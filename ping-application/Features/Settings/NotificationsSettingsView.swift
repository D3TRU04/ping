//
//  NotificationsSettingsView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/settings/notifications/page.tsx (implied)
//  Notifications settings screen
//

import SwiftUI
import Combine

struct NotificationsSettingsView: View {
    @StateObject private var viewModel = NotificationsSettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FAF6F2"), Color(hex: "F5F5F5")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    SettingsSection(title: "Push Notifications") {
                        ToggleRow(
                            label: "Enable Push Notifications",
                            isOn: $viewModel.pushNotificationsEnabled
                        )
                    }
                    
                    SettingsSection(title: "Notification Types") {
                        ToggleRow(
                            label: "New Followers",
                            isOn: $viewModel.newFollowersEnabled
                        )
                        
                        ToggleRow(
                            label: "Place Recommendations",
                            isOn: $viewModel.placeRecommendationsEnabled
                        )
                        
                        ToggleRow(
                            label: "Chat Messages",
                            isOn: $viewModel.chatMessagesEnabled
                        )
                        
                        ToggleRow(
                            label: "Group Updates",
                            isOn: $viewModel.groupUpdatesEnabled
                        )
                    }
                    
                    SettingsSection(title: "Email Notifications") {
                        ToggleRow(
                            label: "Email Notifications",
                            isOn: $viewModel.emailNotificationsEnabled
                        )
                    }
                }
                .padding(.vertical, 16)
            }
            
            // Top Nav Bar
            VStack {
                SettingsTopNavBar(title: "Notifications")
                Spacer()
            }
        }
        .navigationBarHidden(true)
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
        // TODO: Load notification preferences from Supabase
    }
    
    func save() async {
        // TODO: Save notification preferences to Supabase
    }
}

struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
