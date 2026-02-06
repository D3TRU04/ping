//
//  NotificationsSettingsView.swift
//  PingNative
//
//  Notifications settings screen
//

import SwiftUI
import Combine

struct NotificationsSettingsView: View {
    @StateObject private var viewModel = NotificationsSettingsViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(hex: "FAFAFA")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    SettingsSectionView(title: "Push Notifications") {
                        SettingsToggleRow(
                            title: "Pause All",
                            isOn: Binding(
                                get: { !viewModel.pushNotificationsEnabled },
                                set: { viewModel.pushNotificationsEnabled = !$0 }
                            )
                        )
                    }

                    SettingsSectionView(title: "Interactions") {
                        SettingsToggleRow(
                            title: "New Followers",
                            isOn: $viewModel.newFollowersEnabled
                        )
                        Divider().padding(.leading, 20)
                        SettingsToggleRow(
                            title: "Mentions & Tags",
                            isOn: $viewModel.chatMessagesEnabled // reusing for now
                        )
                    }

                    SettingsSectionView(title: "Recommendations") {
                        SettingsToggleRow(
                            title: "Place Recommendations",
                            isOn: $viewModel.placeRecommendationsEnabled
                        )
                        Divider().padding(.leading, 20)
                        SettingsToggleRow(
                            title: "Group Updates",
                            isOn: $viewModel.groupUpdatesEnabled
                        )
                    }

                    SettingsSectionView(title: "Other") {
                        SettingsToggleRow(
                            title: "Email Notifications",
                            isOn: $viewModel.emailNotificationsEnabled
                        )
                    }

                    Text("Push notifications are sent to your device to keep you updated on activity.")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .task {
            viewModel.configure(
                notificationsService: appEnvironment.notificationsService,
                userId: appEnvironment.currentUser?.id ?? ""
            )
            await viewModel.load()
        }
        .onChange(of: viewModel.pushNotificationsEnabled) { _ in viewModel.debounceSave() }
        .onChange(of: viewModel.newFollowersEnabled) { _ in viewModel.debounceSave() }
        .onChange(of: viewModel.chatMessagesEnabled) { _ in viewModel.debounceSave() }
        .onChange(of: viewModel.groupUpdatesEnabled) { _ in viewModel.debounceSave() }
        .onChange(of: viewModel.emailNotificationsEnabled) { _ in viewModel.debounceSave() }
    }
}

@MainActor
class NotificationsSettingsViewModel: ObservableObject {
    @Published var pushNotificationsEnabled: Bool = true
    @Published var newFollowersEnabled: Bool = true
    @Published var placeRecommendationsEnabled: Bool = true
    @Published var chatMessagesEnabled: Bool = true
    @Published var groupUpdatesEnabled: Bool = true
    @Published var emailNotificationsEnabled: Bool = false

    private var notificationsService: NotificationsServiceProtocol?
    private var userId: String = ""
    private var saveTask: Task<Void, Never>?
    private var isLoading: Bool = false

    func configure(notificationsService: NotificationsServiceProtocol, userId: String) {
        self.notificationsService = notificationsService
        self.userId = userId
    }

    func load() async {
        guard let service = notificationsService, !userId.isEmpty else { return }
        isLoading = true
        do {
            let settings = try await service.getNotificationSettings(userId: userId)
            pushNotificationsEnabled = settings.pushEnabled
            emailNotificationsEnabled = settings.emailEnabled
            newFollowersEnabled = settings.followNotifications
            chatMessagesEnabled = settings.messageNotifications
            groupUpdatesEnabled = settings.groupNotifications
        } catch {
            #if DEBUG
            print("Failed to load notification settings: \(error)")
            #endif
        }
        isLoading = false
    }

    func debounceSave() {
        guard !isLoading else { return }
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await save()
        }
    }

    func save() async {
        guard let service = notificationsService, !userId.isEmpty else { return }
        do {
            try await service.updateNotificationSettings(
                userId: userId,
                pushEnabled: pushNotificationsEnabled,
                emailEnabled: emailNotificationsEnabled,
                followNotifications: newFollowersEnabled,
                messageNotifications: chatMessagesEnabled,
                groupNotifications: groupUpdatesEnabled
            )
        } catch {
            #if DEBUG
            print("Failed to save notification settings: \(error)")
            #endif
        }
    }
}
