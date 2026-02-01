//
//  DiscoverViewModel.swift
//  PingNative
//
//  Core view model for places discovery
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI
import Combine

enum DiscoverSearchMode {
    case places
    case users
}

@MainActor
class DiscoverViewModel: NSObject, ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchMode: DiscoverSearchMode = .places
    @Published var currentRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
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

    var hasInitializedLocation: Bool = false
    var hasLoadedPlaces: Bool = false
    var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    var placesService: PlacesServiceProtocol?
    var profileService: ProfileServiceProtocol?
    var currentUser: User?
    let locationManager = CLLocationManager()
    private var searchCancellable: AnyCancellable?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        searchCancellable = $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task {
                    await self?.performSearch(query: query)
                }
            }
    }

    func configure(placesService: PlacesServiceProtocol, profileService: ProfileServiceProtocol? = nil, currentUser: User? = nil) {
        self.placesService = placesService
        self.profileService = profileService
        self.currentUser = currentUser
    }

    var transformedPreferences: [String: [String]]? {
        currentUser?.categoryPreferences?.toPlacesQueryFormat(using: OnboardingData.categories)
    }

    func getDefaultPreferences() -> [String: [String]] {
        return [
            "food_drink": ["Restaurants", "Cafes", "Bars", "Coffee"],
            "social_nightlife": ["Bars", "Clubs", "Lounges"],
            "nature_outdoors": ["Parks", "Hiking", "Lakes"],
            "shopping": ["Malls", "Boutiques", "Markets"]
        ]
    }

    func selectPlace(_ place: Place) {
        selectedPlace = place

        if let lat = place.latitude, let lng = place.longitude {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
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

    func calculateRadiusKm() -> Double {
        let latDelta = currentRegion.span.latitudeDelta
        let radiusKm = latDelta * 111 / 2
        return min(max(radiusKm, 1), 50)
    }
}
