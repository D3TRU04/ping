//
//  BirthdayStepView.swift
//  PingNative
//
//  Birthday input step view for onboarding
//

import SwiftUI

struct BirthdayStepView: View {
    @Binding var birthday: Date
    @Binding var showDatePicker: Bool
    let errors: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("When's your birthday?")
                    .font(.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Your birthday helps us verify your age and provide age-appropriate content.")
                    .font(.system(size: 16, design: .rounded))
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
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.mint)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .glassInputStyle()
                }

                if let error = errors["birthday"] {
                    Text(error)
                        .font(.system(size: 14, design: .rounded))
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
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(10)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(0.9), location: 0.0),
                                            .init(color: .white.opacity(0.5), location: 0.5),
                                            .init(color: .white.opacity(0.7), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
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
                    .font(.system(size: 24, weight: .regular, design: .rounded))
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
            GlassCTAButton(title: "Done") {
                showDatePicker = false
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Color.white)
    }
}
