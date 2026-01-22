//
//  DiscoverView.swift
//  PingNative
//
//  Clean, minimal discover screen with Mapbox integration
//

import SwiftUI
import MapKit

struct DiscoverView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = DiscoverViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var sheetExpansion: CGFloat = 0 // 0 = minimized, 1 = expanded

    // Consistent background color matching Profile
    private let backgroundColor = Color(hex: "FAFAFA")
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                // Map Background (only visible in places mode)
                if viewModel.searchMode == .places {
                    MapboxMapView(
                        coordinateRegion: $viewModel.currentRegion,
                        showsUserLocation: true,
                        mapType: viewModel.mapType == "satellite" ? .satellite : .standard,
                        places: viewModel.filteredPlaces,
                        selectedPlace: viewModel.selectedPlace,
                        onPlaceSelect: { place in
                            withAnimation(.easeOut(duration: 0.3)) {
                                viewModel.selectPlace(place)
                            }
                        }
                    )
                    .ignoresSafeArea()

                    // Gradient overlay at top for better readability
                    VStack {
                        LinearGradient(
                            colors: viewModel.mapType == "satellite" 
                                ? [Color.black.opacity(0.6), Color.black.opacity(0)]
                                : [Color.white.opacity(0.95), Color.white.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 180)
                        .ignoresSafeArea()

                        Spacer()
                    }
                } else {
                    // Background for users mode
                    backgroundColor
                        .ignoresSafeArea()
                }

                // Top Navigation
                VStack(spacing: 10) {
                    // Nav Bar
                    DiscoverNavBar(
                        searchMode: $viewModel.searchMode,
                        isSatelliteMode: viewModel.mapType == "satellite",
                        onModeChange: {
                            viewModel.searchQuery = ""
                            viewModel.userResults = []
                            viewModel.filteredPlaces = viewModel.places
                        },
                        onSearchTap: {
                            path.append("searchUsers")
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Search Bar (Places only)
                    if viewModel.searchMode == .places {
                        DiscoverSearchBar(
                            searchQuery: $viewModel.searchQuery,
                            placeholder: "Search places...",
                            isSatelliteMode: viewModel.mapType == "satellite"
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                        // Category Filter Bar
                        DiscoverCategoryFilterBar(
                            activeCategory: $viewModel.activeTab,
                            isSatelliteMode: viewModel.mapType == "satellite",
                            userSelectedCategories: appEnvironment.currentUser?.categoryPreferences?.categories
                        ) { category in
                            viewModel.filterByCategory(category)
                        }
                        .padding(.bottom, 16)
                    }

                    // Zoom & Map Controls (Right side)
                    if viewModel.searchMode == .places {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                // Zoom In
                                Button(action: {
                                    var region = viewModel.currentRegion
                                    region.span.latitudeDelta /= 2
                                    region.span.longitudeDelta /= 2
                                    withAnimation {
                                        viewModel.currentRegion = region
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.textPrimary)
                                        .frame(width: 44, height: 44)
                                        .background(viewModel.mapType == "satellite" ? Color.black.opacity(0.5) : Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }

                                // Zoom Out
                                Button(action: {
                                    var region = viewModel.currentRegion
                                    region.span.latitudeDelta *= 2
                                    region.span.longitudeDelta *= 2
                                    withAnimation {
                                        viewModel.currentRegion = region
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.textPrimary)
                                        .frame(width: 44, height: 44)
                                        .background(viewModel.mapType == "satellite" ? Color.black.opacity(0.5) : Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }

                                // Divider
                                Rectangle()
                                    .fill(viewModel.mapType == "satellite" ? Color.white.opacity(0.2) : Color.gray.opacity(0.2))
                                    .frame(width: 24, height: 1)
                                    .padding(.vertical, 4)

                                // Center on Location
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        viewModel.centerOnUserLocation()
                                    }
                                }) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.mint)
                                        .frame(width: 44, height: 44)
                                        .background(viewModel.mapType == "satellite" ? Color.black.opacity(0.5) : Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }

                                // Satellite Toggle
                                Button(action: {
                                    viewModel.mapType = viewModel.mapType == "standard" ? "satellite" : "standard"
                                }) {
                                    Image(systemName: viewModel.mapType == "satellite" ? "map.fill" : "globe.americas.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.textSecondary)
                                        .frame(width: 44, height: 44)
                                        .background(viewModel.mapType == "satellite" ? Color.black.opacity(0.5) : Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                            }
                            .padding(.trailing, 16)
                            .opacity(Double(1 - sheetExpansion * 0.6))
                        }
                    }

                    Spacer()
                }
            
            // Status indicator - centered on map
            if viewModel.searchMode == .places && viewModel.selectedPlace == nil {
                VStack {
                    Spacer()
                    
                    if viewModel.loading {
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(viewModel.mapType == "satellite" ? .white : AppColors.mint)
                            Text("Finding places nearby...")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            (viewModel.mapType == "satellite" ? Color.black.opacity(0.6) : Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                        )
                        .cornerRadius(25)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 60) // Offset slightly above center
            }
            
            // Selected Place Card
            if let selectedPlace = viewModel.selectedPlace {
                VStack {
                    Spacer()

                    DiscoverPlaceCard(
                        place: selectedPlace,
                        isSatelliteMode: viewModel.mapType == "satellite",
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.25)) {
                                viewModel.selectedPlace = nil
                            }
                        },
                        onNavigate: {
                            // TODO: Open in Maps
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 130)
                    .transition(
                        .asymmetric(
                            insertion: .offset(y: 20).combined(with: .opacity),
                            removal: .offset(y: 10).combined(with: .opacity)
                        )
                    )
                    .animation(.easeOut(duration: 0.3), value: selectedPlace.id)
                }
                .zIndex(1)
            }
            
            /*
            // Bottom Content - based on search mode
            if viewModel.searchMode == .places {
                // Bottom Sheet for Places
                VStack {
                    Spacer()

                    DiscoverBottomSheet(
                        places: viewModel.filteredPlaces,
                        loading: viewModel.loading,
                        onPlaceSelect: { place in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                viewModel.selectedPlace = place
                            }
                        },
                        onExpansionChange: { expansion in
                            withAnimation(.easeOut(duration: 0.2)) {
                                sheetExpansion = expansion
                            }
                        }
                    )
                    .padding(.bottom, 100) // Space for floating nav bar
                }
            } else {
                // User Search Results - Initial State (Empty or Featured)
                // Since actual search is now a separate screen, we can show something else here
                // or just keep it simple.
                VStack {
                    Spacer()
                    
                    Text("Tap the magnifying glass to search users")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                    
                    Spacer()
                }
                .padding(.bottom, 100)
            }
            */
        }
        // Report sheet expansion and satellite mode to parent for nav bar animation
        .preference(key: SheetExpansionPreferenceKey.self, value: sheetExpansion)
        .preference(key: SatelliteModePreferenceKey.self, value: viewModel.mapType == "satellite")
        .navigationDestination(for: String.self) { route in
            if route == "searchUsers" {
                SearchUsersView()
                    .environmentObject(appEnvironment)
                    .navigationBarBackButtonHidden(true)
            } else if route.starts(with: "user:") {
                let userId = String(route.dropFirst(5))
                PublicProfileView(userId: userId)
                    .environmentObject(appEnvironment)
            }
        }
        .onAppear {
            // Request location permission when view appears (proper timing for iOS)
            viewModel.requestLocationPermission()
        }
        .task {
            viewModel.configure(
                placesService: appEnvironment.placesService,
                profileService: appEnvironment.profileService,
                currentUser: appEnvironment.currentUser
            )
            await viewModel.load()
        }
    }
    }
}

