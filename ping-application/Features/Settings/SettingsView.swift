//
//  SettingsView.swift
//  PingNative
//
//  Settings screen with account options and logout
//

import SwiftUI
import Clerk

struct SettingsView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var environmentDismiss
    var onDismiss: (() -> Void)? = nil
    @State private var showingLogoutAlert = false
    @State private var isLoggingOut = false
    @State private var showingDeleteAccountAlert = false
    @State private var isDeletingAccount = false
    
    private func dismiss() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            environmentDismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FAFAFA")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Account Section
                        SettingsSectionView(title: "Account") {
                            NavigationLink(destination: AccountInfoView().environmentObject(appEnvironment)) {
                                SettingsRowContent(
                                    icon: "person.circle",
                                    title: "Account Info"
                                )
                            }
                            
                            Divider().padding(.leading, 64)
                            
                            NavigationLink(destination: NotificationsSettingsView()) {
                                SettingsRowContent(
                                    icon: "bell",
                                    title: "Notifications"
                                )
                            }
                            
                            Divider().padding(.leading, 64)
                            
                            NavigationLink(destination: PrivacySettingsView()) {
                                SettingsRowContent(
                                    icon: "lock",
                                    title: "Privacy"
                                )
                            }

                            Divider().padding(.leading, 64)

                            Button(action: {
                                showingDeleteAccountAlert = true
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "EF4444"))
                                        .frame(width: 28)

                                    Text("Delete Account")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(hex: "EF4444"))

                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                        }
                        
                        // Support Section
                        SettingsSectionView(title: "Support") {
                            NavigationLink(destination: HelpCenterView()) {
                                SettingsRowContent(
                                    icon: "questionmark.circle",
                                    title: "Help Center"
                                )
                            }
                            
                            Divider().padding(.leading, 64)
                            
                            NavigationLink(destination: ContactUsView()) {
                                SettingsRowContent(
                                    icon: "envelope",
                                    title: "Contact Us"
                                )
                            }
                        }
                        
                        // Logout Button
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            HStack {
                                if isLoggingOut {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Log Out")
                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "F87171"), Color(hex: "EF4444")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "DC2626"), lineWidth: 1.5)
                            )
                            .shadow(color: Color(hex: "EF4444").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .disabled(isLoggingOut)
                        
                        // App Version
                        Text("Version 1.0.0")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textTertiary)
                            .padding(.top, 24)
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    Task {
                        await logout()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.")
            }
        }
    }
    
    private func logout() async {
        isLoggingOut = true

        do {
            try await Clerk.shared.signOut()

            await MainActor.run {
                appEnvironment.currentUser = nil
                appEnvironment.isAuthenticated = false
                appEnvironment.needsOnboarding = false
                isLoggingOut = false
                dismiss()
            }
        } catch {
            print("❌ Logout failed: \(error.localizedDescription)")
            isLoggingOut = false
        }
    }

    private func deleteAccount() async {
        guard let userId = appEnvironment.currentUser?.id else { return }

        isDeletingAccount = true

        do {
            // Delete account from backend
            try await appEnvironment.profileService.deleteAccount(userId: userId)

            // Sign out from Clerk
            try await Clerk.shared.signOut()

            await MainActor.run {
                appEnvironment.currentUser = nil
                appEnvironment.isAuthenticated = false
                appEnvironment.needsOnboarding = false
                isDeletingAccount = false
                dismiss()
            }
        } catch {
            print("❌ Delete account failed: \(error.localizedDescription)")
            isDeletingAccount = false
        }
    }
}

// MARK: - Privacy Settings View
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

// MARK: - Help Center View
struct HelpCenterView: View {
    @Environment(\.dismiss) var dismiss
    
    let faqItems: [(question: String, answer: String)] = [
        ("How do I edit my profile?", "Go to your profile page and tap 'Edit Profile' to update your information, bio, and profile picture."),
        ("How do I save a place?", "When viewing a place, tap the bookmark icon to save it to your collection."),
        ("How do I follow someone?", "Visit their profile and tap the 'Follow' button to start following them."),
        ("How do I change my password?", "Go to Settings > Account Info > Change Password to update your password."),
        ("How do I report a problem?", "Use the Contact Us option in Settings to report any issues you encounter.")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "FAFAFA")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Search Bar Placeholder
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text("Search help articles...")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textTertiary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // FAQ Section
                    SettingsSectionView(title: "Frequently Asked Questions") {
                        ForEach(Array(faqItems.enumerated()), id: \.offset) { index, item in
                            if index > 0 {
                                Divider().padding(.leading, 20)
                            }
                            FAQItemView(question: item.question, answer: item.answer)
                        }
                    }
                    
                    // Quick Links
                    SettingsSectionView(title: "Quick Links") {
                        QuickLinkRow(icon: "book.fill", title: "User Guide", url: "https://ping.app/guide")
                        Divider().padding(.leading, 64)
                        QuickLinkRow(icon: "shield.fill", title: "Privacy Policy", url: "https://ping.app/privacy")
                        Divider().padding(.leading, 64)
                        QuickLinkRow(icon: "doc.text.fill", title: "Terms of Service", url: "https://ping.app/terms")
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Help Center")
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

struct FAQItemView: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct QuickLinkRow: View {
    let icon: String
    let title: String
    let url: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.mint)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Contact Us View
struct ContactUsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var selectedCategory = "General"
    @State private var showingSuccessAlert = false
    
    let categories = ["General", "Bug Report", "Feature Request", "Account Issue", "Other"]
    
    var body: some View {
        ZStack {
            Color(hex: "FAFAFA")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Category Picker
                    SettingsSectionView(title: "Category") {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    
                    // Subject
                    SettingsSectionView(title: "Subject") {
                        TextField("Brief description of your issue", text: $subject)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                    }
                    
                    // Message
                    SettingsSectionView(title: "Message") {
                        TextEditor(text: $message)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .frame(minHeight: 150)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .scrollContentBackground(.hidden)
                    }
                    
                    // Submit Button
                    Button(action: {
                        submitContactForm()
                    }) {
                        Text("Send Message")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
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
                    .disabled(subject.isEmpty || message.isEmpty)
                    .opacity(subject.isEmpty || message.isEmpty ? 0.6 : 1.0)
                    
                    // Alternative Contact Methods
                    SettingsSectionView(title: "Other Ways to Reach Us") {
                        Button(action: {
                            if let url = URL(string: "mailto:support@ping.app") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppColors.mint)
                                    .frame(width: 28)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Email Us")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    Text("support@ping.app")
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                        
                        Divider().padding(.leading, 64)
                        
                        Button(action: {
                            if let url = URL(string: "https://twitter.com/pingapp") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "bubble.left.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppColors.mint)
                                    .frame(width: 28)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Twitter / X")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    Text("@pingapp")
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Contact Us")
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
        .alert("Message Sent", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you for contacting us. We'll get back to you soon!")
        }
    }
    
    private func submitContactForm() {
        // TODO: Send contact form to backend
        print("📧 Contact form submitted:")
        print("   Category: \(selectedCategory)")
        print("   Subject: \(subject)")
        print("   Message: \(message)")
        
        showingSuccessAlert = true
    }
}