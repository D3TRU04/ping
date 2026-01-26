//
//  DiscoverCategoryFilterBar.swift
//  PingNative
//
//  Category filter bar for Discover screen
//

import SwiftUI

struct DiscoverCategoryFilterBar: View {
    @Binding var activeCategory: String
    var isSatelliteMode: Bool = false
    var userSelectedCategories: [String]?
    let onCategorySelect: (String) -> Void

    private let allCategories: [(id: String, filterId: String, name: String, icon: String)] = [
        ("food-drink", "food_drink", "Food", "🍔"),
        ("shopping-markets", "shopping", "Shopping", "🛍️"),
        ("social-nightlife", "social_nightlife", "Nightlife", "🍻"),
        ("nature-outdoors", "nature_outdoors", "Nature", "🌲"),
        ("recreation-fitness", "recreation_fitness", "Fitness", "💪"),
        ("creative-arts", "creative_arts", "Arts", "🎨"),
        ("indoor-adventure", "indoor_adventure", "Adventure", "🎮"),
        ("sight-seeing", "sight_seeing", "Sights", "🏛️")
    ]

    private var displayCategories: [(id: String, filterId: String, name: String, icon: String)] {
        guard let selected = userSelectedCategories, !selected.isEmpty else {
            return allCategories
        }
        return allCategories.filter { selected.contains($0.id) }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: activeCategory == "all",
                    isSatelliteMode: isSatelliteMode
                ) {
                    onCategorySelect("all")
                }

                ForEach(displayCategories, id: \.id) { category in
                    CategoryChip(
                        title: category.name,
                        icon: category.icon,
                        isSelected: activeCategory == category.filterId,
                        isSatelliteMode: isSatelliteMode
                    ) {
                        onCategorySelect(category.filterId)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
