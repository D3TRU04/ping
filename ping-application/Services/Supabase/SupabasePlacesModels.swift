//
//  SupabasePlacesModels.swift
//  PingNative
//
//  Model types for places service
//

import Foundation

struct SupabasePlace: Decodable {
    let id: String
    let name: String
    let category: String?
    let subcategory: String?
    let location: String?
    let lat: Double?
    let lng: Double?
    let rating: Double?
    let priceRange: String?
    let hours: String?
    let description: String?
    let imageUrl: String?
    let websiteUrl: String?

    // No CodingKeys needed - SupabaseClient uses .convertFromSnakeCase
    // which auto-converts price_range → priceRange, image_url → imageUrl, etc.

    func toPlace() -> Place {
        Place(
            id: id,
            name: name,
            address: location,
            latitude: lat,
            longitude: lng,
            category: category,
            subcategory: subcategory,
            subtopic: nil,
            rating: rating,
            imageUrl: imageUrl,
            description: description,
            hours: parseHours(hours),
            phone: nil,
            priceRange: priceRange != nil ? priceRange!.count : nil
        )
    }

    private func parseHours(_ hoursString: String?) -> [String]? {
        guard let hoursString = hoursString, !hoursString.isEmpty else { return nil }

        if let data = hoursString.data(using: .utf8),
           let array = try? JSONDecoder().decode([String].self, from: data) {
            return array
        }

        if hoursString.contains("\n") {
            return hoursString.components(separatedBy: "\n")
        }

        return [hoursString]
    }
}

struct SupabaseVisit: Decodable {
    let id: String
    let userId: String
    let placeId: String
    let placeName: String
    let placeImage: String?
    let visitDate: Date
    let place: SupabasePlace?

    // Only need CodingKey for "places" -> "place" (different name)
    // All snake_case fields auto-convert via .convertFromSnakeCase
    enum CodingKeys: String, CodingKey {
        case id, userId, placeId, placeName, placeImage, visitDate
        case place = "places"
    }
}
