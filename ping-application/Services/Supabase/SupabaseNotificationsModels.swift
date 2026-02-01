//
//  SupabaseNotificationsModels.swift
//  PingNative
//
//  Model types for notifications service
//

import Foundation

struct SupabaseNotification: Decodable {
    let id: String
    let recipientId: String
    let senderId: String?
    let type: String
    let title: String
    let message: String
    let metadata: NotificationMetadataJSON?
    let isRead: Bool
    let createdAt: Date
    let sender: Sender?

    // Only need CodingKey for "users" -> "sender" (different name)
    enum CodingKeys: String, CodingKey {
        case id, recipientId, senderId, type, title, message, metadata, isRead, createdAt
        case sender = "users"
    }

    struct Sender: Decodable {
        let id: String
        let username: String?
        let fullName: String?
        let profilePicture: String?

        // No CodingKeys needed - auto-converted from snake_case
    }

    struct NotificationMetadataJSON: Decodable {
        let senderName: String?
        let senderId: String?
        let placeName: String?
        let placeId: String?
        let chatId: String?

        // No CodingKeys needed - auto-converted from snake_case
    }

    func toAppNotification() -> AppNotification {
        AppNotification(
            id: id,
            type: type,
            title: title,
            body: message,
            isRead: isRead,
            createdAt: createdAt,
            metadata: metadata.map { meta in
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

struct SupabaseNotificationSettings: Decodable {
    let id: String
    let userId: String
    let pushEnabled: Bool
    let emailEnabled: Bool
    let followNotifications: Bool
    let groupNotifications: Bool
    let messageNotifications: Bool?

    // No CodingKeys needed - auto-converted from snake_case
}
