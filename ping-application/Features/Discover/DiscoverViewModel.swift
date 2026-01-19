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
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
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
    
    private var hasInitializedLocation: Bool = false
    private var locationContinuation: CheckedContinuation<Void, Never>?

    private var placesService: PlacesService?
    private var profileService: ProfileService?
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
    
    func configure(placesService: PlacesService, profileService: ProfileService? = nil) {
        self.placesService = placesService
        self.profileService = profileService
    }
    
    func load() async {
        loading = true
        errorMessage = nil
        
        // On first load, get user's actual location
        if !hasInitializedLocation {
            await initializeUserLocation()
            hasInitializedLocation = true
        }
        
        let radius = max(calculateRadiusKm(), 100) // Use at least 100km radius
        print("📍 Loading places for region: \(currentRegion.center.latitude), \(currentRegion.center.longitude), radius: \(radius)km")
        
        // Try to load from backend
        if let placesService = placesService {
            do {
                // Load nearby places based on current map region with large radius
                let nearbyPlaces = try await placesService.getNearbyPlaces(
                    latitude: currentRegion.center.latitude,
                    longitude: currentRegion.center.longitude,
                    radiusKm: radius,
                    limit: 100
                )
                
                self.places = nearbyPlaces.map { $0.place }
                self.filteredPlaces = self.places
                
                print("✅ Loaded \(self.places.count) places from backend (nearby)")
                
                // If no nearby places, try to get all places as fallback
                if self.places.isEmpty {
                    print("🔄 No nearby places, trying to fetch all places...")
                    let allPlaces = try await placesService.getAllPlaces(limit: 100)
                    self.places = allPlaces
                    self.filteredPlaces = self.places
                    print("✅ Loaded \(self.places.count) places from backend (all)")
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
            // Wait for authorization
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        case .denied, .restricted:
            print("❌ Location access denied - using default location")
            locationStatus = "Location access denied"
            // Don't return - continue with default location
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location authorized")
        @unknown default:
            break
        }
        
        // Check if we already have a location
        if let location = locationManager.location {
            let coord = location.coordinate
            // Validate the location is reasonable (not 0,0)
            if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                print("📍 Using cached location: \(coord.latitude), \(coord.longitude)")
                currentRegion.center = coord
                locationStatus = "Location found"
                return
            }
        }
        
        // Request a fresh location
        print("📍 Requesting fresh location...")
        locationManager.startUpdatingLocation()
        
        // Wait for location with timeout
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.locationContinuation = continuation
            
            // Set timeout
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds timeout
                if let cont = self.locationContinuation {
                    self.locationContinuation = nil
                    self.locationManager.stopUpdatingLocation()
                    print("⏱️ Location timeout - using default location")
                    self.locationStatus = "Using default location"
                    cont.resume()
                }
            }
        }
        
        // Final check - if we got a location during the wait
        if let location = locationManager.location {
            let coord = location.coordinate
            if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                print("📍 Got location after wait: \(coord.latitude), \(coord.longitude)")
                currentRegion.center = coord
                locationStatus = "Location found"
            }
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
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let location = locationManager.location {
            print("📍 Centering on: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentRegion.center = location.coordinate
            }
            
            // Reload places for new location
            Task {
                // Reset initialization flag to force reload
                hasInitializedLocation = true
                await load()
            }
        } else {
            print("⚠️ No location available yet, requesting...")
            locationManager.requestLocation()
        }
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
        
        print("📍 Got location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        Task { @MainActor in
            self.currentRegion.center = location.coordinate
            self.locationStatus = "Location updated"
            
            // Resume continuation if waiting
            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                manager.stopUpdatingLocation()
                continuation.resume()
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
                    print("📍 Using location from authorization: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    self.currentRegion.center = location.coordinate
                }
                manager.startUpdatingLocation()
            case .denied, .restricted:
                self.locationStatus = "Location denied"
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
            
            // Resume continuation if waiting
            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                continuation.resume()
            }
        }
    }
}
