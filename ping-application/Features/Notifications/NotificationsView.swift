//
//  NotificationsView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/notifications/page.tsx
//  Updated to match Profile screen styling
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    // Soft white background color (matching Profile)
    private let backgroundColor = Color(hex: "FAFAFA")
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Spacer for fixed nav bar
                Spacer().frame(height: 50)
                
                // Filter Tabs (matching ProfileTabs style)
                NotificationFilterTabs(
                    activeFilter: $viewModel.activeFilter,
                    counts: viewModel.notificationCounts
                )
                .padding(.top, 4)
                
                // Unread Count & Mark All Read
                if viewModel.notificationCounts.unread > 0 {
                    HStack {
                        Text("\(viewModel.notificationCounts.unread) unread notification\(viewModel.notificationCounts.unread != 1 ? "s" : "")")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                await viewModel.markAllAsRead()
                            }
                        }) {
                            Text("Mark all read")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "1FC9C3"))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                
                // Notifications List
                if viewModel.loading {
                    VStack(spacing: 16) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1FC9C3")))
                            .scaleEffect(1.2)
                        Text("Loading notifications...")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                } else if viewModel.filteredNotifications.isEmpty {
                    NotificationsEmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredNotifications) { notification in
                                NotificationItemCard(
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
                            Spacer().frame(height: 100)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            
            // Fixed Top Nav Bar (matching ProfileNavBar style)
            NotificationsNavBar()
        }
        .task {
            viewModel.configure(notificationsService: appEnvironment.notificationsService)
            await viewModel.load(userId: appEnvironment.currentUser?.id ?? "")
        }
    }
}

// MARK: - Nav Bar (matching DiscoverNavBar style)
struct NotificationsNavBar: View {
    var body: some View {
        HStack(alignment: .center) {
            Text("Notifications")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "FAFAFA").opacity(0.95), Color(hex: "FAFAFA").opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Filter Tabs (matching ProfileTabs style)
struct NotificationFilterTabs: View {
    @Binding var activeFilter: NotificationsViewModel.NotificationFilter
    let counts: NotificationCounts
    
    var body: some View {
        HStack(spacing: 8) {
            FilterTabButton(
                title: "All",
                count: counts.total,
                isSelected: activeFilter == .all,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeFilter = .all
                    }
                }
            )
            
            FilterTabButton(
                title: "Unread",
                count: counts.unread,
                isSelected: activeFilter == .unread,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeFilter = .unread
                    }
                }
            )
            
            FilterTabButton(
                title: "Read",
                count: counts.total - counts.unread,
                isSelected: activeFilter == .read,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeFilter = .read
                    }
                }
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

struct FilterTabButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(title) (\(count))")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ?
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            colors: [Color(hex: "F3F4F6"), Color(hex: "F3F4F6")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color(hex: "1FC9C3") : Color.clear, lineWidth: 1)
                )
                .shadow(color: isSelected ? Color(hex: "1FC9C3").opacity(0.25) : Color.clear, radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Notification Item Card
struct NotificationItemCard: View {
    let notification: Notification
    let onPress: () -> Void
    let onMarkAsRead: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            HStack(spacing: 14) {
                // Icon with glow effect (similar to profile picture style)
                ZStack {
                    // Subtle glow for unread
                    if !notification.isRead {
                        Circle()
                            .fill(Color(hex: "1FC9C3").opacity(0.15))
                            .frame(width: 56, height: 56)
                            .blur(radius: 8)
                    }
                    
                    Circle()
                        .fill(notification.isRead ? Color(hex: "F3F4F6") : Color(hex: "1FC9C3").opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: iconForType(notification.type))
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(notification.isRead ? AppColors.textTertiary : Color(hex: "1FC9C3"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 16, weight: notification.isRead ? .regular : .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(notification.body)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                    
                    Text(formatDate(notification.createdAt))
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.top, 2)
                }
                
                Spacer()
                
                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 10, height: 10)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(notification.isRead ? 0.03 : 0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            if !notification.isRead {
                Button(action: onMarkAsRead) {
                    Label("Mark as Read", systemImage: "checkmark.circle")
                }
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
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

// MARK: - Empty State (matching Profile EmptyStateView style)
struct NotificationsEmptyStateView: View {
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "F3F4F6"))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "bell.slash")
                        .font(.system(size: 32, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "B2BEC3"))
                }
                .padding(.bottom, 8)
                
                VStack(spacing: 8) {
                    Text("No notifications")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("You're all caught up! New notifications will appear here.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                }
            }
            
            Spacer()
            
            // Extra space for bottom nav bar
            Spacer().frame(height: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

