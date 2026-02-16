//
//  AccountInfoView.swift
//  PingNative
//
//  Account information editing view
//
//  Related files:
//  - AccountInfoView+Form.swift - Form data loading and saving
//

import SwiftUI

struct AccountInfoView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss

    @State var fullName: String = ""
    @State var username: String = ""
    @State var pronouns: String = ""
    @State var bio: String = ""
    @State var location: String = ""
    @State var website: String = ""

    @State var isLoading = false
    @State var showSuccessAlert = false
    @State var errorMessage: String?
    @State var showErrorAlert = false
    @State var showingImagePicker = false
    @State var inputImage: UIImage?

    var body: some View {
        ZStack {
            LiquidGlassBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    profilePictureSection
                    formFieldsSection
                    saveButton
                    Spacer().frame(height: 40)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit Profile")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                GlassCircleButton(icon: "chevron.left", action: { dismiss() })
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

    private var profilePictureSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "F3F4F6"))
                    .frame(width: 100, height: 100)

                if let inputImage = inputImage {
                    Image(uiImage: inputImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else if let avatarUrl = appEnvironment.currentUser?.profilePicture, let url = URL(string: avatarUrl) {
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
                showingImagePicker = true
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }

            Text("Change Profile Photo")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.mint)
        }
        .padding(.top, 20)
    }

    private var formFieldsSection: some View {
        VStack(spacing: 24) {
            SettingsSectionView(title: "Basic Info") {
                SettingsTextFieldRow(title: "Name", placeholder: "Your name", text: $fullName)
                Divider().padding(.leading, 20)
                SettingsTextFieldRow(title: "Username", placeholder: "@username", text: $username)
                Divider().padding(.leading, 20)
                SettingsTextFieldRow(title: "Pronouns", placeholder: "they/them", text: $pronouns)
            }

            SettingsSectionView(title: "About You") {
                SettingsTextFieldRow(title: "Location", placeholder: "City, Country", text: $location)
            }
        }
    }

    private var saveButton: some View {
        Button(action: saveProfile) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.textPrimary))
                } else {
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                }
            }
            .foregroundColor(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    Capsule().fill(Color.white.opacity(0.12))
                    Capsule().fill(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.2), location: 0.0),
                                .init(color: .white.opacity(0.05), location: 0.3),
                                .init(color: .white.opacity(0.0), location: 0.5),
                                .init(color: .white.opacity(0.02), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    Capsule().fill(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                }
            )
            .clipShape(Capsule())
            .overlay(
                ZStack {
                    Capsule()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.7), location: 0.3),
                                    .init(color: .white.opacity(0.5), location: 0.6),
                                    .init(color: .white.opacity(0.85), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    Capsule()
                        .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                        .padding(1)
                }
            )
            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
        .padding(.horizontal, 24)
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
}
