//
//  DiscoverViewModel+Search.swift
//  PingNative
//
//  Search and filtering logic for discover view model
//

import Foundation
import MapKit

extension DiscoverViewModel {

    func load(forceReload: Bool = false) async {
        if hasLoadedPlaces && !forceReload {
            print("Places already loaded, skipping reload")
            return
        }

        loading = true
        errorMessage = nil

        if !hasInitializedLocation {
            await initializeUserLocation()
            hasInitializedLocation = true
        }

        print("Loading places for region: \(currentRegion.center.latitude), \(currentRegion.center.longitude)")

        let preferences = transformedPreferences ?? getDefaultPreferences()
        print("Using preferences: \(preferences.keys.joined(separator: ", "))")

        if let placesService = placesService {
            do {
                let filteredByPreferences = try await placesService.fetchPlaces(
                    categoryPreferences: preferences,
                    excludeIds: [],
                    limit: 100
                )

                self.places = filteredByPreferences
                self.filteredPlaces = self.places

                print("Loaded \(self.places.count) places matching preferences")

                if self.places.isEmpty {
                    print("No places match preferences, trying nearby places...")
                    let radius = max(calculateRadiusKm(), 100)
                    let nearbyPlaces = try await placesService.getNearbyPlaces(
                        latitude: currentRegion.center.latitude,
                        longitude: currentRegion.center.longitude,
                        radiusKm: radius,
                        limit: 100
                    )
                    self.places = nearbyPlaces.map { $0.place }
                    self.filteredPlaces = self.places
                    print("Loaded \(self.places.count) nearby places as fallback")
                }

                for place in self.places.prefix(5) {
                    print("   - \(place.name): lat=\(place.latitude ?? 0), lng=\(place.longitude ?? 0), category=\(place.category ?? "none")")
                }

                hasLoadedPlaces = true

            } catch {
                print("Error loading places: \(error)")
                errorMessage = error.localizedDescription
            }
        } else {
            print("Places service not configured")
        }

        loading = false
    }

    func refresh() async {
        refreshing = true
        await load(forceReload: true)
        refreshing = false
    }

    func performSearch(query: String) async {
        if query.isEmpty {
            filteredPlaces = places
            userResults = []
            return
        }

        loading = true

        switch searchMode {
        case .places:
            await searchPlaces(query: query)
        case .users:
            await searchUsers(query: query)
        }

        loading = false
    }

    private func searchPlaces(query: String) async {
        guard let placesService = placesService else { return }

        do {
            let searchResults = try await placesService.searchPlaces(query: query, limit: 50)
            self.filteredPlaces = searchResults
        } catch {
            print("Error searching places: \(error)")
            filteredPlaces = places.filter { place in
                place.name.localizedCaseInsensitiveContains(query) ||
                (place.category?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }
    }

    private func searchUsers(query: String) async {
        guard let profileService = profileService else { return }

        do {
            let results = try await profileService.searchUsers(query: query, limit: 50)
            self.userResults = results
        } catch {
            print("Error searching users: \(error)")
            self.userResults = []
        }
    }

    func filterByCategory(_ category: String) {
        activeTab = category

        if category == "all" {
            filteredPlaces = places
            print("Filter: showing all \(places.count) places")
            return
        }

        let categoryKeywords: [String: [String]] = [
            "food_drink": ["food", "restaurant", "cafe", "coffee", "dining", "bakery", "fast_food", "seafood", "dessert", "vegan", "japanese", "chinese", "italian", "mexican", "pizza", "burger", "sushi", "thai", "indian", "korean", "vietnamese", "greek", "french", "american", "asian", "european", "breakfast", "brunch", "lunch", "dinner", "bistro", "diner", "eatery", "grill", "steakhouse", "bbq", "noodle", "ramen", "pho", "taco", "burrito"],
            "shopping": ["shop", "store", "mall", "market", "boutique", "retail", "thrift", "grocery", "supermarket", "convenience", "outlet", "plaza", "center", "department"],
            "social_nightlife": ["bar", "club", "nightlife", "lounge", "karaoke", "pub", "nightclub", "brewery", "winery", "cocktail", "tavern", "saloon", "speakeasy", "rooftop"],
            "nature_outdoors": ["park", "nature", "outdoor", "hiking", "lake", "camping", "garden", "trail", "beach", "mountain", "forest", "reserve", "wildlife", "botanical", "scenic", "waterfall", "river", "ocean", "coast"],
            "recreation_fitness": ["gym", "fitness", "sport", "yoga", "swimming", "recreation", "athletic", "tennis", "golf", "basketball", "soccer", "football", "baseball", "climbing", "cycling", "running", "crossfit", "pilates", "martial", "boxing", "wellness", "spa", "pool"],
            "creative_arts": ["art", "gallery", "craft", "painting", "pottery", "photography", "studio", "theater", "theatre", "cinema", "movie", "concert", "music", "dance", "performance", "exhibit", "creative", "design", "sculpture"],
            "indoor_adventure": ["arcade", "bowling", "escape", "laser", "entertainment", "game", "amusement", "trampoline", "minigolf", "mini golf", "go kart", "karting", "axe throwing", "virtual reality", "vr", "fun", "play", "activity"],
            "sight_seeing": ["landmark", "monument", "historical", "tourist", "attraction", "architecture", "museum", "heritage", "memorial", "statue", "tower", "castle", "palace", "cathedral", "church", "temple", "shrine", "ruins", "ancient", "historic", "cultural", "observatory", "viewpoint", "lookout"]
        ]

        let keywords = categoryKeywords[category] ?? [category]

        filteredPlaces = places.filter { place in
            let placeCategory = place.category?.lowercased() ?? ""
            let placeSubcategory = place.subcategory?.lowercased() ?? ""
            let placeName = place.name.lowercased()

            return keywords.contains { keyword in
                placeCategory.contains(keyword) ||
                placeSubcategory.contains(keyword) ||
                placeName.contains(keyword)
            }
        }

        print("Filter '\(category)': \(filteredPlaces.count) of \(places.count) places match")
    }
}
