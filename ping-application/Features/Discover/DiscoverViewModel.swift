//
//  DiscoverViewModel.swift
//  PingNative
//
//  Connected to Convex database for places discovery
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI
import Combine

// MARK: - Search Mode
enum DiscoverSearchMode {
    case places
    case users
}

@MainActor
class DiscoverViewModel: NSObject, ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchMode: DiscoverSearchMode = .places
    @Published var currentRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0), // Will be set by user location
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var places: [Place] = []
    @Published var filteredPlaces: [Place] = []
    @Published var userResults: [ProfileSearchResult] = []
    @Published var selectedPlace: Place?
    @Published var showFilters: Bool = false
    @Published var filters: [String] = []
    @Published var activeTab: String = "all"
    @Published var loading: Bool = false
    @Published var refreshing: Bool = false
    @Published var isSheetDown: Bool = false
    @Published var mapType: String = "standard"
    @Published var errorMessage: String?
    @Published var locationStatus: String = "Initializing..."
    @Published var locationReady: Bool = false

    private var hasInitializedLocation: Bool = false
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    private var placesService: PlacesService?
    private var profileService: ProfileService?
    private var currentUser: User?
    private let locationManager = CLLocationManager()
    private var searchCancellable: AnyCancellable?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request location authorization immediately
        locationManager.requestWhenInUseAuthorization()
        
        // Debounce search queries
        searchCancellable = $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task {
                    await self?.performSearch(query: query)
                }
            }
    }
    
    func configure(placesService: PlacesService, profileService: ProfileService? = nil, currentUser: User? = nil) {
        self.placesService = placesService
        self.profileService = profileService
        self.currentUser = currentUser
    }

    /// Transform stored preferences to the format expected by places query
    private var transformedPreferences: [String: [String]]? {
        currentUser?.categoryPreferences?.toPlacesQueryFormat(using: OnboardingData.categories)
    }

    /// Default preferences when user hasn't set any
    private func getDefaultPreferences() -> [String: [String]] {
        return [
            "food_drink": ["Restaurants", "Cafes", "Bars", "Coffee"],
            "social_nightlife": ["Bars", "Clubs", "Lounges"],
            "nature_outdoors": ["Parks", "Hiking", "Lakes"],
            "shopping": ["Malls", "Boutiques", "Markets"]
        ]
    }
    
    func load() async {
        loading = true
        errorMessage = nil

        // On first load, get user's actual location
        if !hasInitializedLocation {
            await initializeUserLocation()
            hasInitializedLocation = true
        }

        print("📍 Loading places for region: \(currentRegion.center.latitude), \(currentRegion.center.longitude)")

        // Get user's category preferences or use defaults
        let preferences = transformedPreferences ?? getDefaultPreferences()
        print("🏷️ Using preferences: \(preferences.keys.joined(separator: ", "))")

        // Try to load from backend
        if let placesService = placesService {
            do {
                // Load places filtered by user's category preferences
                let filteredByPreferences = try await placesService.fetchPlaces(
                    categoryPreferences: preferences,
                    excludeIds: [],
                    limit: 100
                )

                self.places = filteredByPreferences
                self.filteredPlaces = self.places

                print("✅ Loaded \(self.places.count) places matching preferences")

                // If no places match preferences, fall back to nearby places
                if self.places.isEmpty {
                    print("🔄 No places match preferences, trying nearby places...")
                    let radius = max(calculateRadiusKm(), 100)
                    let nearbyPlaces = try await placesService.getNearbyPlaces(
                        latitude: currentRegion.center.latitude,
                        longitude: currentRegion.center.longitude,
                        radiusKm: radius,
                        limit: 100
                    )
                    self.places = nearbyPlaces.map { $0.place }
                    self.filteredPlaces = self.places
                    print("✅ Loaded \(self.places.count) nearby places as fallback")
                }

                // Debug: Print places with coordinates
                for place in self.places.prefix(5) {
                    print("   - \(place.name): lat=\(place.latitude ?? 0), lng=\(place.longitude ?? 0), category=\(place.category ?? "none")")
                }

            } catch {
                print("❌ Error loading places: \(error)")
                errorMessage = error.localizedDescription
            }
        } else {
            print("⚠️ Places service not configured")
        }

        loading = false
    }
    
    private func initializeUserLocation() async {
        print("📍 Initializing user location...")
        locationStatus = "Getting location..."

        let authStatus = locationManager.authorizationStatus
        print("📍 Authorization status: \(authStatus.rawValue)")

        // Check authorization status
        switch authStatus {
        case .notDetermined:
            print("📍 Requesting authorization...")
            locationManager.requestWhenInUseAuthorization()
            // Wait for authorization response
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds for user to respond
        case .denied, .restricted:
            print("❌ Location access denied - using fallback location")
            locationStatus = "Location access denied"
            // Set a reasonable fallback (will show empty map initially)
            locationReady = true
            return
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location authorized")
        @unknown default:
            break
        }

        // Check if we already have a cached location
        if let location = locationManager.location {
            let coord = location.coordinate
            // Validate the location is reasonable (not 0,0)
            if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                print("📍 Using cached location: \(coord.latitude), \(coord.longitude)")
                currentRegion.center = coord
                locationStatus = "Location found"
                locationReady = true
                return
            }
        }

        // Request a fresh location and wait for it
        print("📍 Requesting fresh location...")
        locationManager.startUpdatingLocation()

        // Wait for location with timeout using async continuation
        let location = await withCheckedContinuation { (continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>) in
            self.locationContinuation = continuation

            // Set timeout - give more time (5 seconds) for initial location fix
            Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds timeout
                if let cont = self.locationContinuation {
                    self.locationContinuation = nil
                    self.locationManager.stopUpdatingLocation()
                    print("⏱️ Location timeout")
                    cont.resume(returning: nil)
                }
            }
        }

        // Process the result
        if let coord = location {
            print("📍 Got location: \(coord.latitude), \(coord.longitude)")
            currentRegion.center = coord
            locationStatus = "Location found"
            locationReady = true
        } else {
            // Check one more time if locationManager has a location
            if let lastLocation = locationManager.location {
                let coord = lastLocation.coordinate
                if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                    print("📍 Using last known location: \(coord.latitude), \(coord.longitude)")
                    currentRegion.center = coord
                    locationStatus = "Location found"
                    locationReady = true
                    return
                }
            }
            print("⚠️ Could not get location - map will center when location becomes available")
            locationStatus = "Waiting for location..."
            locationReady = true
        }
    }
    
    func refresh() async {
        refreshing = true
        await load()
        refreshing = false
    }
    
    private func performSearch(query: String) async {
        if query.isEmpty {
            filteredPlaces = places
            userResults = []
            return
        }

        loading = true

        switch searchMode {
        case .places:
            await searchPlaces(query: query)
        case .users:
            await searchUsers(query: query)
        }

        loading = false
    }

    private func searchPlaces(query: String) async {
        guard let placesService = placesService else { return }

        do {
            let searchResults = try await placesService.searchPlaces(query: query, limit: 50)
            self.filteredPlaces = searchResults
        } catch {
            print("❌ Error searching places: \(error)")
            // Fall back to local filtering
            filteredPlaces = places.filter { place in
                place.name.localizedCaseInsensitiveContains(query) ||
                (place.category?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }
    }

    private func searchUsers(query: String) async {
        guard let profileService = profileService else { return }

        do {
            let results = try await profileService.searchUsers(query: query, limit: 50)
            self.userResults = results
        } catch {
            print("❌ Error searching users: \(error)")
            self.userResults = []
        }
    }
    
    func filterByCategory(_ category: String) async {
        activeTab = category
        
        if category == "all" {
            filteredPlaces = places
            return
        }
        
        filteredPlaces = places.filter { ($0.category?.lowercased() ?? "") == category.lowercased() }
    }
    
    func selectPlace(_ place: Place) {
        selectedPlace = place
        
        // Center map on selected place
        if let lat = place.latitude, let lng = place.longitude {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentRegion.center = CLLocationCoordinate2D(
                    latitude: lat,
                    longitude: lng
                )
            }
        }
    }
    
    func clearSelection() {
        selectedPlace = nil
    }
    
    func centerOnUserLocation() {
        print("📍 Center on user location requested")

        // Check if we have a valid cached location first
        if let location = locationManager.location {
            let coord = location.coordinate
            if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                print("📍 Centering on: \(coord.latitude), \(coord.longitude)")
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentRegion.center = coord
                }
                return
            }
        }

        // Request fresh location if no valid cached location
        print("⚠️ No valid cached location, requesting fresh location...")
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // The delegate will update currentRegion when location arrives
    }
    
    func onRegionChange() {
        // Reload places when map region changes significantly
        Task {
            await load()
        }
    }
    
    private func calculateRadiusKm() -> Double {
        // Calculate radius based on map span
        let latDelta = currentRegion.span.latitudeDelta
        let radiusKm = latDelta * 111 / 2 // 111km per degree of latitude
        return min(max(radiusKm, 1), 50) // Clamp between 1km and 50km
    }
}

