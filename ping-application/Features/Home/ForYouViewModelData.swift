//
//  ForYouViewModel+Data.swift
//  PingNative
//
//  Data fetching and filtering for ForYou feed
//

import Foundation
import CoreLocation

extension ForYouViewModel {

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

    func sortPlaces(_ places: [Place], by sortOption: SortOption) -> [Place] {
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

    func distanceToPlace(_ place: Place, from userLoc: CLLocationCoordinate2D) -> Double {
        guard let lat = place.latitude, let lng = place.longitude else {
            return Double.infinity
        }
        let placeLocation = CLLocation(latitude: lat, longitude: lng)
        let userCLLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        return userCLLocation.distance(from: placeLocation)
    }

    func fetchData(userId: String, categoryPreferences: [String: [String]]? = nil, isRefresh: Bool = false, filters: PlaceFilters = PlaceFilters()) async {
        guard let placesService = placesService else {
            errorMessage = "Places service not configured"
            return
        }

        if !isRefresh && isFetchingData {
            return
        }

        if !isRefresh && !contentData.isEmpty {
            return
        }

        isFetchingData = true

        if isRefresh {
            refreshing = true
        } else {
            loading = true
        }

        updateUserLocation()

        do {
            let preferences = categoryPreferences ?? getDefaultPreferences()
            let excludeIds = Array(likedPlaces)

            #if DEBUG
            print("🏠 ForYou: Fetching places with preferences:")
            for (category, subcategories) in preferences {
                print("   - \(category): \(subcategories)")
            }
            if preferences.isEmpty {
                print("   - (empty - using default)")
            }
            #endif

            let places = try await placesService.fetchPlaces(
                categoryPreferences: preferences,
                excludeIds: excludeIds,
                limit: 50
            )

            #if DEBUG
            print("🏠 ForYou: Fetched \(places.count) places")
            for place in places.prefix(5) {
                print("   - \(place.name): \(place.category ?? "nil") / \(place.subcategory ?? "nil")")
            }
            #endif

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

        } catch is CancellationError {
            #if DEBUG
            print("🏠 ForYou: Task was cancelled (view changed)")
            #endif
            // Don't reset loading state when cancelled - keep showing loading
            // so empty state doesn't flash. The retry will complete the load.
            isFetchingData = false
            return
        } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
            #if DEBUG
            print("🏠 ForYou: Network request was cancelled (view changed)")
            #endif
            // Don't reset loading state when cancelled - keep showing loading
            isFetchingData = false
            return
        } catch {
            #if DEBUG
            print("🏠 ForYou ERROR: \(error)")
            #endif
            errorMessage = error.localizedDescription
        }

        loading = false
        refreshing = false
        isFetchingData = false
    }
}
