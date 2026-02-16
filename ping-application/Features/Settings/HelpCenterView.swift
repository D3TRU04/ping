//
//  HelpCenterView.swift
//  PingNative
//
//  Help center with FAQ and quick links
//

import SwiftUI

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
            LiquidGlassBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Search Bar Placeholder
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textSecondary)

                        Text("Search help articles...")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .glassInputStyle(cornerRadius: 24)
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Help Center")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                GlassCircleButton(icon: "chevron.left", action: { dismiss() })
            }
        }
    }
}

// MARK: - FAQ Item View
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
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
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

// MARK: - Quick Link Row
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
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}
