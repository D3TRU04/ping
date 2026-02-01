//
//  SearchUsersStateViews.swift
//  PingNative
//
//  State views for user search screen
//

import SwiftUI

struct SearchUsersLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                .scaleEffect(1.2)
            Text("Searching users...")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }
}

struct SearchUsersEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7").opacity(0.1), Color(hex: "1FC9C3").opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 10)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }

            VStack(spacing: 8) {
                Text("Discover People")
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Find friends and see what they're up to")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SearchUsersNoResultsView: View {
    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 80, height: 80)

                Image(systemName: "person.slash")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }

            VStack(spacing: 4) {
                Text("No users found")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Try a different search")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
        }
    }
}