// Preference key for sheet expansion state (shared with RootView)
struct SheetExpansionPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Discover Nav Bar
struct DiscoverNavBar: View {
    @Binding var searchMode: DiscoverSearchMode
    var isSatelliteMode: Bool = false
    var onModeChange: (() -> Void)? = nil
    var onSearchTap: () -> Void
    
    private var textColor: Color {
        isSatelliteMode ? .white : AppColors.textPrimary
    }

    var body: some View {
        HStack(alignment: .center) {
            Text("Discover")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(textColor)
                .shadow(color: isSatelliteMode ? Color.black.opacity(0.3) : Color.clear, radius: 2, x: 0, y: 1)
            
            Spacer()
            
            // Search Button (Magnifying Glass)
            Button(action: onSearchTap) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .regular)) // Match title size/weight
                    .foregroundColor(textColor)
                    .frame(width: 44, height: 44) // Keep tappable area
                    .contentShape(Rectangle())
                    .shadow(color: isSatelliteMode ? Color.black.opacity(0.3) : Color.clear, radius: 2, x: 0, y: 1)
            }
        }
    }
}

// MARK: - Discover Search Bar
struct DiscoverSearchBar: View {
    @Binding var searchQuery: String
    var placeholder: String = "Search places..."
    var isSatelliteMode: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textTertiary)

            ZStack(alignment: .leading) {
                // Custom placeholder with proper color
                if searchQuery.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.5) : AppColors.textTertiary)
                }
                
                TextField("", text: $searchQuery)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(isSatelliteMode ? .white : AppColors.textPrimary)
                    .focused($isFocused)
            }

            if !searchQuery.isEmpty {
                Button(action: {
                    searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(isSatelliteMode ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Discover Map Controls
struct DiscoverMapControls: View {
    var isSatelliteMode: Bool = false
    let onLocationTap: () -> Void
    let onLayerTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Location Button
            Button(action: onLocationTap) {
                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.mint)
                    .frame(width: 48, height: 48)
                    .background(isSatelliteMode ? Color.black.opacity(0.5) : Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
            
            // Layer Toggle Button
            Button(action: onLayerTap) {
                Image(systemName: "square.3.layers.3d")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSatelliteMode ? .white : AppColors.textSecondary)
                    .frame(width: 48, height: 48)
                    .background(isSatelliteMode ? Color.black.opacity(0.5) : Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
        }
    }
}

// MARK: - Discover Place Card
struct DiscoverPlaceCard: View {
    let place: Place
    var isSatelliteMode: Bool = false
    let onDismiss: () -> Void
    let onNavigate: () -> Void
    
    private var formattedHours: String? {
        guard let hours = place.hours, !hours.isEmpty else { return nil }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // 1=Sun, 2=Mon, ..., 7=Sat
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let todayName = days[weekday - 1]

        if let todayHour = hours.first(where: { $0.hasPrefix(todayName) }) {
            // Remove the day prefix for cleaner display "Monday: 9 AM..." -> "9 AM..."
            if let colonIndex = todayHour.firstIndex(of: ":") {
                return String(todayHour[todayHour.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            }
            return todayHour
        }
        return nil
    }

    private func getSubcategoryGradient(_ name: String) -> [Color] {
        let sum = name.utf8.reduce(0) { $0 + Int($1) }
        let index = sum % 6

        switch index {
        case 0:
            return [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")] // Mint
        case 1:
            return [Color(hex: "FF9F43"), Color(hex: "EE5A24")] // Orange
        case 2:
            return [Color(hex: "54a0ff"), Color(hex: "2e86de")] // Blue
        case 3:
            return [Color(hex: "a55eea"), Color(hex: "8854d0")] // Purple
        case 4:
            return [Color(hex: "ff6b6b"), Color(hex: "ee5253")] // Red
        case 5:
            return [Color(hex: "1dd1a1"), Color(hex: "10ac84")] // Green
        default:
            return [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")]
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Place Info
            VStack(alignment: .leading, spacing: 8) {
                Text(place.name)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(isSatelliteMode ? .white : AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let address = place.address {
                    Text(address)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Rating & Category & Hours
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 12) {
                        if let rating = place.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "FBBF24"))
                                Text(String(format: "%.1f", rating))
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textSecondary)
                            }
                        }
                        
                        // Subcategory with gradient colors
                        if let subcategory = place.subcategory, !subcategory.isEmpty {
                            Text(subcategory.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    LinearGradient(
                                        colors: isSatelliteMode ? [Color.white.opacity(0.4), Color.white.opacity(0.2)] : getSubcategoryGradient(subcategory),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(Capsule())
                        } else if let category = place.category {
                            Text(category.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    LinearGradient(
                                        colors: isSatelliteMode ? [Color.white.opacity(0.4), Color.white.opacity(0.2)] : getSubcategoryGradient(category),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(Capsule())
                        }
                    }

                    if let hours = formattedHours {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textTertiary)
                            Text(hours)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(isSatelliteMode ? .white.opacity(0.9) : AppColors.textPrimary)
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            // Actions
            VStack(spacing: 12) {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textTertiary)
                        .frame(width: 36, height: 36)
                        .background(isSatelliteMode ? Color.white.opacity(0.2) : Color(hex: "F3F4F6"))
                        .clipShape(Circle())
                }
                
                Button(action: onNavigate) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSatelliteMode ? .white : AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(isSatelliteMode ? Color.white.opacity(0.2) : Color(hex: "F3F4F6"))
                        .clipShape(Circle())
                }
            }
        }
        .padding(20)
        .background(isSatelliteMode ? Color.black.opacity(0.8) : Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Discover Bottom Sheet
struct DiscoverBottomSheet: View {
    let places: [Place]
    let loading: Bool
    let onPlaceSelect: (Place) -> Void
    var onExpansionChange: ((CGFloat) -> Void)? = nil
    
    @State private var sheetHeight: CGFloat = 140
    
    private let minHeight: CGFloat = 140
    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    
    private var expansionProgress: CGFloat {
        (sheetHeight - minHeight) / (maxHeight - minHeight)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle Area - Compact & Clean
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "D1D5DB"))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
                // Header Row
                HStack(alignment: .center) {
                    // Icon + Title
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "6EE7E7").opacity(0.3), Color(hex: "1FC9C3").opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "1FC9C3"))
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Nearby")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("\(places.count) places")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Expand indicator with animation
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if sheetHeight < (minHeight + maxHeight) / 2 {
                                sheetHeight = maxHeight
                            } else {
                                sheetHeight = minHeight
                            }
                            onExpansionChange?(expansionProgress)
                        }
                    }) {
                        Image(systemName: expansionProgress > 0.5 ? "chevron.compact.down" : "chevron.compact.up")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.textTertiary)
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newHeight = sheetHeight - value.translation.height
                        sheetHeight = min(max(newHeight, minHeight), maxHeight)
                        onExpansionChange?(expansionProgress)
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            if sheetHeight < (minHeight + maxHeight) / 2 {
                                sheetHeight = minHeight
                            } else {
                                sheetHeight = maxHeight
                            }
                            onExpansionChange?(expansionProgress)
                        }
                    }
            )
            
            // Content
            ZStack {
                Color(hex: "F5F5F7")
                
                if loading {
                    VStack(spacing: 12) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1FC9C3")))
                            .scaleEffect(1.2)
                        Text("Finding places...")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                } else if places.isEmpty {
                    VStack(spacing: 14) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            
                            Image(systemName: "mappin.slash")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(Color(hex: "B2BEC3"))
                        }
                        
                        VStack(spacing: 4) {
                            Text("No places nearby")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Try a different location")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            ForEach(places) { place in
                                DiscoverPlaceRow(place: place)
                                    .onTapGesture {
                                        onPlaceSelect(place)
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .frame(height: max(sheetHeight - 90, 50))
        }
        .frame(height: sheetHeight)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
        .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: -10)
    }
}

