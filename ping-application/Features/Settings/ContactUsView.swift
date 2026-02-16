//
//  ContactUsView.swift
//  PingNative
//
//  Contact form for user support
//

import SwiftUI

struct ContactUsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var selectedCategory = "General"
    @State private var showingSuccessAlert = false

    let categories = ["General", "Bug Report", "Feature Request", "Account Issue", "Other"]

    var body: some View {
        ZStack {
            LiquidGlassBackground()
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
                            .font(.system(size: 17, weight: .regular, design: .rounded))
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
                    .padding(.horizontal, 24)
                    .disabled(subject.isEmpty || message.isEmpty)
                    .opacity(subject.isEmpty || message.isEmpty ? 0.6 : 1.0)

                    // Alternative Contact Methods
                    SettingsSectionView(title: "Other Ways to Reach Us") {
                        ContactMethodRow(
                            icon: "envelope.fill",
                            title: "Email Us",
                            subtitle: "support@ping.app",
                            url: "mailto:support@ping.app"
                        )

                        Divider().padding(.leading, 64)

                        ContactMethodRow(
                            icon: "bubble.left.fill",
                            title: "Twitter / X",
                            subtitle: "@pingapp",
                            url: "https://twitter.com/pingapp"
                        )
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
                Text("Contact Us")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                GlassCircleButton(icon: "chevron.left", action: { dismiss() })
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
        print("Contact form submitted:")
        print("   Category: \(selectedCategory)")
        print("   Subject: \(subject)")
        print("   Message: \(message)")

        showingSuccessAlert = true
    }
}

// MARK: - Contact Method Row
struct ContactMethodRow: View {
    let icon: String
    let title: String
    let subtitle: String
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

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}
