//
//  HomeTopNavBar.swift
//  PingNative
//
//  Clean top navigation bar matching Profile screen style
//

import SwiftUI

struct HomeTopNavBar: View {
    let currentUser: User?
    let onProfileTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            // Logo from Assets (2.png)
            Image("2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 44)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4) // Lift logo off background
            
            Spacer()
            
            // Profile picture button
            Button(action: onProfileTap) {
                profileImage
                    .frame(width: 40, height: 40) // Slightly smaller to fit in bubble
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                    .padding(6) // Space between image and glass edge
                    .background(
                        GlassSurface(cornerRadius: 26, opacity: 0.06) {
                            Color.clear
                        }
                    )
                    // Extra specular highlight on the container
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                            .padding(1)
                    )
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.95))
        }
        // MARK: - Layout Spacing (Parent container handles horizontal padding)
        .padding(.bottom, 12)
        // Navbar background is handled by the ZStack below
        .background(Color.clear)
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
