//
//  PrivacySettingsView.swift
//  PingNative
//
//  Privacy settings screen
//

import SwiftUI

struct PrivacySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var privateAccount = false
    @State private var showActivityStatus = true
    @State private var allowTagging = true
    @State private var showLocation = true

    var body: some View {
        ZStack {
            Color(hex: "FAFAFA")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    SettingsSectionView(title: "Account Privacy") {
                        SettingsToggleRow(
                            icon: "lock.fill",
                            title: "Private Account",
                            subtitle: "Only approved followers can see your content",
                            isOn: $privateAccount
                        )

                        Divider().padding(.leading, 64)

                        SettingsToggleRow(
                            icon: "circle.fill",
                            title: "Activity Status",
                            subtitle: "Show when you're active",
                            isOn: $showActivityStatus
                        )
                    }

                    SettingsSectionView(title: "Interactions") {
                        SettingsToggleRow(
                            icon: "at",
                            title: "Allow Tagging",
                            subtitle: "Let others tag you in posts",
                            isOn: $allowTagging
                        )

                        Divider().padding(.leading, 64)

                        SettingsToggleRow(
                            icon: "location.fill",
                            title: "Show Location",
                            subtitle: "Display your location on your profile",
                            isOn: $showLocation
                        )
                    }
                }
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Privacy")
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
    }
}
