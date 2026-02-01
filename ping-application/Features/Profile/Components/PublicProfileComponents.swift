//
//  PublicProfileComponents.swift
//  PingNative
//
//  UI components for public profile view
//

import SwiftUI

// MARK: - Mutual Follow Buttons
struct PublicProfileMutualButtons: View {
    let sharedWantToTryCount: Int
    let sharedBeenCount: Int
    let onShowSharedWantToTry: () -> Void
    let onShowSharedBeen: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onShowSharedWantToTry) {
                HStack(spacing: 10) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 16))
                    Text("Shared Want to Try")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    Text("\(sharedWantToTryCount)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.mint.opacity(0.2))
                        .clipShape(Capsule())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(AppColors.mint)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppColors.mint.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(action: onShowSharedBeen) {
                HStack(spacing: 10) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16))
                    Text("Shared Been")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    Text("\(sharedBeenCount)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.mint.opacity(0.2))
                        .clipShape(Capsule())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(AppColors.mint)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppColors.mint.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}

// MARK: - Top Nav Bar
struct PublicProfileTopNavBar: View {
    let userName: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            }

            Text("@\(userName)")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 0)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "FAFAFA").opacity(0.95), Color(hex: "FAFAFA").opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
