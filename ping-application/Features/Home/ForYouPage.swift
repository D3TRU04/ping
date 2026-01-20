//
//  ForYouPage.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/for-you/page.tsx
//  ForYou feed page connected to Convex database
//

import SwiftUI
import Combine
import CoreLocation

// MARK: - Filter Types
enum SortOption: String, CaseIterable, Identifiable {
    case defaultSort = "Default"
    case ratingHighToLow = "Highest Rated"
    case ratingLowToHigh = "Lowest Rated"
    case nearest = "Nearest"
    case farthest = "Farthest"
    case priceHighToLow = "Price: High to Low"
    case priceLowToHigh = "Price: Low to High"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .defaultSort: return "sparkles"
        case .ratingHighToLow, .ratingLowToHigh: return "star.fill"
        case .nearest, .farthest: return "location.fill"
        case .priceHighToLow, .priceLowToHigh: return "dollarsign.circle.fill"
        }
    }
}

enum RatingFilter: String, CaseIterable, Identifiable {
    case any = "Any"
    case threeAndUp = "3+ Stars"
    case fourAndUp = "4+ Stars"
    case fourFiveAndUp = "4.5+ Stars"

    var id: String { rawValue }
    var minRating: Double {
        switch self {
        case .any: return 0
        case .threeAndUp: return 3.0
        case .fourAndUp: return 4.0
        case .fourFiveAndUp: return 4.5
        }
    }
}

enum PriceFilter: String, CaseIterable, Identifiable {
    case any = "Any"
    case budget = "$"
    case moderate = "$$"
    case upscale = "$$$"
    case fine = "$$$$"

    var id: String { rawValue }
    var maxPrice: Int? {
        switch self {
        case .any: return nil
        case .budget: return 1
        case .moderate: return 2
        case .upscale: return 3
        case .fine: return 4
        }
    }
}

struct PlaceFilters {
    var sortBy: SortOption = .defaultSort
    var minRating: RatingFilter = .any
    var maxPrice: PriceFilter = .any

    var isActive: Bool {
        sortBy != .defaultSort || minRating != .any || maxPrice != .any
    }

    mutating func reset() {
        sortBy = .defaultSort
        minRating = .any
        maxPrice = .any
    }
}

struct ForYouPage: View {
    let currentUser: User?
    let activeTab: SecondaryNavBarTab
    @StateObject private var viewModel = ForYouViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    let onUpdatePreferences: () -> Void
    @Binding var filters: PlaceFilters
    @Binding var showFilterSheet: Bool

    /// Transform stored preferences to the format expected by places query
    private var transformedPreferences: [String: [String]]? {
        currentUser?.categoryPreferences?.toPlacesQueryFormat(using: OnboardingData.categories)
    }

    var body: some View {
        ZStack {
            Color(hex: "FAFAFA")
                .ignoresSafeArea()

            if let userId = currentUser?.id {
                FeedView(
                    items: viewModel.contentData,
                    liked: viewModel.likedPlaces,
                    savedMap: viewModel.savedMap,
                    refreshing: viewModel.refreshing,
                    loading: viewModel.loading,
                    onRefresh: {
                        await viewModel.fetchData(
                            userId: userId,
                            categoryPreferences: transformedPreferences,
                            isRefresh: true,
                            filters: filters
                        )
                    },
                    erroredImages: viewModel.erroredImages,
                    setErroredImages: { newSet in
                        viewModel.erroredImages = newSet
                    },
                    setCurrentIndex: { index in
                        viewModel.currentIndex = index
                    },
                    currentUserId: userId,
                    onLikeChange: { placeId, isLiked in
                        Task {
                            await viewModel.toggleLike(placeId: placeId, isLiked: isLiked, userId: userId)
                        }
                    },
                    onSaveChange: { placeId, listName in
                        Task {
                            await viewModel.toggleSave(placeId: placeId, listName: listName, userId: userId)
                        }
                    },
                    onUpdatePreferences: {
                        onUpdatePreferences()
                    }
                )
                .task {
                    viewModel.configure(
                        placesService: appEnvironment.placesService,
                        collectionsService: appEnvironment.collectionsService
                    )
                    await viewModel.fetchData(
                        userId: userId,
                        categoryPreferences: transformedPreferences,
                        filters: filters
                    )
                }
                .onChange(of: filters.sortBy) { _ in
                    viewModel.applyFilters(filters)
                }
                .onChange(of: filters.minRating) { _ in
                    viewModel.applyFilters(filters)
                }
                .onChange(of: filters.maxPrice) { _ in
                    viewModel.applyFilters(filters)
                }
            } else {
                VStack(spacing: 16) {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color(hex: "F3F4F6"))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Sign in to continue")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Please log in to see your personalized feed")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
            }
        }
    }
}