// MARK: - Discover Place Row
struct DiscoverPlaceRow: View {
    let place: Place

    private func getSubcategoryGradient(_ name: String) -> [Color] {
        let sum = name.utf8.reduce(0) { $0 + Int($1) }
        let index = sum % 6

        switch index {
        case 0:
            return [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")] // Mint
        case 1:
            return [Color(hex: "FF9F43"), Color(hex: "EE5A24")] // Orange
        case 2:
            return [Color(hex: "54a0ff"), Color(hex: "2e86de")] // Blue
        case 3:
            return [Color(hex: "a55eea"), Color(hex: "8854d0")] // Purple
        case 4:
            return [Color(hex: "ff6b6b"), Color(hex: "ee5253")] // Red
        case 5:
            return [Color(hex: "1dd1a1"), Color(hex: "10ac84")] // Green
        default:
            return [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")]
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail with gradient accent
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                
                ZStack {
                    Circle()
                        .fill(Color(hex: "1FC9C3").opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(Color(hex: "1FC9C3"))
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // Subcategory with gradient colors
                    if let subcategory = place.subcategory, !subcategory.isEmpty {
                        Text(subcategory.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                LinearGradient(
                                    colors: getSubcategoryGradient(subcategory),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                    } else if let category = place.category {
                        Text(category.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                LinearGradient(
                                    colors: getSubcategoryGradient(category),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                    }

                    if let rating = place.rating {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "FBBF24"))
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }

            Spacer()

            // Arrow button
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textTertiary)
                .frame(width: 28, height: 28)
                .background(Color(hex: "F3F4F6"))
                .clipShape(Circle())
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - User Search Results
struct DiscoverUserResults: View {
    let users: [ProfileSearchResult]
    let loading: Bool
    let onUserSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "D1D5DB"))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 10)

                // Header Row
                HStack(alignment: .center) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "6EE7E7").opacity(0.3), Color(hex: "1FC9C3").opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)

                            Image(systemName: "person.2.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "1FC9C3"))
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Users")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)

                            Text("\(users.count) result\(users.count != 1 ? "s" : "")")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)

            // Content
            ZStack {
                Color(hex: "F5F5F7")

                if loading {
                    VStack(spacing: 12) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1FC9C3")))
                            .scaleEffect(1.2)
                        Text("Searching users...")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                } else if users.isEmpty {
                    VStack(spacing: 14) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)

                            Image(systemName: "person.slash")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(Color(hex: "B2BEC3"))
                        }

                        VStack(spacing: 4) {
                            Text("No users found")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)

                            Text("Try a different search")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(users.enumerated()), id: \.element.id) { index, user in
                                UserSearchResultRow(user: user)
                                    .onTapGesture {
                                        onUserSelect(user.id)
                                    }
                                
                                if index < users.count - 1 {
                                    Divider()
                                        .padding(.leading, 68)
                                        .opacity(0.4)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: UIScreen.main.bounds.height * 0.7)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
        .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: -10)
    }
}

// MARK: - User Search Result Row
struct UserSearchResultRow: View {
    let user: ProfileSearchResult

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppColors.borderSubtle)
                    .frame(width: 54, height: 54)

