//
//  ProfileStepViews.swift
//  PingNative
//
//  Profile-related step views for onboarding (name, birthday, username)
//

import SwiftUI

// MARK: - Name Step
struct NameStepView: View {
    @Binding var fullName: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your name?")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("We use your name so friends can recognize and connect with you easily.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 8) {
                TextField("Enter your full name", text: $fullName)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.words)
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(20)
                    .onAppear {
                        isFocused = true
                    }

                if let error = errors["fullName"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Birthday Step
struct BirthdayStepView: View {
    @Binding var birthday: Date
    @Binding var showDatePicker: Bool
    let errors: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("When's your birthday?")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("Your birthday helps us verify your age and provide age-appropriate content.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 8) {
                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Text(formatDate(birthday))
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.mint)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(16)
                }

                if let error = errors["birthday"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(birthday: $birthday, showDatePicker: $showDatePicker)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var birthday: Date
    @Binding var showDatePicker: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header with Close Button
            HStack {
                Spacer()
                Button(action: {
                    showDatePicker = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(10)
                        .background(Color(hex: "F3F4F6"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)

            // Icon & Title
            VStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 44))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, 4)

                Text("Select Birthday")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.top, 8)
            .padding(.bottom, 20)

            // Date Picker
            DatePicker("", selection: $birthday, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 24)

            Spacer()

            // CTA Button
            Button(action: {
                showDatePicker = false
            }) {
                Text("Done")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
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
                            .stroke(Color(hex: "1FC9C3"), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Color.white)
    }
}

// MARK: - Username Step
struct UsernameStepView: View {
    @Binding var username: String
    var usernameAvailable: Bool?
    let errors: [String: String]
    let onUsernameChanged: (String) -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your username")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Text("Your username is your unique identity on Ping.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 12) {
                TextField("Enter username", text: $username)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(20)
                    .onChange(of: username) { newValue in
                        onUsernameChanged(newValue)
                    }
                    .onAppear {
                        isFocused = true
                    }

                if let error = errors["username"] {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color(hex: "EF4444"))
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "EF4444"))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "FEE2E2"))
                    .cornerRadius(12)
                }

                if let available = usernameAvailable {
                    HStack {
                        Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(.white)
                        Text(available ? "Username is available!" : "Username is already taken")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(available ? Color(hex: "10B981") : Color(hex: "EF4444"))
                    .cornerRadius(12)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Marketing Step
struct MarketingStepView: View {
    let titlePart1: String
    let highlightedText: String
    let titlePart2: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            (Text(titlePart1) +
             Text(highlightedText)
                .foregroundColor(AppColors.mint) +
             Text(titlePart2))
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle)
                .font(.system(size: 20))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .font(.system(size: 36, weight: .regular))
        .foregroundColor(AppColors.textPrimary)
    }
}
