//
//  OnboardingData.swift
//  PingNative
//
//  Source: ping/apps/src/screens/auth/onboarding/data.ts (implied)
//  Category and subcategory data structures
//

import Foundation

struct OnboardingData {
    static let categories: [Category] = [
        Category(
            id: "food-drink",
            name: "Food & Drink",
            icon: "🍔",
            color: "#FF6B6B",
            gradient: ["#FF6B6B", "#FF5252"],
            description: "Discover amazing restaurants and cafes",
            subcategories: [
                Subcategory(name: "Fast Food", icon: "🍟", value: "fast_food"),
                Subcategory(name: "Seafood", icon: "🦞", value: "seafood"),
                Subcategory(name: "Desserts", icon: "🍰", value: "desserts"),
                Subcategory(name: "Vegan", icon: "🥗", value: "vegan"),
                Subcategory(name: "Japanese", icon: "🍣", value: "japanese"),
                Subcategory(name: "Chinese", icon: "🥡", value: "chinese"),
                Subcategory(name: "Italian", icon: "🍝", value: "italian"),
                Subcategory(name: "Mexican", icon: "🌮", value: "mexican"),
            ]
        ),
        Category(
            id: "shopping-markets",
            name: "Shopping & Markets",
            icon: "🛍️",
            color: "#4ECDC4",
            gradient: ["#4ECDC4", "#44A08D"],
            description: "Find the best shopping spots",
            subcategories: [
                Subcategory(name: "Malls", icon: "🏬", value: "malls"),
                Subcategory(name: "Boutiques", icon: "👗", value: "boutiques"),
                Subcategory(name: "Farmers Markets", icon: "🥕", value: "farmers_markets"),
                Subcategory(name: "Thrift", icon: "👕", value: "thrift"),
            ]
        ),
        Category(
            id: "creative-arts",
            name: "Creative Arts & Crafts",
            icon: "🎨",
            color: "#45B7D1",
            gradient: ["#45B7D1", "#3498DB"],
            description: "Explore your creative side",
            subcategories: [
                Subcategory(name: "Painting", icon: "🖌️", value: "painting"),
                Subcategory(name: "Pottery", icon: "🏺", value: "pottery"),
                Subcategory(name: "DIY", icon: "🔨", value: "diy"),
                Subcategory(name: "Photography", icon: "📸", value: "photography"),
            ]
        ),
        Category(
            id: "social-nightlife",
            name: "Social & Nightlife",
            icon: "🍻",
            color: "#96CEB4",
            gradient: ["#96CEB4", "#7FB3A3"],
            description: "Connect and have fun",
            subcategories: [
                Subcategory(name: "Bars", icon: "🍺", value: "bars"),
                Subcategory(name: "Clubs", icon: "🎵", value: "clubs"),
                Subcategory(name: "Karaoke", icon: "🎤", value: "karaoke"),
                Subcategory(name: "Lounges", icon: "🥂", value: "lounges"),
            ]
        ),
        Category(
            id: "recreation-fitness",
            name: "Recreation & Fitness",
            icon: "💪",
            color: "#FFEAA7",
            gradient: ["#FFEAA7", "#FDCB6E"],
            description: "Stay active and healthy",
            subcategories: [
                Subcategory(name: "Gym", icon: "🏋️", value: "gym"),
                Subcategory(name: "Yoga", icon: "🧘", value: "yoga"),
                Subcategory(name: "Sports", icon: "⚽", value: "sports"),
                Subcategory(name: "Swimming", icon: "🏊", value: "swimming"),
            ]
        ),
        Category(
            id: "nature-outdoors",
            name: "Nature & Outdoors",
            icon: "🌲",
            color: "#DDA0DD",
            gradient: ["#DDA0DD", "#C77DFF"],
            description: "Explore the great outdoors",
            subcategories: [
                Subcategory(name: "Hiking", icon: "🥾", value: "hiking"),
                Subcategory(name: "Parks", icon: "🌳", value: "parks"),
                Subcategory(name: "Lakes", icon: "🏞️", value: "lakes"),
                Subcategory(name: "Camping", icon: "⛺", value: "camping"),
            ]
        ),
        Category(
            id: "indoor-adventure",
            name: "Indoor Adventure",
            icon: "🎯",
            color: "#FFB347",
            gradient: ["#FFB347", "#FF9500"],
            description: "Fun activities indoors",
            subcategories: [
                Subcategory(name: "Escape Rooms", icon: "🔐", value: "escape_rooms"),
                Subcategory(name: "Bowling", icon: "🎳", value: "bowling"),
                Subcategory(name: "Arcades", icon: "🕹️", value: "arcades"),
                Subcategory(name: "Laser Tag", icon: "🔫", value: "laser_tag"),
            ]
        ),
        Category(
            id: "sight-seeing",
            name: "Sight-Seeing",
            icon: "🗺️",
            color: "#98D8C8",
            gradient: ["#98D8C8", "#7BC4A4"],
            description: "Discover landmarks and attractions",
            subcategories: [
                Subcategory(name: "Museums", icon: "🏛️", value: "museums"),
                Subcategory(name: "Landmarks", icon: "🗽", value: "landmarks"),
                Subcategory(name: "Architecture", icon: "🏗️", value: "architecture"),
                Subcategory(name: "Historical Sites", icon: "🏰", value: "historical_sites"),
            ]
        ),
    ]
}

struct Category: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: String
    let gradient: [String]
    let description: String
    let subcategories: [Subcategory]
}

struct Subcategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let value: String
    var subSubcategories: [SubSubcategory]? = nil
}

struct SubSubcategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let value: String?
    let price: String?
}
