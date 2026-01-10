//
//  HomeTopNavBar.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/components/NavBar.tsx
//  Top navigation bar for Home screen
//

import SwiftUI

struct HomeTopNavBar: View {
    let currentUser: User?
    let onProfileTap: () -> Void
    
    var body: some View {
        HStack {
            // Logo
            Image("logo2") // Ensure this asset exists or fallback to text
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 28)
            
            Spacer()
            
            // Profile picture button
            Button(action: onProfileTap) {
                if let avatar = currentUser?.profilePicture, let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.borderSubtle, lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, AppTheme.padding)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(AppColors.background)
    }
}
