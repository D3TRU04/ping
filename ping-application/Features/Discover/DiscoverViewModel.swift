//
//  DiscoverViewModel.swift
//  PingNative
//
//  Source: ping/apps/src/screens/discover/hooks/useDiscoverState.ts (implied)
//  Generated Swift ViewModel matching RN state management
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI
import Combine

@MainActor
class DiscoverViewModel: ObservableObject {
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
    
    func load() async {
        loading = true
        // TODO: Load places from Supabase
        // This matches RN behavior where places are fetched from backend
        loading = false
    }
    
    func refresh() async {
        refreshing = true
        await load()
        refreshing = false
    }
    
    func centerOnUserLocation() {
        // TODO: Request location permission and center map
        // This matches RN MapControls behavior
    }
}