@MainActor
class ForYouViewModel: ObservableObject {
    @Published var contentData: [Place] = []
    @Published var loading: Bool = false
    @Published var refreshing: Bool = false
    @Published var likedPlaces: Set<String> = []
    @Published var savedPlaces: Set<String> = []
    @Published var savedMap: [String: [String]] = [:]
    @Published var collections: [CollectionsService.Collection] = []
    @Published var erroredImages: Set<String> = []
    @Published var currentIndex: Int = 0
    @Published var errorMessage: String?

    private var placesService: PlacesService?
    private var collectionsService: CollectionsService?
    private var defaultCollectionId: String?
    private var allPlaces: [Place] = [] // Store unfiltered places
    private var userLocation: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()

    func configure(placesService: PlacesService, collectionsService: CollectionsService) {
        self.placesService = placesService
        self.collectionsService = collectionsService
        // Get user's current location for distance calculations
        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location {
            userLocation = location.coordinate
        }
    }

    /// Apply filters and sorting to the places
    func applyFilters(_ filters: PlaceFilters) {
        var filtered = allPlaces

        // Apply rating filter
        if filters.minRating != .any {
            filtered = filtered.filter { ($0.rating ?? 0) >= filters.minRating.minRating }
        }

        // Apply price filter
        if let maxPrice = filters.maxPrice.maxPrice {
            filtered = filtered.filter { ($0.priceRange ?? 0) <= maxPrice }
        }

        // Apply sorting
        filtered = sortPlaces(filtered, by: filters.sortBy)

        contentData = filtered
    }

    private func sortPlaces(_ places: [Place], by sortOption: SortOption) -> [Place] {
        switch sortOption {
        case .defaultSort:
            return places
        case .ratingHighToLow:
            return places.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .ratingLowToHigh:
            return places.sorted { ($0.rating ?? 0) < ($1.rating ?? 0) }
        case .nearest:
            guard let userLoc = userLocation else { return places }
            return places.sorted { distanceToPlace($0, from: userLoc) < distanceToPlace($1, from: userLoc) }
        case .farthest:
            guard let userLoc = userLocation else { return places }
            return places.sorted { distanceToPlace($0, from: userLoc) > distanceToPlace($1, from: userLoc) }
        case .priceHighToLow:
            return places.sorted { ($0.priceRange ?? 0) > ($1.priceRange ?? 0) }
        case .priceLowToHigh:
            return places.sorted { ($0.priceRange ?? 0) < ($1.priceRange ?? 0) }
        }
    }

    private func distanceToPlace(_ place: Place, from userLoc: CLLocationCoordinate2D) -> Double {
        guard let lat = place.latitude, let lng = place.longitude else {
            return Double.infinity
        }
        let placeLocation = CLLocation(latitude: lat, longitude: lng)
        let userCLLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        return userCLLocation.distance(from: placeLocation)
    }

    func updateUserLocation() {
        if let location = locationManager.location {
            userLocation = location.coordinate
        }
    }
    
    func fetchData(userId: String, categoryPreferences: [String: [String]]? = nil, isRefresh: Bool = false, filters: PlaceFilters = PlaceFilters()) async {
        guard let placesService = placesService else {
            errorMessage = "Places service not configured"
            return
        }

        if isRefresh {
            refreshing = true
        } else {
            loading = true
        }

        // Update user location for distance sorting
        updateUserLocation()

        do {
            // Use user's category preferences, or fall back to defaults
            let preferences = categoryPreferences ?? getDefaultPreferences()

            // Get already liked places to exclude
            let excludeIds = Array(likedPlaces)

            let places = try await placesService.fetchPlaces(
                categoryPreferences: preferences,
                excludeIds: excludeIds,
                limit: 50
            )

            // Store all places for filtering
            self.allPlaces = places

            // Apply filters and sorting
            applyFilters(filters)
            
            // Also fetch user's visited places to mark as liked
            let visitedPlaces = try await placesService.getUserVisitedPlaces(userId: userId, limit: 100)
            self.likedPlaces = Set(visitedPlaces.map { $0.placeId })

            // Fetch saved places and collections
            if let collectionsService = collectionsService {
                // Get or create default collection
                self.defaultCollectionId = try await collectionsService.getOrCreateDefaultCollection(userId: userId)

                // Fetch all collections
                self.collections = try await collectionsService.getUserCollections(userId: userId)

                // Fetch saved places
                let saved = try await collectionsService.getUserSavedPlaces(userId: userId, limit: 100)
                self.savedPlaces = Set(saved.map { $0.placeId })

                // Build savedMap for UI
                var newSavedMap: [String: [String]] = [:]
                for savedPlace in saved {
                    let collectionName = savedPlace.collectionName ?? "Want to Go"
                    if newSavedMap[collectionName] == nil {
                        newSavedMap[collectionName] = []
                    }
                    newSavedMap[collectionName]?.append(savedPlace.placeId)
                }
                self.savedMap = newSavedMap
            }

        } catch {
            print("❌ Error fetching feed data: \(error)")
            errorMessage = error.localizedDescription
        }

        loading = false
        refreshing = false
    }
    
