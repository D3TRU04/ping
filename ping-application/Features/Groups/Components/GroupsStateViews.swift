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
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
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
            .padding(.top, 8)

            Spacer()
        }
    }
}
