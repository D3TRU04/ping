//
//  DiscoverCategoryFilter.swift
//  PingNative
//
//  Category filtering logic for Discover screen
//

import Foundation

struct DiscoverCategoryFilter {
    static let categoryKeywords: [String: [String]] = [
        "food_drink": [
            "food", "restaurant", "cafe", "coffee", "dining", "bakery", "fast_food",
            "seafood", "dessert", "vegan", "japanese", "chinese", "italian", "mexican",
            "pizza", "burger", "sushi", "thai", "indian", "korean", "vietnamese",
            "greek", "french", "american", "asian", "european", "breakfast", "brunch",
            "lunch", "dinner", "bistro", "diner", "eatery", "grill", "steakhouse",
            "bbq", "noodle", "ramen", "pho", "taco", "burrito"
        ],
        "shopping": [
            "shop", "store", "mall", "market", "boutique", "retail", "thrift",
            "grocery", "supermarket", "convenience", "outlet", "plaza", "center", "department"
        ],
        "social_nightlife": [
            "bar", "club", "nightlife", "lounge", "karaoke", "pub", "nightclub",
            "brewery", "winery", "cocktail", "tavern", "saloon", "speakeasy", "rooftop"
        ],
        "nature_outdoors": [
            "park", "nature", "outdoor", "hiking", "lake", "camping", "garden",
            "trail", "beach", "mountain", "forest", "reserve", "wildlife", "botanical",
            "scenic", "waterfall", "river", "ocean", "coast"
        ],
        "recreation_fitness": [
            "gym", "fitness", "sport", "yoga", "swimming", "recreation", "athletic",
            "tennis", "golf", "basketball", "soccer", "football", "baseball", "climbing",
            "cycling", "running", "crossfit", "pilates", "martial", "boxing", "wellness",
            "spa", "pool"
        ],
        "creative_arts": [
            "art", "gallery", "craft", "painting", "pottery", "photography", "studio",
            "theater", "theatre", "cinema", "movie", "concert", "music", "dance",
            "performance", "exhibit", "creative", "design", "sculpture"
        ],
        "indoor_adventure": [
            "arcade", "bowling", "escape", "laser", "entertainment", "game", "amusement",
            "trampoline", "minigolf", "mini golf", "go kart", "karting", "axe throwing",
            "virtual reality", "vr", "fun", "play", "activity"
        ],
        "sight_seeing": [
            "landmark", "monument", "historical", "tourist", "attraction", "architecture",
            "museum", "heritage", "memorial", "statue", "tower", "castle", "palace",
            "cathedral", "church", "temple", "shrine", "ruins", "ancient", "historic",
            "cultural", "observatory", "viewpoint", "lookout"
        ]
    ]

    static func filter(places: [Place], by category: String) -> [Place] {
        if category == "all" {
            return places
        }

        let keywords = categoryKeywords[category] ?? [category]

        return places.filter { place in
            let placeCategory = place.category?.lowercased() ?? ""
            let placeSubcategory = place.subcategory?.lowercased() ?? ""
            let placeName = place.name.lowercased()

            return keywords.contains { keyword in
                placeCategory.contains(keyword) ||
                placeSubcategory.contains(keyword) ||
                placeName.contains(keyword)
            }
        }
    }

    static func getDefaultPreferences() -> [String: [String]] {
        return [
            "food_drink": ["Restaurants", "Cafes", "Bars", "Coffee"],
            "social_nightlife": ["Bars", "Clubs", "Lounges"],
            "nature_outdoors": ["Parks", "Hiking", "Lakes"],
            "shopping": ["Malls", "Boutiques", "Markets"]
        ]
    }
}
