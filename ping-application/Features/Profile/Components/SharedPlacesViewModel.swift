//
//  SharedPlacesViewModel.swift
//  PingNative
//
//  ViewModel for shared places view
//

import Foundation
import Combine

// MARK: - Shared Place Type
enum SharedPlaceType {
    case wantToTry
    case been
}

// MARK: - Shared Places ViewModel
@MainActor
class SharedPlacesViewModel: ObservableObject {
    @Published var sharedPlaces: [PlaceListItem] = []
    @Published var isLoading: Bool = false

    func loadSharedPlaces(
        currentUserId: String,
        otherUserId: String,
        placeType: SharedPlaceType,
        appEnvironment: AppEnvironment
    ) async {
        isLoading = true

        do {
            switch placeType {
            case .wantToTry:
                let mySavedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(
                    userId: currentUserId,
                    limit: 100
                )
                let theirSavedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(
                    userId: otherUserId,
                    limit: 100
                )

                let myPlaceIds = Set(mySavedPlaces.map { $0.placeId })
                let shared = theirSavedPlaces.filter { myPlaceIds.contains($0.placeId) }

                sharedPlaces = shared.compactMap { savedPlace -> PlaceListItem? in
                    guard let place = savedPlace.place else { return nil }
                    return PlaceListItem(
                        id: place.id,
                        name: place.name,
                        category: place.category,
                        subcategory: place.subcategory,
                        location: place.location,
                        imageUrl: place.imageUrl,
                        rating: place.rating,
                        hours: nil,
                        price: nil
                    )
                }

            case .been:
                let myVisitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(
                    userId: currentUserId,
                    limit: 100
                )
                let theirVisitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(
                    userId: otherUserId,
                    limit: 100
                )

                let myPlaceIds = Set(myVisitedPlaces.map { $0.placeId })
                let shared = theirVisitedPlaces.filter { myPlaceIds.contains($0.placeId) }

                sharedPlaces = shared.compactMap { visit -> PlaceListItem? in
                    guard let place = visit.place else { return nil }
                    return PlaceListItem(
                        id: place.id,
                        name: place.name,
                        category: place.category ?? "Unknown",
                        subcategory: place.subcategory,
                        location: place.address ?? "",
                        imageUrl: place.imageUrl,
                        rating: place.rating,
                        hours: place.hours,
                        price: place.priceRange
                    )
                }
            }
        } catch {
            print("Error loading shared places: \(error)")
        }

        isLoading = false
    }
}
