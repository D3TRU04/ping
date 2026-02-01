//
//  InfoSectionGradients.swift
//  PingNative
//
//  Category gradient helper for InfoSection
//

import SwiftUI

func getSubcategoryGradient(_ name: String) -> [Color] {
    let lowerName = name.lowercased()

    // Semantic mapping for common themes
    if lowerName.contains("coffee") || lowerName.contains("cafe") || lowerName.contains("bakery") || lowerName.contains("bread") || lowerName.contains("waffle") || lowerName.contains("crepe") || lowerName.contains("breakfast") {
        return [Color(hex: "E2D1C3"), Color(hex: "CDB4A6")]
    } else if lowerName.contains("salad") || lowerName.contains("vegan") || lowerName.contains("vegetarian") || lowerName.contains("park") || lowerName.contains("nature") || lowerName.contains("hike") {
        return [Color(hex: "A8E6CF"), Color(hex: "88D8B0")]
    } else if lowerName.contains("ocean") || lowerName.contains("sea") || lowerName.contains("water") || lowerName.contains("pool") || lowerName.contains("swim") {
        return [Color(hex: "A1C4FD"), Color(hex: "8AB6F9")]
    } else if lowerName.contains("pizza") || lowerName.contains("burger") || lowerName.contains("fast food") || lowerName.contains("taco") {
        return [Color(hex: "FAD390"), Color(hex: "F6B93B")]
    } else if lowerName.contains("dessert") || lowerName.contains("ice cream") || lowerName.contains("cake") || lowerName.contains("sweet") || lowerName.contains("donut") {
        return [Color(hex: "F8A5C2"), Color(hex: "F78FB3")]
    } else if lowerName.contains("bar") || lowerName.contains("wine") || lowerName.contains("beer") || lowerName.contains("cocktail") || lowerName.contains("night") {
        return [Color(hex: "D6A2E8"), Color(hex: "B39CD0")]
    } else if lowerName.contains("sushi") || lowerName.contains("japanese") || lowerName.contains("seafood") {
        return [Color(hex: "FFBE76"), Color(hex: "FFA502")]
    }

    // Fallback deterministic selection
    let sum = name.utf8.reduce(0) { $0 + Int($1) }
    let index = sum % 8

    switch index {
    case 0:
        return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
    case 1:
        return [Color(hex: "74B9FF"), Color(hex: "0984E3")]
    case 2:
        return [Color(hex: "A29BFE"), Color(hex: "6C5CE7")]
    case 3:
        return [Color(hex: "FAB1A0"), Color(hex: "E17055")]
    case 4:
        return [Color(hex: "B2BEC3"), Color(hex: "636E72")]
    case 5:
        return [Color(hex: "FD79A8"), Color(hex: "E84393")]
    case 6:
        return [Color(hex: "E0C3FC"), Color(hex: "8EC5FC")]
    case 7:
        return [Color(hex: "55EFC4"), Color(hex: "00B894")]
    default:
        return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
    }
}