// MARK: - CLLocationManagerDelegate
extension DiscoverViewModel: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coord = location.coordinate

        // Validate location is reasonable
        guard abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 else { return }

        print("📍 Got location update: \(coord.latitude), \(coord.longitude)")

        Task { @MainActor in
            // Always update the region with the latest location
            self.currentRegion.center = coord
            self.locationStatus = "Location updated"
            self.locationReady = true

            // Resume continuation if waiting (returns the coordinate)
            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                manager.stopUpdatingLocation()
                continuation.resume(returning: coord)
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("📍 Authorization changed: \(status.rawValue)")

        Task { @MainActor in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationStatus = "Authorized"
                // If we already have a location, use it immediately
                if let location = manager.location {
                    let coord = location.coordinate
                    if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                        print("📍 Using location from authorization: \(coord.latitude), \(coord.longitude)")
                        self.currentRegion.center = coord
                        self.locationReady = true
                    }
                }
                manager.startUpdatingLocation()
            case .denied, .restricted:
                self.locationStatus = "Location denied"
                self.locationReady = true
                print("❌ Location access denied or restricted")
            case .notDetermined:
                self.locationStatus = "Waiting for permission"
            @unknown default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error)")

        Task { @MainActor in
            self.locationStatus = "Location error"

            // Resume continuation if waiting (returns nil to indicate failure)
            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                continuation.resume(returning: nil)
            }
        }
    }
}
