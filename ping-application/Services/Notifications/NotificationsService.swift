//
//  NotificationsService.swift
//  PingNative
//
//  Source: ping/apps/src/screens/notifications/services/
//  Complete Notifications service with Supabase integration
//

import Foundation

class NotificationsService {
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func fetchNotifications(userId: String) async throws -> [Notification] {
        // Fetch notifications from Supabase
        // SELECT * FROM notifications WHERE user_id = userId ORDER BY created_at DESC
        let response: [NotificationResponse] = try await supabaseClient.get(
            path: "/rest/v1/notifications",
            queryParams: [
                "user_id": "eq.\(userId)",
                "order": "created_at.desc"
            ],
            responseType: [NotificationResponse].self
        )
        
        return response.map { $0.toNotification() }
    }
    
    func markAsRead(notificationId: String) async throws {
        // Update notification in Supabase
        let update: [String: Bool] = ["is_read": true]
        let _: EmptyResponse = try await supabaseClient.patch(
            path: "/rest/v1/notifications",
            body: update,
            queryParams: ["id": "eq.\(notificationId)"],
            responseType: EmptyResponse.self
        )
    }
    
    func markAllAsRead(userId: String) async throws {
        // Update all notifications for user
        let update: [String: Bool] = ["is_read": true]
        let _: EmptyResponse = try await supabaseClient.patch(
            path: "/rest/v1/notifications",
            body: update,
            queryParams: ["user_id": "eq.\(userId)"],
            responseType: EmptyResponse.self
        )
    }
    
    func deleteNotification(notificationId: String) async throws {
        // Delete notification from Supabase
        let _: EmptyResponse = try await supabaseClient.delete(
            path: "/rest/v1/notifications",
            queryParams: ["id": "eq.\(notificationId)"],
            responseType: EmptyResponse.self
        )
    }
    
    // Real-time subscription for new notifications
    func subscribeToNotifications(
        userId: String,
        onNotification: @escaping (Notification) -> Void
    ) -> NotificationSubscription? {
        // TODO: Implement real-time subscription using Supabase Realtime
        // This would use WebSocket connection
        return nil
    }
}

struct NotificationResponse: Codable {
    let id: String
    let userId: String
    let type: String
    let title: String
    let body: String
    let isRead: Bool
    let createdAt: Date
    let metadata: NotificationMetadataResponse?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case title
        case body
        case isRead = "is_read"
        case createdAt = "created_at"
        case metadata
    }
    
    func toNotification() -> Notification {
        Notification(
            id: id,
            type: type,
            title: title,
            body: body,
            isRead: isRead,
            createdAt: createdAt,
            metadata: metadata?.toMetadata()
        )
    }
}

struct NotificationMetadataResponse: Codable {
    let senderName: String?
    let senderId: String?
    let placeName: String?
    let placeId: String?
    let chatId: String?
    
    enum CodingKeys: String, CodingKey {
        case senderName = "sender_name"
        case senderId = "sender_id"
        case placeName = "place_name"
        case placeId = "place_id"
        case chatId = "chat_id"
    }
    
    func toMetadata() -> NotificationMetadata {
        NotificationMetadata(
            senderName: senderName,
            senderId: senderId,
            placeName: placeName,
            placeId: placeId,
            chatId: chatId
        )
    }
}

class NotificationSubscription {
    func cancel() {
        // Cancel subscription
    }
}
