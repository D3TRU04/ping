//
//  TodayViewModel+FeedData.swift
//  PingNative
//
//  Feed data fetching logic for Today feed
//

import Foundation

extension TodayViewModel {

    func fetchData(userId: String, isRefresh: Bool = false) async {
        guard let placesService = placesService else {
            errorMessage = "Places service not configured"
            return
        }

        if !isRefresh && isFetchingData {
            return
        }

        if !isRefresh && !todayFeedItems.isEmpty {
            return
        }

        isFetchingData = true

        if isRefresh {
            refreshing = true
        } else {
            loading = true
        }

        do {
            try Task.checkCancellation()

            var places = try await placesService.getAllPlaces(limit: 50)

            if places.count > 10 {
                let filtered = places.filter { !recentlyShownSet.contains($0.id) }
                if filtered.count >= 5 {
                    places = filtered
                }
            }

            try Task.checkCancellation()

            if !selectedThemes.isEmpty && !isRefresh {
                todayFeedItems = scorePlacesByThemes(places, themes: selectedThemes)
            } else {
                todayFeedItems = places.shuffled()
            }

            for place in todayFeedItems {
                recentlyShownSet.insert(place.id)
            }
            saveRecentlyShown()

            await fetchUserPlaceData(userId: userId, placesService: placesService)

        } catch is CancellationError {
            // Expected behavior when view changes
        } catch {
            if todayFeedItems.isEmpty {
                await handleFetchError(placesService: placesService)
            }
        }

        loading = false
        refreshing = false
        isFetchingData = false
    }

    private func fetchUserPlaceData(userId: String, placesService: PlacesServiceProtocol) async {
        async let visitedPlacesTask = placesService.getUserVisitedPlaces(userId: userId, limit: 100)

        var savedPlacesResult: [CollectionsService.SavedPlace] = []
        var defaultColId: String? = nil

        if let collectionsService = collectionsService {
            do {
                async let defaultCollectionTask = collectionsService.getOrCreateDefaultCollection(userId: userId)
                async let savedPlacesTask = collectionsService.getUserSavedPlaces(userId: userId, limit: 100)

                defaultColId = try await defaultCollectionTask
                savedPlacesResult = try await savedPlacesTask
            } catch {
                // Don't fail the whole fetch if collections fail
            }
        }

        do {
            let visitedPlaces = try await visitedPlacesTask
            likedPlaces = Set(visitedPlaces.map { $0.placeId })
        } catch {
            // Don't fail the whole fetch if visited places fail
        }

        defaultCollectionId = defaultColId
        savedPlaces = Set(savedPlacesResult.map { $0.placeId })

        var newSavedMap: [String: [String]] = [:]
        newSavedMap["all_saved"] = savedPlacesResult.map { $0.placeId }

        for savedPlace in savedPlacesResult {
            let collectionName = savedPlace.collectionName ?? "Want to Go"
            if newSavedMap[collectionName] == nil {
                newSavedMap[collectionName] = []
            }
            newSavedMap[collectionName]?.append(savedPlace.placeId)
        }
        savedMap = newSavedMap
    }

    private func handleFetchError(placesService: PlacesServiceProtocol) async {
        do {
            let fallbackPlaces = try await placesService.getAllPlaces(limit: 30)
            if !fallbackPlaces.isEmpty {
                if !selectedThemes.isEmpty {
                    todayFeedItems = scorePlacesByThemes(fallbackPlaces, themes: selectedThemes)
                } else {
                    todayFeedItems = fallbackPlaces.shuffled()
                }
            } else {
                errorMessage = "No places available. Please try again later."
            }
        } catch {
            errorMessage = "Unable to load places. Please check your connection."
        }
    }
}
