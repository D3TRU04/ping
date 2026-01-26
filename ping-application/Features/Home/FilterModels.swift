//
//  FilterModels.swift
//  PingNative
//
//  Filter types and models for the ForYou feed
//

import Foundation

// MARK: - Sort Option
enum SortOption: String, CaseIterable, Identifiable {
    case defaultSort = "Default"
    case ratingHighToLow = "Highest Rated"
    case ratingLowToHigh = "Lowest Rated"
    case nearest = "Nearest"
    case farthest = "Farthest"
    case priceHighToLow = "Price: High to Low"
    case priceLowToHigh = "Price: Low to High"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .defaultSort: return "sparkles"
        case .ratingHighToLow, .ratingLowToHigh: return "star.fill"
        case .nearest, .farthest: return "location.fill"
        case .priceHighToLow, .priceLowToHigh: return "dollarsign.circle.fill"
        }
    }
}

// MARK: - Rating Filter
enum RatingFilter: String, CaseIterable, Identifiable {
    case any = "Any"
    case threeAndUp = "3+ Stars"
    case fourAndUp = "4+ Stars"
    case fourFiveAndUp = "4.5+ Stars"

    var id: String { rawValue }

    var minRating: Double {
        switch self {
        case .any: return 0
        case .threeAndUp: return 3.0
        case .fourAndUp: return 4.0
        case .fourFiveAndUp: return 4.5
        }
    }
}

// MARK: - Price Filter
enum PriceFilter: String, CaseIterable, Identifiable {
    case any = "Any"
    case budget = "$"
    case moderate = "$$"
    case upscale = "$$$"
    case fine = "$$$$"

    var id: String { rawValue }

    var maxPrice: Int? {
        switch self {
        case .any: return nil
        case .budget: return 1
        case .moderate: return 2
        case .upscale: return 3
        case .fine: return 4
        }
    }
}

// MARK: - Place Filters
struct PlaceFilters {
    var sortBy: SortOption = .defaultSort
    var minRating: RatingFilter = .any
    var maxPrice: PriceFilter = .any

    var isActive: Bool {
        sortBy != .defaultSort || minRating != .any || maxPrice != .any
    }

    mutating func reset() {
        sortBy = .defaultSort
        minRating = .any
        maxPrice = .any
    }
}
