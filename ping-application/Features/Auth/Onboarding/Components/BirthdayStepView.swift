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
                        .font(.system(size: 14, weight: .regular))
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
                    .font(.system(size: 18, weight: .regular))
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
