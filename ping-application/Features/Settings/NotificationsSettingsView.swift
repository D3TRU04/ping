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
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .task {
            await viewModel.load()
        }
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
    
    func load() async {
        // TODO: Load notification preferences from Backend
        // For now, simulate loading
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func save() async {
        // TODO: Save notification preferences to Backend
    }
}
