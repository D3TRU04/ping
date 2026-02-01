//
//  PlacesServiceProtocol.swift
//  PingNative
//
//  Protocol definition for places service
//

import Foundation

protocol PlacesServiceProtocol {
    func fetchPlaces(categoryPreferences: [String: [String]], excludeIds: [String], limit: Int?) async throws -> [Place]
    func searchPlaces(query: String, limit: Int) async throws -> [Place]
    func getAllPlaces(limit: Int) async throws -> [Place]
    func fetchPlaceDetails(placeId: String) async throws -> Place?
    func getUserVisitedPlaces(userId: String, limit: Int) async throws -> [PlaceVisit]
    func recordPlaceVisit(userId: String, placeId: String) async throws -> String
    func removePlaceVisit(userId: String, placeId: String) async throws
    func hasVisitedPlace(userId: String, placeId: String) async throws -> Bool
    func getNearbyPlaces(latitude: Double, longitude: Double, radiusKm: Double, limit: Int) async throws -> [PlaceWithDistance]
}
