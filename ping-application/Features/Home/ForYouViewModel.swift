//
//  ForYouViewModel.swift
//  PingNative
//
//  ViewModel for the ForYou feed page
//

import Foundation
import SwiftUI
import Combine
import CoreLocation

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

    var placesService: PlacesServiceProtocol?
    var collectionsService: CollectionsServiceProtocol?
    var defaultCollectionId: String?
    var allPlaces: [Place] = []
    var userLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    var isFetchingData: Bool = false

    func configure(placesService: PlacesServiceProtocol, collectionsService: CollectionsServiceProtocol) {
        self.placesService = placesService
        self.collectionsService = collectionsService
        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location {
            userLocation = location.coordinate
        }
    }

    func updateUserLocation() {
        if let location = locationManager.location {
            userLocation = location.coordinate
        }
    }

    func getDefaultPreferences() -> [String: [String]] {
        // Use database category/subcategory values (not display names)
        return [
            "food_drink": ["fast_food", "seafood", "desserts", "japanese", "italian"],
            "shopping": ["malls", "boutiques", "farmers_markets"],
            "nature_outdoors": ["hiking", "parks", "camping"],
            "recreation_fitness": ["gym", "sports", "swimming"]
        ]
    }
}
