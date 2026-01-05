//
//  ChatService.swift
//  PingNative
//
//  Chat service with Convex integration
//

import Foundation

// ChatMessage model - shared between service and views
struct ChatMessage: Identifiable, Codable {
    let id: String
    let senderId: String
    let receiverId: String?
    let groupId: String?
    let text: String
    let createdAt: Double
    var isRead: Bool
    let sender: MessageSender?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case senderId
        case receiverId
        case groupId
        case text = "message"
        case createdAt
        case isRead
        case sender
    }
}

struct MessageSender: Codable {
    let username: String
    let fullName: String?
    let profilePicture: String?
}

class ChatService {
    private let convexClient: ConvexClient

    init(convexClient: ConvexClient) {
        self.convexClient = convexClient
    }
    
    func fetchChats(userId: String) async throws -> [Chat] {
        struct ConversationResult: Codable {
            let conversationId: String
            let otherUser: OtherUser
            let latestMessage: LatestMessage
            let unreadCount: Int
            let updatedAt: Double

            struct OtherUser: Codable {
                let _id: String
                let username: String
                let fullName: String?
                let profilePicture: String?
            }

            struct LatestMessage: Codable {
                let text: String
                let createdAt: Double
                let senderId: String
            }
        }

        let conversations: [ConversationResult] = try await convexClient.query(
            function: "messages:getConversations",
            args: ["userId": userId]
        )

        return conversations.map { conv in
            Chat(
                id: conv.conversationId,
                name: conv.otherUser.fullName ?? conv.otherUser.username,
                otherUserId: conv.otherUser._id,
                latestMessage: conv.latestMessage.text,
                updatedAt: Date(timeIntervalSince1970: conv.latestMessage.createdAt / 1000),
                unreadCount: conv.unreadCount
            )
        }
    }
    
    func fetchMessages(conversationId: String) async throws -> [ChatMessage] {
        let messages: [ChatMessage] = try await convexClient.query(
            function: "messages:getMessages",
            args: ["conversationId": conversationId]
        )

        return messages
    }
    
    func sendMessage(
        conversationId: String,
        senderId: String,
        receiverId: String,
        text: String
    ) async throws -> String {
        let messageId: String = try await convexClient.mutation(
            function: "messages:sendMessage",
            args: [
                "conversationId": conversationId,
                "senderId": senderId,
                "receiverId": receiverId,
                "message": text
            ]
        )

        return messageId
    }
    
    func createConversation(userId1: String, userId2: String) async throws -> String {
        struct ConversationResult: Codable {
            let conversationId: String
            let exists: Bool
        }

        let result: ConversationResult = try await convexClient.query(
            function: "messages:getOrCreateConversation",
            args: [
                "userId1": userId1,
                "userId2": userId2
            ]
        )

        return result.conversationId
    }
    
    // Mark messages as read in a conversation
    func markMessagesAsRead(conversationId: String, userId: String) async throws {
        struct MarkReadResult: Codable {
            let count: Int
        }

        let _: MarkReadResult = try await convexClient.mutation(
            function: "messages:markMessagesAsRead",
            args: [
                "conversationId": conversationId,
                "userId": userId
            ]
        )
    }

    // MARK: - Group Methods

    // Get user's groups
    func fetchUserGroups(userId: String) async throws -> [Group] {
        struct GroupResult: Codable {
            let _id: String
            let name: String
            let createdBy: String
            let createdAt: Double
            let memberRole: String?
            let latestMessage: LatestMessage?
            let unreadCount: Int

            struct LatestMessage: Codable {
                let text: String
                let createdAt: Double
                let senderId: String
            }
        }

        let groups: [GroupResult] = try await convexClient.query(
            function: "messages:getUserGroups",
            args: ["userId": userId]
        )

        return groups.map { group in
            Group(
                id: group._id,
                name: group.name,
                latestMessage: group.latestMessage?.text,
                updatedAt: group.latestMessage.map { Date(timeIntervalSince1970: $0.createdAt / 1000) },
                unreadCount: group.unreadCount
            )
        }
    }

    // Get messages in a group
    func fetchGroupMessages(groupId: String) async throws -> [ChatMessage] {
        let messages: [ChatMessage] = try await convexClient.query(
            function: "messages:getGroupMessages",
            args: ["groupId": groupId]
        )

        return messages
    }

    // Send group message
    func sendGroupMessage(groupId: String, senderId: String, text: String) async throws -> String {
        let messageId: String = try await convexClient.mutation(
            function: "messages:sendGroupMessage",
            args: [
                "groupId": groupId,
                "senderId": senderId,
                "message": text
            ]
        )

        return messageId
    }

    // Create a new group
    func createGroup(name: String, createdBy: String, memberIds: [String]) async throws -> String {
        let groupId: String = try await convexClient.mutation(
            function: "messages:createGroup",
            args: [
                "name": name,
                "createdBy": createdBy,
                "memberIds": memberIds
            ]
        )

        return groupId
    }

    // Get group details
    func getGroupDetails(groupId: String) async throws -> GroupDetails {
        struct GroupDetailsResult: Codable {
            let _id: String
            let name: String
            let createdBy: String
            let createdAt: Double
            let members: [Member]

            struct Member: Codable {
                let _id: String
                let username: String
                let fullName: String?
                let profilePicture: String?
                let role: String?
                let joinedAt: Double
            }
        }

        let result: GroupDetailsResult = try await convexClient.query(
            function: "messages:getGroupDetails",
            args: ["groupId": groupId]
        )

        return GroupDetails(
            id: result._id,
            name: result.name,
            createdBy: result.createdBy,
            members: result.members.map { member in
                GroupMember(
                    id: member._id,
                    username: member.username,
                    fullName: member.fullName,
                    profilePicture: member.profilePicture,
                    role: member.role ?? "member"
                )
            }
        )
    }

    // Real-time subscription for new messages
    func subscribeToMessages(
        conversationId: String,
        onMessage: @escaping (ChatMessage) -> Void
    ) -> MessageSubscription? {
        // TODO: Implement real-time subscription using Convex subscriptions
        return nil
    }
}

// MARK: - Chat Models

struct Chat: Identifiable {
    let id: String
    let name: String?
    let otherUserId: String?
    let latestMessage: String?
    let updatedAt: Date?
    let unreadCount: Int
}

struct Group: Identifiable {
    let id: String
    let name: String
    let latestMessage: String?
    let updatedAt: Date?
    let unreadCount: Int
}

struct GroupDetails {
    let id: String
    let name: String
    let createdBy: String
    let members: [GroupMember]
}

struct GroupMember: Identifiable {
    let id: String
    let username: String
    let fullName: String?
    let profilePicture: String?
    let role: String
}

class MessageSubscription {
    func cancel() {
        // Cancel subscription
    }
}
