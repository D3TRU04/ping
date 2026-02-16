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
                        .foregroundColor(AppColors.textPrimary)

                    Text("Directions")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity)
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
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.7), location: 0.3),
                                    .init(color: .white.opacity(0.5), location: 0.6),
                                    .init(color: .white.opacity(0.8), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, 8)
    }
}
