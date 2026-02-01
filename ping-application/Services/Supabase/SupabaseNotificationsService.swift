//
//  SupabaseNotificationsService.swift
//  PingNative
//
//  Notifications service for Supabase integration
//  Mirrors NotificationsService.swift functionality
//

import Foundation

class SupabaseNotificationsService: NotificationsServiceProtocol {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Queries

    func fetchNotifications(userId: String, limit: Int = 100) async throws -> [AppNotification] {
        // Fetch notifications without user join
        struct SimpleNotification: Decodable {
            let id: String
            let recipientId: String
            let senderId: String?
            let type: String
            let title: String
            let message: String
            let isRead: Bool
            let createdAt: Date
        }

        let notifications: [SimpleNotification] = try await client.fetch(
            from: "notifications",
            query: [
                "recipient_id": "eq.\(userId)",
                "order": "created_at.desc",
                "limit": "\(limit)"
            ]
        )

        return notifications.map { n in
            AppNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.message,
                isRead: n.isRead,
                createdAt: n.createdAt,
                metadata: nil
            )
        }
    }

    func fetchUnreadNotifications(userId: String, limit: Int = 50) async throws -> [AppNotification] {
        // Fetch notifications without user join
        struct SimpleNotification: Decodable {
            let id: String
            let recipientId: String
            let senderId: String?
            let type: String
            let title: String
            let message: String
            let isRead: Bool
            let createdAt: Date
        }

        let notifications: [SimpleNotification] = try await client.fetch(
            from: "notifications",
            query: [
                "recipient_id": "eq.\(userId)",
                "is_read": "eq.false",
                "order": "created_at.desc",
                "limit": "\(limit)"
            ]
        )

        return notifications.map { n in
            AppNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.message,
                isRead: n.isRead,
                createdAt: n.createdAt,
                metadata: nil
            )
        }
    }

    func getUnreadCount(userId: String) async throws -> Int {
        let notifications: [SupabaseNotification] = try await client.fetch(
            from: "notifications",
            query: [
                "recipient_id": "eq.\(userId)",
                "is_read": "eq.false"
            ],
            select: "id"
        )

        return notifications.count
    }

    func getNotificationSettings(userId: String) async throws -> NotificationSettings {
        let settings: SupabaseNotificationSettings? = try await client.fetchOptional(
            from: "notification_settings",
            query: ["user_id": "eq.\(userId)"]
        )

        if let settings = settings {
            return NotificationSettings(
                userId: settings.userId,
                pushEnabled: settings.pushEnabled,
                emailEnabled: settings.emailEnabled,
                followNotifications: settings.followNotifications,
                messageNotifications: settings.messageNotifications ?? true,
                groupNotifications: settings.groupNotifications
            )
        }

        return NotificationSettings(
            userId: userId,
            pushEnabled: true,
            emailEnabled: true,
            followNotifications: true,
            messageNotifications: true,
            groupNotifications: true
        )
    }
}
