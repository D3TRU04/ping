//
//  GroupsService.swift
//  PingNative
//
//  Groups service for Convex integration
//

import Foundation

class GroupsService {
    private let convexClient: ConvexClient

    init(convexClient: ConvexClient) {
        self.convexClient = convexClient
    }

    // MARK: - Group Models

    struct Group: Codable, Identifiable {
        let id: String
        let name: String
        let createdBy: String
        let createdAt: Double
        let memberCount: Int?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case createdBy
            case createdAt
            case memberCount
        }
    }

    struct GroupMember: Codable, Identifiable {
        let id: String
        let username: String?
        let fullName: String?
        let profilePicture: String?
        let role: String?
        let joinedAt: Double?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case username
            case fullName
            case profilePicture
            case role
            case joinedAt
        }
    }

    struct GroupOwner: Codable, Identifiable {
        let id: String
        let username: String?
        let fullName: String?
        let profilePicture: String?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case username
            case fullName
            case profilePicture
        }
    }

    struct GroupDetails: Codable, Identifiable {
        let id: String
        let name: String
        let createdBy: String
        let createdAt: Double
        let owner: GroupOwner?
        let members: [GroupMember]

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case createdBy
            case createdAt
            case owner
            case members
        }
    }

    struct CommonPlace: Codable, Identifiable {
        let id: String
        let name: String
        let category: String
        let subcategory: String?
        let location: String
        let lat: Double
        let lng: Double
        let rating: Double?
        let imageUrl: String?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case category
            case subcategory
            case location
            case lat
            case lng
            case rating
            case imageUrl
        }
    }

    // MARK: - Queries

    func getUserGroups(userId: String) async throws -> [Group] {
        let groups: [Group] = try await convexClient.query(
            function: "groups:getUserGroups",
            args: ["userId": userId]
        )
        return groups
    }

    func getGroupDetails(groupId: String) async throws -> GroupDetails {
        let details: GroupDetails = try await convexClient.query(
            function: "groups:getGroupDetails",
            args: ["groupId": groupId]
        )
        return details
    }

    func getGroupCommonPlaces(groupId: String, placeType: PlaceType) async throws -> [CommonPlace] {
        let places: [CommonPlace] = try await convexClient.query(
            function: "groups:getGroupCommonPlaces",
            args: [
                "groupId": groupId,
                "placeType": placeType.rawValue
            ]
        )
        return places
    }

    // MARK: - Mutations

    func createGroup(ownerId: String, name: String, memberIds: [String]) async throws -> String {
        let groupId: String = try await convexClient.mutation(
            function: "groups:createGroup",
            args: [
                "ownerId": ownerId,
                "name": name,
                "memberIds": memberIds
            ]
        )
        return groupId
    }

    func addMember(groupId: String, userId: String, requesterId: String) async throws -> String {
        let membershipId: String = try await convexClient.mutation(
            function: "groups:addMember",
            args: [
                "groupId": groupId,
                "userId": userId,
                "requesterId": requesterId
            ]
        )
        return membershipId
    }

    func removeMember(groupId: String, userId: String, requesterId: String) async throws {
        struct Result: Codable {
            let success: Bool
        }

        let _: Result = try await convexClient.mutation(
            function: "groups:removeMember",
            args: [
                "groupId": groupId,
                "userId": userId,
                "requesterId": requesterId
            ]
        )
    }

    func deleteGroup(groupId: String, userId: String) async throws {
        struct Result: Codable {
            let success: Bool
        }

        let _: Result = try await convexClient.mutation(
            function: "groups:deleteGroup",
            args: [
                "groupId": groupId,
                "userId": userId
            ]
        )
    }

    func updateGroup(groupId: String, userId: String, name: String) async throws {
        struct Result: Codable {
            let success: Bool
        }

        let _: Result = try await convexClient.mutation(
            function: "groups:updateGroup",
            args: [
                "groupId": groupId,
                "userId": userId,
                "name": name
            ]
        )
    }

    // MARK: - Place Type Enum

    enum PlaceType: String {
        case saved = "saved"     // Want to Try places
        case been = "been"       // Been/visited places
    }
}
