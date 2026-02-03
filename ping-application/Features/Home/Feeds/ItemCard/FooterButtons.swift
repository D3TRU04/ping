//
//  FooterButtons.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/item-card/components/FooterButtons.tsx
//  Footer buttons (directions, call)
//

import SwiftUI

struct FooterButtons: View {
    let placeName: String
    let onDirections: () -> Void
    let onCall: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Directions Button (Primary)
            Button(action: onDirections) {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    Text("Directions")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
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
                        .stroke(Color(hex: "1FC9C3"), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Call Button (Secondary)
            Button(action: onCall) {
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.mint)
                    
                    Text("Call")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.mint)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    GlassSurface(cornerRadius: 30, opacity: 0.05) { Color.clear }
                )
                .clipShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, 8)
    }
}
