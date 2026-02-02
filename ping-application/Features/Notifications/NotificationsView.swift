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

    var body: some View {
        ZStack(alignment: .top) {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                // MARK: - Unified Header Container (Title + Filter Pills)
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text("Notifications")
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    // Filter Tabs (aligned to same leading edge as title)
                    NotificationFilterTabs(
                        activeFilter: $viewModel.activeFilter,
                        counts: viewModel.notificationCounts
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24) // Increased margin from screen edges
                .safeAreaPadding(.top, 12) // Respects safe area

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
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color(hex: "1FC9C3"))
                        }
                    }
                    .padding(.horizontal, 24) // Consistent with header margins
                    .padding(.top, 8)
                }

                // Notifications List
                if viewModel.loading {
                    NotificationsLoadingView()
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
                        .padding(.horizontal, 24) // Consistent with header margins
                        .padding(.top, 16)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
        }
        .task {
            viewModel.configure(notificationsService: appEnvironment.notificationsService)
            await viewModel.load(userId: appEnvironment.currentUser?.id ?? "")
        }
    }
}

// MARK: - Loading View
struct NotificationsLoadingView: View {
    var body: some View {
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
    }
}
