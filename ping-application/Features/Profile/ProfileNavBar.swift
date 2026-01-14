//
//  ProfileNavBar.swift
//  PingNative
//
//  Created on 2025-01-13
//

import SwiftUI

struct ProfileNavBar: View {
    let onSettingsTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Text("Profile")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Button(action: onSettingsTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 0)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [Color(hex: "FAFAFA").opacity(0.95), Color(hex: "FAFAFA").opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
