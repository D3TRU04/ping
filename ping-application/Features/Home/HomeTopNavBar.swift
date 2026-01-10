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
            Image("logo2") // Add logo2.png to Assets.xcassets
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 32)
            
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
                            .foregroundColor(.gray)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
