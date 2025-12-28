//
//  NotificationsView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/notifications/page.tsx
//  Generated Swift equivalent matching RN design
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Nav Bar
                NotificationsTopNavBar(currentUser: appEnvironment.currentUser)
                
                // Filter Buttons
                if viewModel.notificationCounts.unread > 0 {
                    HStack {
                        Text("\(viewModel.notificationCounts.unread) unread notification\(viewModel.notificationCounts.unread != 1 ? "s" : "")")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                await viewModel.markAllAsRead()
                            }
                        }) {
                            Text("Mark all read")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.mint)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterButton(
                            title: "All (\(viewModel.notificationCounts.total))",
                            isSelected: viewModel.activeFilter == .all,
                            action: { viewModel.activeFilter = .all }
                        )
                        
                        FilterButton(
                            title: "Unread (\(viewModel.notificationCounts.unread))",
                            isSelected: viewModel.activeFilter == .unread,
                            action: { viewModel.activeFilter = .unread }
                        )
                        
                        FilterButton(
                            title: "Read (\(viewModel.notificationCounts.total - viewModel.notificationCounts.unread))",
                            isSelected: viewModel.activeFilter == .read,
                            action: { viewModel.activeFilter = .read }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                
                // Notifications List
                if viewModel.loading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                        Text("Loading notifications...")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.mint)
                            .padding(.top, 16)
                        Spacer()
                    }
                } else if viewModel.filteredNotifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    List {
                        ForEach(viewModel.filteredNotifications) { notification in
                            NotificationItemView(
                                notification: notification,
                                onPress: {
                                    Task {
                                        await viewModel.handleNotificationPress(notification)
                                    }
                                },
                                onMarkAsRead: {
                                    Task {
                                        await viewModel.markAsRead(notification.id)
                                    }
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteNotification(notification.id)
                                    }
                                }
                            )
                        }
                        
                        // Bottom spacing for tab bar
                        Color.clear.frame(height: 90)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
        }
        .task {
            await viewModel.load(userId: appEnvironment.currentUser?.id ?? "")
        }
    }
}

struct NotificationsTopNavBar: View {
    let currentUser: User?
    
    var body: some View {
        HStack {
            Text("Notifications")
                .font(.system(size: 20, weight: .bold))
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppColors.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.mint : Color(hex: "F5F6FA"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? AppColors.mint : Color(hex: "E0E0E0"), lineWidth: 1)
                )
                .cornerRadius(20)
        }
    }
}

struct NotificationItemView: View {
    let notification: Notification
    let onPress: () -> Void
    let onMarkAsRead: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            HStack(spacing: 12) {
                // Icon based on notification type
                Image(systemName: iconForType(notification.type))
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.mint)
                    .frame(width: 40, height: 40)
                    .background(AppColors.mint.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 16, weight: notification.isRead ? .regular : .semibold))
                        .foregroundColor(AppColors.text)
                    
                    Text(notification.body)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                    
                    Text(formatDate(notification.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if !notification.isRead {
                    Circle()
                        .fill(AppColors.mint)
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            .background(notification.isRead ? Color.white : Color(hex: "F5F6FA"))
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            
            if !notification.isRead {
                Button(action: onMarkAsRead) {
                    Label("Mark Read", systemImage: "checkmark")
                }
                .tint(AppColors.mint)
            }
        }
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "follow": return "person.badge.plus"
        case "place_visit": return "mappin.circle"
        case "place_recommendation": return "star.circle"
        case "chat_message": return "message"
        default: return "bell"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 80))
                .foregroundColor(AppColors.mint)
            
            Text("No notifications")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.text)
            
            Text("You're all caught up! New notifications will appear here.")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
