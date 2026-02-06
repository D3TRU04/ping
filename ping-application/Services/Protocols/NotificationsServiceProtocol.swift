//
//  NotificationsServiceProtocol.swift
//  PingNative
//
//  Protocol and types for notifications service
//
//  Note: AppNotification is a typealias to Notification from Models/Notification.swift
//  NotificationMetadata is defined in Models/Notification.swift
//

import Foundation

/// Typealias for the Notification model to use in service protocol
typealias AppNotification = Notification

protocol NotificationsServiceProtocol {
    func fetchNotifications(userId: String, limit: Int) async throws -> [AppNotification]
    func fetchUnreadNotifications(userId: String, limit: Int) async throws -> [AppNotification]
    func getUnreadCount(userId: String) async throws -> Int
    func getNotificationSettings(userId: String) async throws -> NotificationSettings
    func markAsRead(notificationId: String) async throws
    func markAllAsRead(userId: String) async throws
    func deleteNotification(notificationId: String) async throws
    func updateNotificationSettings(userId: String, pushEnabled: Bool?, emailEnabled: Bool?, followNotifications: Bool?, messageNotifications: Bool?, groupNotifications: Bool?) async throws
    func createNotification(recipientId: String, senderId: String, type: String, title: String, message: String, metadata: [String: String]?) async throws
}

// MARK: - Notification Settings

struct NotificationSettings {
    let userId: String
    var pushEnabled: Bool
    var emailEnabled: Bool
    var followNotifications: Bool
    var messageNotifications: Bool
    var groupNotifications: Bool
}
