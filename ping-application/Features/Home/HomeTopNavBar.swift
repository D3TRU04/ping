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
                .frame(height: 72)
            
            Spacer()
            
            // Profile picture button
            Button(action: onProfileTap) {
                profileImage
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
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
                    ProgressView()
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "F3F4F6"))
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
            Color(hex: "F3F4F6")
            Image(systemName: "person.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.textTertiary)
        }
    }
}
