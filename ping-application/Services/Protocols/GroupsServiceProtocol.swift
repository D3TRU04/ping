//
//  GroupsServiceProtocol.swift
//  PingNative
//
//  Protocol and types for groups service
//

import Foundation

protocol GroupsServiceProtocol {
    func getUserGroups(userId: String) async throws -> [GroupsService.Group]
    func getGroupDetails(groupId: String) async throws -> GroupsService.GroupDetails
    func getGroupCommonPlaces(groupId: String, placeType: PlaceType) async throws -> [GroupsService.CommonPlace]
    func createGroup(ownerId: String, name: String, memberIds: [String]) async throws -> String
    func addMember(groupId: String, userId: String, requesterId: String) async throws -> String
    func removeMember(groupId: String, userId: String, requesterId: String) async throws
    func deleteGroup(groupId: String, userId: String) async throws
    func updateGroup(groupId: String, userId: String, name: String) async throws
}

// MARK: - Groups Service Types

enum PlaceType {
    case saved
    case visited
}

enum GroupsService {
    struct Group: Identifiable {
        let id: String
        let name: String
        let createdBy: String
        let createdAt: Double
        let memberCount: Int?
    }

    struct GroupDetails: Identifiable {
        let id: String
        let name: String
        let createdBy: String
        let createdAt: Double
        let owner: GroupOwner?
        let members: [GroupMember]
    }

    struct GroupOwner {
        let id: String
        let username: String?
        let fullName: String?
        let profilePicture: String?
    }

    struct GroupMember: Identifiable {
        let id: String
        let username: String?
        let fullName: String?
        let profilePicture: String?
        let role: String?
        let joinedAt: Double
    }

    struct CommonPlace: Identifiable {
        let id: String
        let name: String
        let category: String
        let subcategory: String?
        let location: String
        let lat: Double
        let lng: Double
        let rating: Double?
        let imageUrl: String?
    }
}
