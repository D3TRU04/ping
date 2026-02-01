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
