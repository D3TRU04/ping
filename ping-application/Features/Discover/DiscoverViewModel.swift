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

@MainActor
class DiscoverViewModel: NSObject, ObservableObject {
    @Published var searchQuery: String = ""
    @Published var currentRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var places: [Place] = []
    @Published var filteredPlaces: [Place] = []
    @Published var selectedPlace: Place?
    @Published var showFilters: Bool = false
    @Published var filters: [String] = []
    @Published var activeTab: String = "all"
    @Published var loading: Bool = false
    @Published var refreshing: Bool = false
    @Published var isSheetDown: Bool = false
    @Published var mapType: String = "standard"
    @Published var errorMessage: String?
    
    private var placesService: PlacesService?
    private let locationManager = CLLocationManager()
    private var searchCancellable: AnyCancellable?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
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
    
    func configure(placesService: PlacesService) {
        self.placesService = placesService
    }
    
    func load() async {
        guard let placesService = placesService else {
            errorMessage = "Places service not configured"
            return
        }
        
        loading = true
        errorMessage = nil
        
        do {
            // Load nearby places based on current map region
            let nearbyPlaces = try await placesService.getNearbyPlaces(
                latitude: currentRegion.center.latitude,
                longitude: currentRegion.center.longitude,
                radiusKm: calculateRadiusKm(),
                limit: 50
            )
            
            self.places = nearbyPlaces.map { $0.place }
            self.filteredPlaces = self.places
            
        } catch {
            print("❌ Error loading nearby places: \(error)")
            errorMessage = error.localizedDescription
        }
        
        loading = false
    }
    
    func refresh() async {
        refreshing = true
        await load()
        refreshing = false
    }
    
    private func performSearch(query: String) async {
        guard let placesService = placesService else { return }
        
        if query.isEmpty {
            filteredPlaces = places
            return
        }
        
        loading = true
        
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
        
        loading = false
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
        locationManager.requestWhenInUseAuthorization()
        
        if let location = locationManager.location {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentRegion.center = location.coordinate
            }
            
            // Reload places for new location
            Task {
                await load()
            }
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentRegion.center = location.coordinate
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error)")
    }
}
