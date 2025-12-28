//
//  PlacesService.swift
//  PingNative
//
//  Source: ping/apps/src/screens/discover/services/ (implied)
//  Places service for fetching places from Supabase
//

import Foundation

class PlacesService {
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func fetchPlaces(
        categoryPreferences: [String: [String]],
        excludeLiked: Set<String> = [],
        excludeSaved: Set<String> = [],
        limit: Int? = nil
    ) async throws -> [Place] {
        var allPlaces: [Place] = []
        
        // Fetch places for each category/subcategory
        for (tableName, subcategories) in categoryPreferences {
            for subcategory in subcategories {
                let subcategoryColumn = "\(tableName)_subcategory"
                
                var queryParams: [String: String] = [
                    "\(subcategoryColumn)": "ilike.\(subcategory)",
                    "order": "place_id.asc"
                ]
                
                if let limit = limit {
                    queryParams["limit"] = "\(limit)"
                }
                
                let response: [PlaceResponse] = try await supabaseClient.get(
                    path: "/rest/v1/\(tableName)",
                    queryParams: queryParams,
                    responseType: [PlaceResponse].self
                )
                
                let filtered = response.filter { place in
                    !excludeLiked.contains(place.placeId) && !excludeSaved.contains(place.placeId)
                }
                
                allPlaces.append(contentsOf: filtered.map { $0.toPlace() })
            }
        }
        
        return allPlaces
    }
    
    func searchPlaces(query: String) async throws -> [Place] {
        // Search across all place tables
        // This is a simplified version - in production, you might use full-text search
        let response: [PlaceResponse] = try await supabaseClient.get(
            path: "/rest/v1/places",
            queryParams: [
                "name": "ilike.%\(query)%",
                "order": "name.asc"
            ],
            responseType: [PlaceResponse].self
        )
        
        return response.map { $0.toPlace() }
    }
    
    func fetchPlaceDetails(placeId: String) async throws -> Place? {
        // Fetch single place details
        let response: [PlaceResponse] = try await supabaseClient.get(
            path: "/rest/v1/places",
            queryParams: [
                "place_id": "eq.\(placeId)"
            ],
            responseType: [PlaceResponse].self
        )
        
        return response.first?.toPlace()
    }
}

struct PlaceResponse: Codable {
    let placeId: String
    let name: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let category: String?
    let subcategory: String?
    let rating: Double?
    let imageUrl: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case address
        case latitude
        case longitude
        case category
        case subcategory
        case imageUrl = "image_url"
        case description
        case rating
    }
    
    func toPlace() -> Place {
        Place(
            id: placeId,
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            category: category,
            subcategory: subcategory,
            rating: rating,
            imageUrl: imageUrl,
            description: description
        )
    }
}
