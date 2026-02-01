//
//  GroupsStateViews.swift
//  PingNative
//
//  Loading and empty state views for groups
//

import SwiftUI

struct GroupsLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                .scaleEffect(1.2)
            Text("Loading groups...")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }
}

struct GroupsEmptyStateView: View {
    let onCreateGroup: () -> Void

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

                Image(systemName: "person.3")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }

            VStack(spacing: 8) {
                Text("No Groups Yet")
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Create a group to see common places with friends")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button(action: onCreateGroup) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                    Text("Create Group")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
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
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
            }
            .padding(.top, 8)

            Spacer()
        }
    }
}
