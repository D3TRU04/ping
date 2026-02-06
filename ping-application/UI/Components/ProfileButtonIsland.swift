//
//  ProfileButtonIsland.swift
//  PingNative
//
//  Floating profile button island for bottom-right corner
//

import SwiftUI

struct ProfileButtonIsland: View {
    let currentUser: User?
    let onProfileTap: () -> Void
    var isProfileActive: Bool = false
    var glassIntensity: CGFloat = 0
    var distortionIntensity: CGFloat = 0

    var body: some View {
        Button(action: onProfileTap) {
            profileImage
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .overlay(
                    Group {
                        if isProfileActive {
                            Circle()
                                .stroke(AppColors.mint, lineWidth: 2)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isProfileActive)
                )
                .padding(8)
                .background(
                    LiquidGlassMaterial(
                        shape: .circle,
                        glassIntensity: glassIntensity,
                        distortionIntensity: distortionIntensity
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
        .safeAreaPadding(.bottom, 12)
    }

    @ViewBuilder
    private var profileImage: some View {
        if let avatar = currentUser?.profilePicture, let url = URL(string: avatar) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    defaultProfileImage
                case .empty:
                    ZStack {
                        Rectangle().fill(Color.white.opacity(0.15))
                        ProgressView().scaleEffect(0.8)
                    }
                @unknown default:
                    defaultProfileImage
                }
            }
        } else {
            defaultProfileImage
        }
    }

    private var defaultProfileImage: some View {
        ZStack {
            Rectangle().fill(Color.white.opacity(0.15))
            Color.white.opacity(0.2)
            Image(systemName: "person.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.textPrimary.opacity(0.6))
        }
    }
}
