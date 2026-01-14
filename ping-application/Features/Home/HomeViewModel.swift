//
//  HomeViewModel.swift
//  PingNative
//
//  Connected to Convex database for places
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var places: [Place] = []
    @Published var currentIndex: Int = 0
    @Published var excludedPlaceIds: [String] = []
    
    private var placesService: PlacesService?
    private var currentUserId: String?
    
    func configure(placesService: PlacesService, userId: String?) {
        self.placesService = placesService
        self.currentUserId = userId
    }
    
    func load(categoryPreferences: [String: [String]]? = nil) async {
        guard let placesService = placesService else {
            errorMessage = "Places service not configured"
            return
        }
        
        isLoading = true
        errorMessage = nil

        do {
            // Use default preferences if none provided
            let preferences = categoryPreferences ?? getDefaultPreferences()
            
            let fetchedPlaces = try await placesService.fetchPlaces(
                categoryPreferences: preferences,
                excludeIds: excludedPlaceIds,
                limit: 50
            )
            
            self.places = fetchedPlaces
            self.currentIndex = 0
            
        } catch {
            print("❌ Error loading places: \(error)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func refresh() async {
        excludedPlaceIds = []
        await load()
    }
    
    func skipPlace(_ place: Place) {
        excludedPlaceIds.append(place.id)
        if currentIndex < places.count - 1 {
            currentIndex += 1
        }
    }
    
    func likePlace(_ place: Place) async {
        guard let placesService = placesService, let userId = currentUserId else { return }
        
        do {
            // Record the visit/like in Convex
            _ = try await placesService.recordPlaceVisit(userId: userId, placeId: place.id)
            
            // Move to next place
            if currentIndex < places.count - 1 {
                currentIndex += 1
            }
        } catch {
            print("❌ Error recording place visit: \(error)")
        }
    }
    
    var currentPlace: Place? {
        guard currentIndex < places.count else { return nil }
        return places[currentIndex]
    }
    
    var hasMorePlaces: Bool {
        currentIndex < places.count
    }
    
    private func getDefaultPreferences() -> [String: [String]] {
        // Default category preferences for "For You" feed
        return [
            "Food & Drink": ["Restaurants", "Cafes", "Bars"],
            "Entertainment": ["Movies", "Music", "Games"],
            "Outdoors": ["Parks", "Hiking", "Beaches"]
        ]
    }
}
