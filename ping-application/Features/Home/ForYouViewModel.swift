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

    private var placesService: PlacesService?
    private var collectionsService: CollectionsService?
    private var defaultCollectionId: String?
    private var allPlaces: [Place] = []
    private var userLocation: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()

    func configure(placesService: PlacesService, collectionsService: CollectionsService) {
        self.placesService = placesService
        self.collectionsService = collectionsService
        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location {
            userLocation = location.coordinate
        }
    }

    func applyFilters(_ filters: PlaceFilters) {
        var filtered = allPlaces

        if filters.minRating != .any {
            filtered = filtered.filter { ($0.rating ?? 0) >= filters.minRating.minRating }
        }

        if let maxPrice = filters.maxPrice.maxPrice {
            filtered = filtered.filter { ($0.priceRange ?? 0) <= maxPrice }
        }

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

        updateUserLocation()

        do {
            let preferences = categoryPreferences ?? getDefaultPreferences()
            let excludeIds = Array(likedPlaces)

            let places = try await placesService.fetchPlaces(
                categoryPreferences: preferences,
                excludeIds: excludeIds,
                limit: 50
            )

            self.allPlaces = places
            applyFilters(filters)

            let visitedPlaces = try await placesService.getUserVisitedPlaces(userId: userId, limit: 100)
            self.likedPlaces = Set(visitedPlaces.map { $0.placeId })

            if let collectionsService = collectionsService {
                self.defaultCollectionId = try await collectionsService.getOrCreateDefaultCollection(userId: userId)
                self.collections = try await collectionsService.getUserCollections(userId: userId)

                let saved = try await collectionsService.getUserSavedPlaces(userId: userId, limit: 100)
                self.savedPlaces = Set(saved.map { $0.placeId })

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
            print("Error fetching feed data: \(error)")
            errorMessage = error.localizedDescription
        }

        loading = false
        refreshing = false
    }

    func toggleLike(placeId: String, isLiked: Bool, userId: String) async {
        guard let placesService = placesService else { return }

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
            print("Error toggling like: \(error)")
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
                try await collectionsService.unsavePlaceFromAll(userId: userId, placeId: placeId)
            } else {
                var collectionId = defaultCollectionId
                if collectionId == nil {
                    collectionId = try await collectionsService.getOrCreateDefaultCollection(userId: userId)
                    self.defaultCollectionId = collectionId
                }
                _ = try await collectionsService.savePlace(userId: userId, placeId: placeId, collectionId: collectionId!)
            }
        } catch {
            print("Error toggling save: \(error)")
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
        return [
            "Food & Drink": ["Restaurants", "Cafes", "Bars", "Coffee"],
            "Entertainment": ["Movies", "Music", "Games", "Nightlife"],
            "Outdoors": ["Parks", "Hiking", "Beaches", "Nature"],
            "Shopping": ["Malls", "Boutiques", "Markets"]
        ]
    }
}
