//
//  TodayViewModel+GameRounds.swift
//  PingNative
//
//  Game round generation and preview logic for Today feed
//

import Foundation

extension TodayViewModel {

    // MARK: - Game Round Generation

    func generateGameRounds() async {
        if matchmakingComplete {
            return
        }

        guard let placesService = placesService else {
            errorMessage = "Service not configured"
            return
        }

        loading = true

        do {
            let allPlaces = try await placesService.getAllPlaces(limit: 100)

            usedPlaceIds.removeAll()
            allFetchedPlaces = allPlaces

            guard allPlaces.count >= 2 else {
                matchmakingComplete = true
                loading = false
                return
            }

            var seenIds = Set<String>()
            let uniquePlaces = allPlaces.filter { place in
                if seenIds.contains(place.id) {
                    return false
                }
                seenIds.insert(place.id)
                return true
            }
            let shuffled = uniquePlaces.shuffled()

            var rounds: [GameRound] = []
            var index = 0

            let maxRounds = min(10, shuffled.count / 2)
            while rounds.count < maxRounds && index + 1 < shuffled.count {
                let placeA = shuffled[index]
                let placeB = shuffled[index + 1]

                usedPlaceIds.insert(placeA.id)
                usedPlaceIds.insert(placeB.id)

                rounds.append(GameRound(
                    optionA: mapToOption(placeA),
                    optionB: mapToOption(placeB)
                ))

                index += 2
            }

            let availableForPreview = uniquePlaces.filter { !usedPlaceIds.contains($0.id) }
            previewPlaces = Array(availableForPreview.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))

            if rounds.isEmpty {
                matchmakingComplete = true
            } else {
                gameRounds = rounds
            }
        } catch {
            matchmakingComplete = true
        }

        loading = false
    }

    func generateAdditionalRounds(count: Int = 5) async -> [GameRound] {
        let availablePlaces = allFetchedPlaces.filter { !usedPlaceIds.contains($0.id) }

        guard availablePlaces.count >= 2 else {
            return []
        }

        let shuffled = availablePlaces.shuffled()
        var newRounds: [GameRound] = []
        var index = 0

        let maxNewRounds = min(count, shuffled.count / 2)
        while newRounds.count < maxNewRounds && index + 1 < shuffled.count {
            let placeA = shuffled[index]
            let placeB = shuffled[index + 1]

            usedPlaceIds.insert(placeA.id)
            usedPlaceIds.insert(placeB.id)

            newRounds.append(GameRound(
                optionA: mapToOption(placeA),
                optionB: mapToOption(placeB)
            ))

            index += 2
        }

        recalculatePreviewPlaces()
        return newRounds
    }

    // MARK: - Preview Places

    func getPreviewPlaces(for themes: [String]) -> [Place] {
        selectedThemes = themes

        let availablePlaces = allFetchedPlaces.filter { !usedPlaceIds.contains($0.id) }

        guard !availablePlaces.isEmpty else {
            let result = Array(allFetchedPlaces.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))
            previewPlaces = result
            return result
        }

        guard !themes.isEmpty else {
            let result = Array(availablePlaces.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))
            previewPlaces = result
            return result
        }

        let scored = scorePlacesByThemes(availablePlaces, themes: themes)
        let result = Array(scored.prefix(5))
        previewPlaces = result
        return result
    }

    func recalculatePreviewPlaces() {
        let availablePlaces = allFetchedPlaces.filter { !usedPlaceIds.contains($0.id) }

        guard !availablePlaces.isEmpty else {
            previewPlaces = Array(allFetchedPlaces.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))
            return
        }

        guard !selectedThemes.isEmpty else {
            previewPlaces = Array(availablePlaces.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }.prefix(5))
            return
        }

        previewPlaces = Array(scorePlacesByThemes(availablePlaces, themes: selectedThemes).prefix(5))
    }

    // MARK: - Helpers

    func mapToOption(_ place: Place) -> PlaceOption {
        let category = place.category ?? "General"
        let subcategory = place.subcategory ?? category

        return PlaceOption(
            name: place.name,
            description: place.description ?? "Discover this place",
            category: category,
            subcategory: subcategory,
            priceRange: place.priceRange
        )
    }

    func scorePlacesByThemes(_ places: [Place], themes: [String]) -> [Place] {
        var themeCounts: [String: Int] = [:]
        for theme in themes {
            themeCounts[theme, default: 0] += 1
        }

        let scoredPlaces = places.map { place -> (Place, Int) in
            let subcategory = place.subcategory ?? place.category ?? ""
            let score = themeCounts[subcategory] ?? 0
            return (place, score)
        }

        let sorted = scoredPlaces.sorted { a, b in
            if a.1 != b.1 {
                return a.1 > b.1
            }
            return (a.0.rating ?? 0) > (b.0.rating ?? 0)
        }

        return sorted.map { $0.0 }
    }
}
