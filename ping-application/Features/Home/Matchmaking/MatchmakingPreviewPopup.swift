//
//  MatchmakingPreviewPopup.swift
//  PingNative
//
//  Preview popup shown after matchmaking rounds are complete
//

import SwiftUI

struct MatchmakingPreviewPopup: View {
    let places: [Place]
    let selectedThemes: [String]
    let isLoadingMoreRounds: Bool
    let onAccept: () -> Void
    let onKeepPlaying: () -> Void

    // Get unique themes for display (deduplicated, preserving order)
    private var uniqueThemes: [String] {
        var seen = Set<String>()
        return selectedThemes.filter { seen.insert($0).inserted }
    }

    var body: some View {
        ZStack {
            // Background provided by parent (or default to glass if presented in sheet)
            LiquidGlassBackground()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    Text("Your Picks Today")
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text("Based on your choices, here's what we found")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 20)

                // Selected themes pills
                if !uniqueThemes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(uniqueThemes.prefix(8), id: \.self) { theme in
                                Text(theme)
                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        LinearGradient(
                                            colors: MatchmakingColorUtils.getSubcategoryGradient(theme),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 16)
                }

                // Places preview list
                if places.isEmpty {
                    VStack(spacing: 14) {
                        ProgressView()
                        Text("Finding places for you...")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(places.prefix(5), id: \.id) { place in
                                MatchmakingPreviewPlaceCard(place: place)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }

                Spacer(minLength: 16)

                // Action buttons
                VStack(spacing: 12) {
                    // Accept button - glass style
                    Button(action: onAccept) {
                        Text("Looks Good!")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
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
                    .buttonStyle(ScaleButtonStyle(scale: 0.96))

                    // Keep playing button - secondary action
                    Button(action: onKeepPlaying) {
                        HStack(spacing: 8) {
                            if isLoadingMoreRounds {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(AppColors.textSecondary)
                            }
                            Text(isLoadingMoreRounds ? "Loading..." : "Not quite right? Keep playing")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textPrimary.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            ZStack {
                                Color.white.opacity(0.15)
                                Color.white.opacity(0.3)
                            }
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle(scale: 0.96))
                    .disabled(isLoadingMoreRounds)
                    .opacity(isLoadingMoreRounds ? 0.6 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
