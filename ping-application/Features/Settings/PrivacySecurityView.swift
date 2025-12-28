//
//  PrivacySecurityView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/settings/privacy-security/page.tsx (implied)
//  Privacy & Security settings screen
//

import SwiftUI
import Combine

struct PrivacySecurityView: View {
    @StateObject private var viewModel = PrivacySecurityViewModel()
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
                    SettingsSection(title: "Privacy") {
                        ToggleRow(
                            label: "Private Profile",
                            isOn: $viewModel.privateProfile
                        )
                        
                        ToggleRow(
                            label: "Show Activity Status",
                            isOn: $viewModel.showActivityStatus
                        )
                        
                        SettingsRow(
                            icon: "eye",
                            label: "Blocked Users",
                            action: {
                                // Navigate to blocked users
                            }
                        )
                    }
                    
                    SettingsSection(title: "Security") {
                        SettingsRow(
                            icon: "lock",
                            label: "Change Password",
                            action: {
                                viewModel.showChangePassword = true
                            }
                        )
                        
                        SettingsRow(
                            icon: "key",
                            label: "Two-Factor Authentication",
                            action: {
                                // Navigate to 2FA setup
                            }
                        )
                    }
                    
                    SettingsSection(title: "Data") {
                        SettingsRow(
                            icon: "arrow.down.doc",
                            label: "Download Your Data",
                            action: {
                                viewModel.downloadData()
                            }
                        )
                        
                        Button(action: {
                            viewModel.showDeleteAccount = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                                    .frame(width: 32)
                                
                                Text("Delete Account")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            
            // Top Nav Bar
            VStack {
                SettingsTopNavBar(title: "Privacy & Security")
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showChangePassword) {
            ChangePasswordView()
        }
        .alert("Delete Account", isPresented: $viewModel.showDeleteAccount) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .task {
            await viewModel.load()
        }
    }
}

@MainActor
class PrivacySecurityViewModel: ObservableObject {
    @Published var privateProfile: Bool = false
    @Published var showActivityStatus: Bool = true
    @Published var showChangePassword: Bool = false
    @Published var showDeleteAccount: Bool = false
    
    func load() async {
        // TODO: Load privacy settings from Supabase
    }
    
    func downloadData() {
        // TODO: Request data download
    }
    
    func deleteAccount() async {
        // TODO: Delete account from Supabase
    }
}

struct ChangePasswordView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var saving: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Current Password") {
                    SecureField("Enter current password", text: $currentPassword)
                }
                
                Section("New Password") {
                    SecureField("Enter new password", text: $newPassword)
                    SecureField("Confirm new password", text: $confirmPassword)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await savePassword()
                        }
                    }
                    .disabled(saving || newPassword != confirmPassword)
                }
            }
        }
    }
    
    func savePassword() async {
        saving = true
        // TODO: Update password via Supabase
        saving = false
        dismiss()
    }
}
