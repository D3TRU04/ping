//
//  AccountInfoView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/settings/account-info/page.tsx (implied)
//  Account info settings screen
//

import SwiftUI
import UIKit
import Combine

struct AccountInfoView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = AccountInfoViewModel()
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
                    // Profile Picture Section
                    VStack(spacing: 16) {
                        Text("Profile Picture")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            viewModel.showImagePicker = true
                        }) {
                            if let image = viewModel.profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    
                    // Account Details Section
                    SettingsSection(title: "Account Details") {
                        SettingsTextFieldRow(
                            label: "Full Name",
                            text: $viewModel.fullName,
                            placeholder: "Enter your full name"
                        )
                        
                        SettingsTextFieldRow(
                            label: "Username",
                            text: $viewModel.username,
                            placeholder: "Enter username"
                        )
                        
                        SettingsTextFieldRow(
                            label: "Email",
                            text: $viewModel.email,
                            placeholder: "Enter email",
                            keyboardType: .emailAddress
                        )
                        
                        SettingsTextFieldRow(
                            label: "Phone",
                            text: $viewModel.phone,
                            placeholder: "Enter phone number",
                            keyboardType: .phonePad
                        )
                    }
                    
                    // Bio Section
                    SettingsSection(title: "Bio") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $viewModel.bio)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(hex: "F5F6FA"))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    // Save Button
                    Button(action: {
                        Task {
                            await viewModel.save(appEnvironment: appEnvironment)
                        }
                    }) {
                        if viewModel.saving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Text("Save Changes")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                    .background(AppColors.mint)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .disabled(viewModel.saving)
                }
                .padding(.vertical, 16)
            }
            
            // Top Nav Bar
            VStack {
                SettingsTopNavBar(title: "Account Info")
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.profileImage)
        }
        .task {
            await viewModel.load(appEnvironment: appEnvironment)
        }
    }
}

@MainActor
class AccountInfoViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var bio: String = ""
    @Published var profileImage: UIImage? = nil
    @Published var saving: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var errorMessage: String? = nil
    
    func load(appEnvironment: AppEnvironment) async {
        guard let userId = appEnvironment.currentUser?.id else { return }
        
        do {
            let profile = try await appEnvironment.profileService.fetchProfile(userId: userId)
            fullName = profile.fullName ?? ""
            username = profile.username ?? ""
            bio = profile.bio ?? ""
            
            if let user = appEnvironment.currentUser {
                email = user.email ?? ""
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func save(appEnvironment: AppEnvironment) async {
        guard let userId = appEnvironment.currentUser?.id else { return }
        
        saving = true
        errorMessage = nil
        
        do {
            var updates = ProfileUpdate()
            updates.fullName = fullName.isEmpty ? nil : fullName
            updates.username = username.isEmpty ? nil : username
            updates.bio = bio.isEmpty ? nil : bio
            
            // TODO: Upload profile image if changed
            
            let _ = try await appEnvironment.profileService.updateProfile(userId: userId, updates: updates)
            
            // Update current user
            let updatedProfile = try await appEnvironment.profileService.fetchProfile(userId: userId)
            // Update appEnvironment.currentUser with new profile data
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        saving = false
    }
}

struct SettingsTextFieldRow: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(.plain)
                .padding(8)
                .background(Color(hex: "F5F6FA"))
                .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

