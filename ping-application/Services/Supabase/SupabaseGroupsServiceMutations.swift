//
//  SupabaseGroupsService+Mutations.swift
//  PingNative
//
//  Mutation operations for groups service
//

import Foundation

extension SupabaseGroupsService {

    func createGroup(ownerId: String, name: String, memberIds: [String]) async throws -> String {
        struct InsertResult: Decodable {
            let id: String
        }

        let group: InsertResult = try await client.insert(
            into: "groups",
            values: [
                "name": name,
                "created_by": ownerId
            ]
        )

        let _: InsertResult = try await client.insert(
            into: "group_members",
            values: [
                "group_id": group.id,
                "user_id": ownerId
            ]
        )

        for memberId in memberIds where memberId != ownerId {
            let _: InsertResult = try await client.insert(
                into: "group_members",
                values: [
                    "group_id": group.id,
                    "user_id": memberId
                ]
            )
        }

        return group.id
    }

    func addMember(groupId: String, userId: String, requesterId: String) async throws -> String {
        struct InsertResult: Decodable {
            let id: String
        }

        let result: InsertResult = try await client.insert(
            into: "group_members",
            values: [
                "group_id": groupId,
                "user_id": userId
            ]
        )

        return result.id
    }

    func removeMember(groupId: String, userId: String, requesterId: String) async throws {
        try await client.delete(
            from: "group_members",
            query: [
                "group_id": "eq.\(groupId)",
                "user_id": "eq.\(userId)"
            ]
        )
    }

    func deleteGroup(groupId: String, userId: String) async throws {
        // Delete all members first
        try await client.delete(
            from: "group_members",
            query: ["group_id": "eq.\(groupId)"]
        )

        // Delete the group
        try await client.delete(
            from: "groups",
            query: ["id": "eq.\(groupId)"]
        )
    }

    func updateGroup(groupId: String, userId: String, name: String) async throws {
        struct UpdateResult: Decodable {
            let id: String
        }

        let _: UpdateResult = try await client.update(
            table: "groups",
            values: ["name": name],
            query: ["id": "eq.\(groupId)"]
        )
    }
}
