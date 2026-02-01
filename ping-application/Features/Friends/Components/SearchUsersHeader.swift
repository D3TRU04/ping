//
//  SearchUsersHeader.swift
//  PingNative
//
//  Header component for user search screen
//

import SwiftUI

struct SearchUsersHeader: View {
    @Binding var searchQuery: String
    @FocusState var isFocused: Bool
    let onDismiss: () -> Void
    let onSearchChange: () -> Void

    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onDismiss) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            }

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppColors.textTertiary)

                TextField("Search users...", text: $searchQuery)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .onChange(of: searchQuery) { _ in
                        onSearchChange()
                    }

                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.8))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [backgroundColor.opacity(0.9), backgroundColor.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct SearchUsersBackgroundView: View {
    var body: some View {
        GeometryReader { _ in
            ZStack {
                Circle()
                    .fill(Color(hex: "6EE7E7").opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: -100, y: -100)

                Circle()
                    .fill(Color(hex: "1FC9C3").opacity(0.1))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(x: 150, y: 100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}
