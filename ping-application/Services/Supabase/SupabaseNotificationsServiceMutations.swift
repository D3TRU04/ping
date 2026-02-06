//
//  SupabaseNotificationsService+Mutations.swift
//  PingNative
//
//  Mutation operations for notifications service
//

import Foundation

extension SupabaseNotificationsService {

    // MARK: - Mutations

    func markAsRead(notificationId: String) async throws {
        struct UpdateResult: Decodable {
            let id: String
        }

        let _: UpdateResult = try await client.update(
            table: "notifications",
            values: ["is_read": true],
            query: ["id": "eq.\(notificationId)"]
        )
    }

    func markAllAsRead(userId: String) async throws {
        struct UpdateResult: Decodable {
            let id: String
        }

        let _: [UpdateResult] = try await client.update(
            table: "notifications",
            values: ["is_read": true],
            query: [
                "recipient_id": "eq.\(userId)",
                "is_read": "eq.false"
            ]
        )
    }

    func deleteNotification(notificationId: String) async throws {
        try await client.delete(
            from: "notifications",
            query: ["id": "eq.\(notificationId)"]
        )
    }

    func createNotification(
        recipientId: String,
        senderId: String,
        type: String,
        title: String,
        message: String,
        metadata: [String: String]? = nil
    ) async throws {
        struct InsertResult: Decodable {
            let id: String
        }

        var values: [String: Any] = [
            "recipient_id": recipientId,
            "sender_id": senderId,
            "type": type,
            "title": title,
            "message": message,
            "is_read": false
        ]

        if let metadata = metadata {
            values["metadata"] = metadata
        }

        let _: InsertResult = try await client.insert(
            into: "notifications",
            values: values
        )
    }

    func updateNotificationSettings(
        userId: String,
        pushEnabled: Bool? = nil,
        emailEnabled: Bool? = nil,
        followNotifications: Bool? = nil,
        messageNotifications: Bool? = nil,
        groupNotifications: Bool? = nil
    ) async throws {
        var updateValues: [String: Any] = [:]

        if let pushEnabled = pushEnabled {
            updateValues["push_enabled"] = pushEnabled
        }
        if let emailEnabled = emailEnabled {
            updateValues["email_enabled"] = emailEnabled
        }
        if let followNotifications = followNotifications {
            updateValues["follow_notifications"] = followNotifications
        }
        if let messageNotifications = messageNotifications {
            updateValues["message_notifications"] = messageNotifications
        }
        if let groupNotifications = groupNotifications {
            updateValues["group_notifications"] = groupNotifications
        }

        guard !updateValues.isEmpty else { return }

        struct UpdateResult: Decodable {
            let id: String
        }

        let existing: SupabaseNotificationSettings? = try await client.fetchOptional(
            from: "notification_settings",
            query: ["user_id": "eq.\(userId)"]
        )

        if existing != nil {
            let _: UpdateResult = try await client.update(
                table: "notification_settings",
                values: updateValues,
                query: ["user_id": "eq.\(userId)"]
            )
        } else {
            let insertValues: [String: Any] = [
                "user_id": userId,
                "push_enabled": pushEnabled ?? true,
                "email_enabled": emailEnabled ?? true,
                "follow_notifications": followNotifications ?? true,
                "group_notifications": groupNotifications ?? true,
                "message_notifications": messageNotifications ?? true
            ]

            let _: UpdateResult = try await client.insert(
                into: "notification_settings",
                values: insertValues
            )
        }
    }
}
