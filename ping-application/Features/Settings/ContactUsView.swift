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
                            .font(.system(size: 17, weight: .regular, design: .rounded))
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
        .navigationTitle("Contact Us")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .regular))
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
                        .foregroundColor(AppColors.textTertiary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}
