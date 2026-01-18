//
//  NotificationsService.swift
//  PingNative
//
//  Notifications service with Convex integration
//

import Foundation

class NotificationsService {
    private let convexClient: ConvexClient

    init(convexClient: ConvexClient) {
        self.convexClient = convexClient
    }
    
    func fetchNotifications(userId: String, limit: Int = 100) async throws -> [AppNotification] {
        struct NotificationResult: Codable {
            let id: String
            let recipientId: String
            let senderId: String?
            let type: String
            let title: String
            let message: String
            let metadata: Metadata?
            let isRead: Bool
            let createdAt: Double
            let sender: Sender?

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case recipientId
                case senderId
                case type
                case title
                case message
                case metadata
                case isRead
                case createdAt
                case sender
            }

            struct Sender: Codable {
                let id: String
                let username: String
                let fullName: String?
                let profilePicture: String?

                enum CodingKeys: String, CodingKey {
                    case id = "_id"
                    case username
                    case fullName
                    case profilePicture
                }
            }

            struct Metadata: Codable {
                let senderName: String?
                let senderId: String?
                let placeName: String?
                let placeId: String?
                let chatId: String?
            }
        }

        let notifications: [NotificationResult] = try await convexClient.query(
            function: "notifications:getNotifications",
            args: ["userId": userId, "limit": limit]
        )

        return notifications.map { notif in
            AppNotification(
                id: notif.id,
                type: notif.type,
                title: notif.title,
                body: notif.message,
                isRead: notif.isRead,
                createdAt: Date(timeIntervalSince1970: notif.createdAt / 1000),
                metadata: notif.metadata.map { meta in
                    NotificationMetadata(
                        senderName: meta.senderName,
                        senderId: meta.senderId,
                        placeName: meta.placeName,
                        placeId: meta.placeId,
                        chatId: meta.chatId
                    )
                }
            )
        }
    }

    func markAsRead(notificationId: String) async throws {
        struct MarkReadResult: Codable {
            let success: Bool
        }

        let _: MarkReadResult = try await convexClient.mutation(
            function: "notifications:markAsRead",
            args: ["notificationId": notificationId]
        )
    }
    
    func markAllAsRead(userId: String) async throws {
        struct MarkAllReadResult: Codable {
            let count: Int
        }

        let _: MarkAllReadResult = try await convexClient.mutation(
            function: "notifications:markAllAsRead",
            args: ["userId": userId]
        )
    }
    
    func deleteNotification(notificationId: String) async throws {
        struct DeleteResult: Codable {
            let success: Bool
        }

        let _: DeleteResult = try await convexClient.mutation(
            function: "notifications:deleteNotification",
            args: ["notificationId": notificationId]
        )
    }
    
    // Get unread notification count
    func getUnreadCount(userId: String) async throws -> Int {
        let count: Int = try await convexClient.query(
            function: "notifications:getUnreadCount",
            args: ["userId": userId]
        )

        return count
    }

    // Get only unread notifications
    func fetchUnreadNotifications(userId: String, limit: Int = 50) async throws -> [AppNotification] {
        struct NotificationResult: Codable {
            let id: String
            let recipientId: String
            let senderId: String?
            let type: String
            let title: String
            let message: String
            let metadata: Metadata?
            let isRead: Bool
            let createdAt: Double
            let sender: Sender?

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case recipientId
                case senderId
                case type
                case title
                case message
                case metadata
                case isRead
                case createdAt
                case sender
            }

            struct Sender: Codable {
                let id: String
                let username: String
                let fullName: String?
                let profilePicture: String?

                enum CodingKeys: String, CodingKey {
                    case id = "_id"
                    case username
                    case fullName
                    case profilePicture
                }
            }

            struct Metadata: Codable {
                let senderName: String?
                let senderId: String?
                let placeName: String?
                let placeId: String?
                let chatId: String?
            }
        }

        let notifications: [NotificationResult] = try await convexClient.query(
            function: "notifications:getUnreadNotifications",
            args: ["userId": userId, "limit": limit]
        )

        return notifications.map { notif in
            AppNotification(
                id: notif.id,
                type: notif.type,
                title: notif.title,
                body: notif.message,
                isRead: notif.isRead,
                createdAt: Date(timeIntervalSince1970: notif.createdAt / 1000),
                metadata: notif.metadata.map { meta in
                    NotificationMetadata(
                        senderName: meta.senderName,
                        senderId: meta.senderId,
                        placeName: meta.placeName,
                        placeId: meta.placeId,
                        chatId: meta.chatId
                    )
                }
            )
        }
    }

    // Get notification settings
    func getNotificationSettings(userId: String) async throws -> NotificationSettings {
        struct SettingsResult: Codable {
            let userId: String
            let pushEnabled: Bool
            let emailEnabled: Bool
            let followNotifications: Bool
            let messageNotifications: Bool
            let groupNotifications: Bool
        }

        let settings: SettingsResult = try await convexClient.query(
            function: "notifications:getNotificationSettings",
            args: ["userId": userId]
        )

        return NotificationSettings(
            userId: settings.userId,
            pushEnabled: settings.pushEnabled,
            emailEnabled: settings.emailEnabled,
            followNotifications: settings.followNotifications,
            messageNotifications: settings.messageNotifications,
            groupNotifications: settings.groupNotifications
        )
    }

    // Update notification settings
    func updateNotificationSettings(
        userId: String,
        pushEnabled: Bool? = nil,
        emailEnabled: Bool? = nil,
        followNotifications: Bool? = nil,
        messageNotifications: Bool? = nil,
        groupNotifications: Bool? = nil
    ) async throws {
        var args: [String: Any] = ["userId": userId]

        if let pushEnabled = pushEnabled { args["pushEnabled"] = pushEnabled }
        if let emailEnabled = emailEnabled { args["emailEnabled"] = emailEnabled }
        if let followNotifications = followNotifications { args["followNotifications"] = followNotifications }
        if let messageNotifications = messageNotifications { args["messageNotifications"] = messageNotifications }
        if let groupNotifications = groupNotifications { args["groupNotifications"] = groupNotifications }

        let _: String = try await convexClient.mutation(
            function: "notifications:updateNotificationSettings",
            args: args
        )
    }

    // Real-time subscription for new notifications
    func subscribeToNotifications(
        userId: String,
        onNotification: @escaping (AppNotification) -> Void
    ) -> NotificationSubscription? {
        // TODO: Implement real-time subscription using Convex subscriptions
        return nil
    }
}

// MARK: - Supporting Models

// Renamed to avoid conflict with system Notification
typealias AppNotification = Notification

struct NotificationSettings {
    let userId: String
    let pushEnabled: Bool
    let emailEnabled: Bool
    let followNotifications: Bool
    let messageNotifications: Bool
    let groupNotifications: Bool
}

class NotificationSubscription {
    func cancel() {
        // Cancel subscription
    }
}
