//
//  AccountInfoView.swift
//  PingNative
//
//  Account information editing view
//

import SwiftUI

struct AccountInfoView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    
    // Form State
    @State private var fullName: String = ""
    @State private var username: String = ""
    @State private var pronouns: String = ""
    @State private var bio: String = ""
    @State private var location: String = ""
    @State private var website: String = ""
    
    // UI State
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    var body: some View {
        ZStack {
            Color(hex: "FAFAFA")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "F3F4F6"))
                                .frame(width: 100, height: 100)
                            
                            if let avatarUrl = appEnvironment.currentUser?.profilePicture, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: "B2BEC3"))
                            }
                            
                            // Edit Badge
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .fill(AppColors.mint)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                        
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .frame(width: 100, height: 100)
                        }
                        .onTapGesture {
                            // TODO: Image picker
                        }
                        
                        Text("Change Profile Photo")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.mint)
                    }
                    .padding(.top, 20)

                    // Form Fields
                    VStack(spacing: 24) {
                        SettingsSectionView(title: "Basic Info") {
                            SettingsTextFieldRow(title: "Name", placeholder: "Your name", text: $fullName)
                            Divider().padding(.leading, 20)
                            SettingsTextFieldRow(title: "Username", placeholder: "@username", text: $username)
                            Divider().padding(.leading, 20)
                            SettingsTextFieldRow(title: "Pronouns", placeholder: "they/them", text: $pronouns)
                        }
                        
                        SettingsSectionView(title: "About You") {
                            SettingsTextFieldRow(title: "Bio", placeholder: "Tell us about yourself", text: $bio)
                            Divider().padding(.leading, 20)
                            SettingsTextFieldRow(title: "Location", placeholder: "City, Country", text: $location)
                            Divider().padding(.leading, 20)
                            SettingsTextFieldRow(title: "Website", placeholder: "https://", text: $website)
                        }
                    }

                    // Save Button
                    Button(action: saveProfile) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save Changes")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "1FC9C3"), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "1FC9C3").opacity(0.25), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.7 : 1.0)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Edit Profile")
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
        .onAppear {
            loadUserData()
        }
        .alert("Profile Updated", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your profile information has been saved successfully.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Failed to update profile")
        }
    }
    
    private func loadUserData() {
        guard let user = appEnvironment.currentUser else { return }
        
        fullName = user.fullName ?? ""
        username = user.username ?? ""
        pronouns = user.pronouns ?? ""
        bio = user.bio ?? ""
        location = user.location ?? ""
        website = user.links?.first ?? "" // Taking first link for now
    }
    
    private func saveProfile() {
        guard let userId = appEnvironment.currentUser?.id else { return }
        
        isLoading = true
        
        Task {
            do {
                let updates = ProfileUpdate(
                    fullName: fullName.isEmpty ? nil : fullName,
                    username: username.isEmpty ? nil : username,
                    pronouns: pronouns.isEmpty ? nil : pronouns,
                    bio: bio.isEmpty ? nil : bio,
                    location: location.isEmpty ? nil : location,
                    links: website.isEmpty ? nil : website, // Simplified for now
                    avatarUrl: nil, // TODO: Handle image upload
                    birthday: nil,
                    categoryPreferences: nil
                )
                
                let updatedUser = try await appEnvironment.profileService.updateProfile(userId: userId, updates: updates)
                
                await MainActor.run {
                    appEnvironment.currentUser = updatedUser
                    isLoading = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}
