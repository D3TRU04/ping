//
//  Notification.swift
//  PingNative
//
//  Source: ping/apps/src/screens/notifications/types/Notification.ts
//  Generated Swift model matching RN Notification structure
//

import Foundation

struct Notification: Identifiable, Codable {
    let id: String
    let type: String // "follow", "place_visit", "place_recommendation", "chat_message"
    let title: String
    let body: String
    var isRead: Bool
    let createdAt: Date
    var metadata: NotificationMetadata?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case body
        case isRead = "is_read"
        case createdAt = "created_at"
        case metadata
    }
}

struct NotificationMetadata: Codable {
    var senderName: String?
    var senderId: String?
    var placeName: String?
    var placeId: String?
    var chatId: String?
    
    enum CodingKeys: String, CodingKey {
        case senderName = "sender_name"
        case senderId = "sender_id"
        case placeName = "place_name"
        case placeId = "place_id"
        case chatId = "chat_id"
    }
}