                if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 54, height: 54)
                                .clipShape(Circle())
                        default:
                            Image(systemName: "person.fill")
                                .font(.system(size: 22))
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                if let fullName = user.fullName {
                    Text(fullName)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                }

                Text("@\(user.username)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)

                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.textTertiary.opacity(0.4))
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Category Filter Bar
struct DiscoverCategoryFilterBar: View {
    @Binding var activeCategory: String
    var isSatelliteMode: Bool = false
    var userSelectedCategories: [String]? // User's selected category IDs from onboarding
    let onCategorySelect: (String) -> Void

    // All available categories with their display info
    private let allCategories: [(id: String, filterId: String, name: String, icon: String)] = [
        ("food-drink", "food_drink", "Food", "🍔"),
        ("shopping-markets", "shopping", "Shopping", "🛍️"),
        ("social-nightlife", "social_nightlife", "Nightlife", "🍻"),
        ("nature-outdoors", "nature_outdoors", "Nature", "🌲"),
        ("recreation-fitness", "recreation_fitness", "Fitness", "💪"),
        ("creative-arts", "creative_arts", "Arts", "🎨"),
        ("indoor-adventure", "indoor_adventure", "Adventure", "🎮"),
        ("sight-seeing", "sight_seeing", "Sights", "🏛️")
    ]

