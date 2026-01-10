//
//  MapViewModel.swift
//  PingNative
//
//  Created on 12/3/25.
//

import Foundation
import CoreLocation
import Combine

@MainActor
class MapViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Map state
    @Published var centerCoordinate: CLLocationCoordinate2D?
    @Published var markers: [MapMarker] = []
    
    // TODO: Add actual map service reference
    // private let mapService: MapService
    
    func loadMapData() async {
        isLoading = true
        errorMessage = nil

        // TODO: Load markers/pins from Backend
        // This assumes the RN app shows markers on the map

        // Placeholder markers
        // markers = await mapService.loadMarkers()

        isLoading = false
    }
    
    func centerOnUserLocation() async {
        // TODO: Request location permission and center map
        // This assumes the RN app has a "center on me" button
    }
}

// Placeholder marker model
struct MapMarker: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let title: String?
}
