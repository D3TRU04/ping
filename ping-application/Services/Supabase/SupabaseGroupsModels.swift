//
//  SupabaseGroupsModels.swift
//  PingNative
//
//  Model types for Supabase groups service
//  Note: No CodingKeys needed for snake_case fields - SupabaseClient uses .convertFromSnakeCase

import Foundation

struct SupabaseGroup: Codable, Identifiable {
    let id: String
    let name: String
    let createdBy: String
    let createdAt: Date

    func toGroup() -> GroupsService.Group {
        GroupsService.Group(
            id: id,
            name: name,
            createdBy: createdBy,
            createdAt: createdAt.timeIntervalSince1970 * 1000,
            memberCount: nil
        )
    }
}

struct SupabaseGroupMember: Codable, Identifiable {
    let id: String
    let groupId: String
    let userId: String
    let joinedAt: Date
    let user: UserInfo?

    // No CodingKeys needed - auto-converted from snake_case
    // user is optional and populated separately (no join)

    struct UserInfo: Codable {
        let id: String
        let username: String?
        let fullName: String?
        let profilePicture: String?
    }
}
