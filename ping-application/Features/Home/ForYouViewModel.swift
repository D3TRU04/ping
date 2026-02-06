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
    var notificationsService: NotificationsServiceProtocol?
    var profileService: ProfileServiceProtocol?
    var defaultCollectionId: String?
    var allPlaces: [Place] = []
    var userLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    var isFetchingData: Bool = false

    func configure(
        placesService: PlacesServiceProtocol,
        collectionsService: CollectionsServiceProtocol,
        notificationsService: NotificationsServiceProtocol? = nil,
        profileService: ProfileServiceProtocol? = nil
    ) {
        self.placesService = placesService
        self.collectionsService = collectionsService
        self.notificationsService = notificationsService
        self.profileService = profileService
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
        return [
            "food_drink": ["Burger Joints", "Seafood & Fish Cuisine", "Ice Cream Shops", "Sushi & Japanese Cuisine", "Pizzerias & Italian Cuisine"],
            "shopping": ["Boutiques", "Thrift Stores", "Bookstores"],
            "nature_outdoors": ["Hiking Trails", "Parks & Gardens", "Scenic Viewpoints"],
            "recreation_fitness": ["Gyms & Fitness Centers", "Yoga", "Tennis Courts"]
        ]
    }
}