    func toggleLike(placeId: String, isLiked: Bool, userId: String) async {
        guard let placesService = placesService else { return }
        
        // Optimistic update
        if isLiked {
            likedPlaces.insert(placeId)
        } else {
            likedPlaces.remove(placeId)
        }
        
        do {
            if isLiked {
                _ = try await placesService.recordPlaceVisit(userId: userId, placeId: placeId)
            } else {
                try await placesService.removePlaceVisit(userId: userId, placeId: placeId)
            }
        } catch {
            print("❌ Error toggling like: \(error)")
            // Revert optimistic update on error
            if isLiked {
                likedPlaces.remove(placeId)
            } else {
                likedPlaces.insert(placeId)
            }
        }
    }
    
    func toggleSave(placeId: String, listName: String, userId: String) async {
        guard let collectionsService = collectionsService else { return }

        let isSaved = savedPlaces.contains(placeId)

        // Optimistic update
        if isSaved {
            savedPlaces.remove(placeId)
            savedMap[listName]?.removeAll { $0 == placeId }
        } else {
            savedPlaces.insert(placeId)
            if savedMap[listName] == nil {
                savedMap[listName] = []
            }
            savedMap[listName]?.append(placeId)
        }

        do {
            if isSaved {
                // Unsave from all collections
                try await collectionsService.unsavePlaceFromAll(userId: userId, placeId: placeId)
            } else {
                // Save to default collection (or create one)
                var collectionId = defaultCollectionId
                if collectionId == nil {
                    collectionId = try await collectionsService.getOrCreateDefaultCollection(userId: userId)
                    self.defaultCollectionId = collectionId
                }
                _ = try await collectionsService.savePlace(userId: userId, placeId: placeId, collectionId: collectionId!)
            }
        } catch {
            print("❌ Error toggling save: \(error)")
            // Revert optimistic update
            if isSaved {
                savedPlaces.insert(placeId)
                if savedMap[listName] == nil {
                    savedMap[listName] = []
                }
                savedMap[listName]?.append(placeId)
            } else {
                savedPlaces.remove(placeId)
                savedMap[listName]?.removeAll { $0 == placeId }
            }
        }
    }

    private func getDefaultPreferences() -> [String: [String]] {
        // Default category preferences when user hasn't set any
        return [
            "Food & Drink": ["Restaurants", "Cafes", "Bars", "Coffee"],
            "Entertainment": ["Movies", "Music", "Games", "Nightlife"],
            "Outdoors": ["Parks", "Hiking", "Beaches", "Nature"],
            "Shopping": ["Malls", "Boutiques", "Markets"]
        ]
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Binding var filters: PlaceFilters
    @Binding var isPresented: Bool
    var onApply: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Sort By Section
                    FilterSection(title: "Sort By", icon: "arrow.up.arrow.down") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(SortOption.allCases) { option in
                                FilterChip(
                                    title: option.rawValue,
                                    icon: option.icon,
                                    isSelected: filters.sortBy == option,
                                    action: { filters.sortBy = option }
                                )
                            }
                        }
                    }

                    // Rating Section
                    FilterSection(title: "Minimum Rating", icon: "star.fill") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(RatingFilter.allCases) { rating in
                                FilterChip(
                                    title: rating.rawValue,
                                    icon: rating == .any ? nil : "star.fill",
                                    isSelected: filters.minRating == rating,
                                    action: { filters.minRating = rating }
                                )
                            }
                        }
                    }

                    // Price Section
                    FilterSection(title: "Max Price", icon: "dollarsign.circle") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(PriceFilter.allCases) { price in
                                FilterChip(
                                    title: price.rawValue,
                                    icon: nil,
                                    isSelected: filters.maxPrice == price,
                                    action: { filters.maxPrice = price }
                                )
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(24)
            }
            .background(Color(hex: "FAFAFA"))
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filters.reset()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply()
                        isPresented = false
                    }
                    .fontWeight(.regular)
                    .foregroundColor(AppColors.mint)
                }
            }
        }
    }
}

// MARK: - Filter Section
struct FilterSection<Content: View>: View {
    let title: String
    let icon: String?
    @ViewBuilder let content: Content

    init(title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(AppColors.mint)
                        .frame(width: 24, alignment: .center)
                }
                Text(title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            content
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .regular))
                        .frame(width: 16, alignment: .center)
                }
                Text(title)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(hex: "E5E7EB"), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? AppColors.mint.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}