    // Filter to only show user-selected categories
    private var displayCategories: [(id: String, filterId: String, name: String, icon: String)] {
        guard let selected = userSelectedCategories, !selected.isEmpty else {
            // If no preferences, show all categories
            return allCategories
        }
        return allCategories.filter { selected.contains($0.id) }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Always show "All" option first
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: activeCategory == "all",
                    isSatelliteMode: isSatelliteMode
                ) {
                    onCategorySelect("all")
                }

                // Show user's selected categories
                ForEach(displayCategories, id: \.id) { category in
                    CategoryChip(
                        title: category.name,
                        icon: category.icon,
                        isSelected: activeCategory == category.filterId,
                        isSatelliteMode: isSatelliteMode
                    ) {
                        onCategorySelect(category.filterId)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var isSatelliteMode: Bool = false
    let action: () -> Void

    private var isEmoji: Bool {
        icon.unicodeScalars.first?.properties.isEmoji ?? false
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isEmoji {
                    Text(icon)
                        .font(.system(size: 14))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundColor(
                isSelected
                    ? .white
                    : (isSatelliteMode ? .white : AppColors.textPrimary)
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else if isSatelliteMode {
                        Color.black.opacity(0.5)
                    } else {
                        Color.white
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(
                color: isSelected
                    ? Color(hex: "1FC9C3").opacity(0.3)
                    : Color.black.opacity(isSatelliteMode ? 0 : 0.06),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

