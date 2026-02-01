//
//  SupabaseGroupsService.swift
//  PingNative
//
//  Groups service for Supabase integration
//

import Foundation

class SupabaseGroupsService: GroupsServiceProtocol {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Queries

    func getUserGroups(userId: String) async throws -> [GroupsService.Group] {
        // Get group IDs for user without join
        struct Membership: Decodable {
            let groupId: String
        }

        let memberships: [Membership] = try await client.fetch(
            from: "group_members",
            query: ["user_id": "eq.\(userId)"],
            select: "group_id"
        )

        guard !memberships.isEmpty else { return [] }

        // Fetch groups separately
        let groupIds = memberships.map { $0.groupId }
        let groups: [SupabaseGroup] = try await client.fetch(
            from: "groups",
            query: ["id": "in.(\(groupIds.joined(separator: ",")))"]
        )

        // Get member counts for each group
        var memberCounts: [String: Int] = [:]
        for groupId in groupIds {
            struct CountMember: Decodable {
                let id: String
            }
            let members: [CountMember] = try await client.fetch(
                from: "group_members",
                query: ["group_id": "eq.\(groupId)"],
                select: "id"
            )
            memberCounts[groupId] = members.count
        }

        return groups.map { group in
            GroupsService.Group(
                id: group.id,
                name: group.name,
                createdBy: group.createdBy,
                createdAt: group.createdAt.timeIntervalSince1970 * 1000,
                memberCount: memberCounts[group.id]
            )
        }
    }

    func getGroupDetails(groupId: String) async throws -> GroupsService.GroupDetails {
        // Fetch group without user join
        let group: SupabaseGroup = try await client.fetch(
            from: "groups",
            query: ["id": "eq.\(groupId)"],
            single: true
        )

        // Fetch owner separately
        let owner: SupabaseUser? = try await client.fetchOptional(
            from: "users",
            query: ["id": "eq.\(group.createdBy)"],
            select: "id,username,full_name,profile_picture"
        )

        // Fetch members (excluding owner to avoid duplicate)
        let allMembers = try await getGroupMembersWithUsers(groupId: groupId)
        let membersWithoutOwner = allMembers.filter { $0.id != group.createdBy }

        return GroupsService.GroupDetails(
            id: group.id,
            name: group.name,
            createdBy: group.createdBy,
            createdAt: group.createdAt.timeIntervalSince1970 * 1000,
            owner: owner.map { o in
                GroupsService.GroupOwner(
                    id: o.id,
                    username: o.username,
                    fullName: o.fullName,
                    profilePicture: o.profilePicture
                )
            },
            members: membersWithoutOwner
        )
    }

    func getGroupMembers(groupId: String) async throws -> [SupabaseGroupMember] {
        // Simple fetch without user join - only select columns that exist
        struct SimpleMember: Decodable {
            let id: String
            let groupId: String
            let userId: String
            let joinedAt: Date
        }

        let members: [SimpleMember] = try await client.fetch(
            from: "group_members",
            query: ["group_id": "eq.\(groupId)"],
            select: "id,group_id,user_id,joined_at"
        )

        return members.map { m in
            SupabaseGroupMember(
                id: m.id,
                groupId: m.groupId,
                userId: m.userId,
                joinedAt: m.joinedAt,
                user: nil
            )
        }
    }

    private func getGroupMembersWithUsers(groupId: String) async throws -> [GroupsService.GroupMember] {
        // Get member user IDs - only select columns that exist
        struct SimpleMember: Decodable {
            let id: String
            let userId: String
            let joinedAt: Date
        }

        let members: [SimpleMember] = try await client.fetch(
            from: "group_members",
            query: ["group_id": "eq.\(groupId)"],
            select: "id,user_id,joined_at"
        )

        guard !members.isEmpty else { return [] }

        // Fetch user profiles separately
        let userIds = members.map { $0.userId }
        let users: [SupabaseUser] = try await client.fetch(
            from: "users",
            query: ["id": "in.(\(userIds.joined(separator: ",")))"],
            select: "id,username,full_name,profile_picture"
        )

        let userMap = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })

        return members.map { m in
            let user = userMap[m.userId]
            return GroupsService.GroupMember(
                id: user?.id ?? m.userId,
                username: user?.username,
                fullName: user?.fullName,
                profilePicture: user?.profilePicture,
                role: nil,
                joinedAt: m.joinedAt.timeIntervalSince1970 * 1000
            )
        }
    }
}
