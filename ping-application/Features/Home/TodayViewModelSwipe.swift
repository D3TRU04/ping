//
//  TodayViewModelSwipe.swift
//  PingNative
//
//  Extension for TodayViewModel handling swipe feature logic and weighted algorithm
//

import Foundation

extension TodayViewModel {

    // MARK: - Swipe Logic

    func handleSwipe(direction: SwipeDirection) {
        guard currentSwipeIndex < swipeCards.count else { return }

        let card = swipeCards[currentSwipeIndex]
        let result = SwipeResult(card: card, direction: direction)
        swipeResults.append(result)

        if direction == .right {
            interestedPlaces.append(card.place)
        }

        currentSwipeIndex += 1

        // Check if batch is complete
        if currentSwipeIndex >= swipeCards.count {
            categorySelectionStep = .preview
        }

        // Save state after each swipe
        saveCategorySelectionState()
    }

    func removeInterestedPlace(_ place: Place) {
        interestedPlaces.removeAll { $0.id == place.id }
    }

    func acceptPreview() {
        // Move interested places to the feed
        todayFeedItems = interestedPlaces
        markMatchmakingComplete()
        categorySelectionStep = .complete
        saveCategorySelectionState()
    }

    func loadMoreSwipeCards() {
        Task {
            await generateSwipeCards(count: additionalBatchSize)
            swipeBatchNumber += 1
            categorySelectionStep = .swipe
            saveCategorySelectionState()
        }
    }

    // MARK: - Swipe Card Generation

    func startSwipeFlow() async {
        await generateSwipeCards(count: firstBatchSize)
        categorySelectionStep = .swipe
        saveCategorySelectionState()
    }

    func generateSwipeCards(count: Int) async {
        guard let placesService = placesService else { return }

        do {
            // Build category preferences map from selected categories and subcategories
            var categoryPreferences: [String: [String]] = [:]
            for categoryId in selectedCategoryIds {
                // Find subcategories for this category
                if let category = OnboardingData.categories.first(where: { $0.id == categoryId }) {
                    let subcategoryValues = category.subcategories
                        .filter { selectedSubcategoryValues.contains($0.value) }
                        .map { $0.value }
                    if !subcategoryValues.isEmpty {
                        categoryPreferences[categoryId] = subcategoryValues
                    } else {
                        // If no subcategories selected for this category, include all
                        categoryPreferences[categoryId] = category.subcategories.map { $0.value }
                    }
                }
            }

            // Fetch places matching selected categories/subcategories
            let places = try await placesService.fetchPlaces(
                categoryPreferences: categoryPreferences,
                excludeIds: Array(usedPlaceIds),
                limit: count * 3 // Fetch more for weighted selection
            )

            // Apply weighted algorithm and select cards
            let weightedCards = applyWeights(to: places)
            let selectedCards = selectCards(from: weightedCards, count: count)

            await MainActor.run {
                self.swipeCards = selectedCards
                self.currentSwipeIndex = 0
                self.totalSwipesThisBatch = selectedCards.count
            }
        } catch {
            print("Error generating swipe cards: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to load places. Please try again."
            }
        }
    }

    // MARK: - Weighted Algorithm

    private func applyWeights(to places: [Place]) -> [SwipeCard] {
        places.map { place in
            var weight: Double = 1.0

            // "Been to" (likedPlaces): 80% less likely
            if likedPlaces.contains(place.id) {
                weight *= 0.2
            }

            // "Wanted to try" (savedPlaces): 2x more likely
            if savedPlaces.contains(place.id) {
                weight *= 2.0
            }

            // Matches selected subcategory: 1.5x bonus
            if let subcategory = place.subcategory,
               selectedSubcategoryValues.contains(subcategory) {
                weight *= 1.5
            }

            // Rating > 4.0: 1.2x bonus
            if let rating = place.rating, rating > 4.0 {
                weight *= 1.2
            }

            return SwipeCard(place: place, weight: weight)
        }
    }

    private func selectCards(from cards: [SwipeCard], count: Int) -> [SwipeCard] {
        var selected: [SwipeCard] = []
        var remainingCards = cards.filter { card in
            // Exclude already shown cards
            !usedPlaceIds.contains(card.id)
        }

        while selected.count < count && !remainingCards.isEmpty {
            // Calculate cumulative weights
            let totalWeight = remainingCards.reduce(0) { $0 + $1.weight }

            guard totalWeight > 0 else { break }

            // Random selection based on weight
            let random = Double.random(in: 0..<totalWeight)
            var cumulative: Double = 0

            for (index, card) in remainingCards.enumerated() {
                cumulative += card.weight
                if random < cumulative {
                    selected.append(card)
                    usedPlaceIds.insert(card.id)
                    remainingCards.remove(at: index)
                    break
                }
            }
        }

        return selected
    }

    // MARK: - Progress Calculation

    var swipeProgress: Double {
        guard !swipeCards.isEmpty else { return 0 }
        return Double(currentSwipeIndex) / Double(swipeCards.count)
    }
}
