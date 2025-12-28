//
//  Place.swift
//  PingNative
//
//  Source: ping/apps/src/types/FoodPlace.ts (implied)
//  Generated Swift model matching RN Place/FoodPlace structure
//

import Foundation
import CoreLocation

struct Place: Identifiable, Codable {
    let id: String
    let name: String
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var category: String?
    var subcategory: String?
    var subtopic: String?
    var rating: Double?
    var imageUrl: String?
    var description: String?
    var hours: [String]?
    var phone: String?
    var priceRange: Int?
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case latitude
        case longitude
        case category
        case subcategory
        case subtopic
        case rating
        case imageUrl = "image_url"
        case description
        case hours
        case phone
        case priceRange = "price_range"
    }
}
