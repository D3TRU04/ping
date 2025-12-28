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
            // Directions Button
            Button(action: onDirections) {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.mint)
                    
                    Text("Directions")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "F5F6FA"))
                .cornerRadius(16)
            }
            
            // Call Button
            Button(action: onCall) {
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    Text("Call")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.mint)
                .cornerRadius(16)
            }
        }
        .padding(.top, 8)
    }
}
