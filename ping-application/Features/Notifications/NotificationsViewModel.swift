//
//  NotificationsViewModel.swift
//  PingNative
//
//  Connected to Convex database for notifications
//

import Foundation
import Combine

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var filteredNotifications: [Notification] = []
    @Published var loading: Bool = false
    @Published var refreshing: Bool = false
    @Published var activeFilter: NotificationFilter = .all
    @Published var notificationCounts = NotificationCounts()
    @Published var error: String?
    
    private var notificationsService: NotificationsService?
    private var currentUserId: String?
    
    enum NotificationFilter {
        case all
        case unread
        case read
    }
    
    func configure(notificationsService: NotificationsService) {
        self.notificationsService = notificationsService
    }
    
    func load(userId: String) async {
        guard !userId.isEmpty else { return }
        guard let notificationsService = notificationsService else {
            error = "Notifications service not configured"
            return
        }

        currentUserId = userId
        loading = true
        error = nil

        do {
            let fetchedNotifications = try await notificationsService.fetchNotifications(userId: userId, limit: 100)
            
            // Convert AppNotification to Notification model
            self.notifications = fetchedNotifications
            
            // Update counts and filter
            updateFilteredNotifications()
        } catch {
            print("❌ Error loading notifications: \(error)")
            self.error = error.localizedDescription
        }

        loading = false
    }
    
    func refresh() async {
        guard let userId = currentUserId else { return }
        refreshing = true
        await load(userId: userId)
        refreshing = false
    }
    
    func markAsRead(_ notificationId: String) async {
        guard let notificationsService = notificationsService else { return }
        
        // Optimistic update
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            updateFilteredNotifications()
        }
        
        do {
            try await notificationsService.markAsRead(notificationId: notificationId)
        } catch {
            print("❌ Error marking notification as read: \(error)")
            // Revert on error
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                notifications[index].isRead = false
                updateFilteredNotifications()
            }
        }
    }
    
    func markAllAsRead() async {
        guard let notificationsService = notificationsService,
              let userId = currentUserId else { return }
        
        // Optimistic update
        let previousStates = notifications.map { $0.isRead }
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        updateFilteredNotifications()
        
        do {
            try await notificationsService.markAllAsRead(userId: userId)
        } catch {
            print("❌ Error marking all notifications as read: \(error)")
            // Revert on error
            for (index, wasRead) in previousStates.enumerated() {
                notifications[index].isRead = wasRead
            }
            updateFilteredNotifications()
        }
    }
    
    func deleteNotification(_ notificationId: String) async {
        guard let notificationsService = notificationsService else { return }
        
        // Store for potential revert
        let deletedNotification = notifications.first { $0.id == notificationId }
        let deletedIndex = notifications.firstIndex { $0.id == notificationId }
        
        // Optimistic update
        notifications.removeAll { $0.id == notificationId }
        updateFilteredNotifications()
        
        do {
            try await notificationsService.deleteNotification(notificationId: notificationId)
        } catch {
            print("❌ Error deleting notification: \(error)")
            // Revert on error
            if let notification = deletedNotification, let index = deletedIndex {
                notifications.insert(notification, at: min(index, notifications.count))
                updateFilteredNotifications()
            }
        }
    }
    
    func handleNotificationPress(_ notification: Notification) async {
        // Mark as read if unread
        if !notification.isRead {
            await markAsRead(notification.id)
        }
        
        // Navigation would be handled by the view based on notification type
        // notification.type can be: "follow", "place_visit", "place_recommendation", "chat_message"
    }
    
    private func updateFilteredNotifications() {
        // Update counts
        notificationCounts.total = notifications.count
        notificationCounts.unread = notifications.filter { !$0.isRead }.count
        
        // Filter based on active filter
        switch activeFilter {
        case .all:
            filteredNotifications = notifications
        case .unread:
            filteredNotifications = notifications.filter { !$0.isRead }
        case .read:
            filteredNotifications = notifications.filter { $0.isRead }
        }
    }
}

struct NotificationCounts {
    var total: Int = 0
    var unread: Int = 0
}
