//
//  LiquidGlassMaterial.swift
//  PingNative
//
//  Reusable 3-layer glass background with blur + animated sheen
//  Replaces static GlassSurface for nav bar and profile button
//

import SwiftUI

enum GlassShape {
    case capsule
    case circle
}

struct LiquidGlassMaterial: View {
    var shape: GlassShape = .capsule
    var glassIntensity: CGFloat = 0
    var distortionIntensity: CGFloat = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Animated sheen endpoint shifts based on distortion
    private var sheenStart: UnitPoint {
        let shift = distortionIntensity * 0.3
        return UnitPoint(x: 0.0 + shift, y: 0.0)
    }

    private var sheenEnd: UnitPoint {
        let shift = distortionIntensity * 0.3
        return UnitPoint(x: 1.0 - shift, y: 1.0)
    }

    var body: some View {
        ZStack {
            // Layer 1 — Real background blur via .ultraThinMaterial
            Group {
                switch shape {
                case .capsule:
                    Capsule().fill(.ultraThinMaterial)
                case .circle:
                    Circle().fill(.ultraThinMaterial)
                }
            }
            .opacity(0.3 + glassIntensity * 0.7) // Fades in with glass intensity

            // Layer 2 — White tint overlay
            Group {
                switch shape {
                case .capsule:
                    Capsule().fill(Color.white.opacity(0.35))
                case .circle:
                    Circle().fill(Color.white.opacity(0.35))
                }
            }

            // Layer 3 — Animated sheen (disabled when reduce motion is on)
            if !reduceMotion {
                Group {
                    switch shape {
                    case .capsule:
                        Capsule().fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.25), location: 0.0),
                                    .init(color: .white.opacity(0.05), location: 0.4),
                                    .init(color: .white.opacity(0.0), location: 0.6),
                                    .init(color: .white.opacity(0.15), location: 1.0)
                                ],
                                startPoint: sheenStart,
                                endPoint: sheenEnd
                            )
                        )
                    case .circle:
                        Circle().fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.25), location: 0.0),
                                    .init(color: .white.opacity(0.05), location: 0.4),
                                    .init(color: .white.opacity(0.0), location: 0.6),
                                    .init(color: .white.opacity(0.15), location: 1.0)
                                ],
                                startPoint: sheenStart,
                                endPoint: sheenEnd
                            )
                        )
                    }
                }
                .brightness(Double(distortionIntensity) * 0.05)
                .contrast(1.0 + Double(distortionIntensity) * 0.03)
                .animation(.easeOut(duration: 0.3), value: distortionIntensity)
            }
        }
        // Gradient border overlay
        .overlay(
            Group {
                switch shape {
                case .capsule:
                    ZStack {
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.95), location: 0.0),
                                        .init(color: .white.opacity(0.6), location: 0.3),
                                        .init(color: .white.opacity(0.4), location: 0.6),
                                        .init(color: .white.opacity(0.7), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        Capsule()
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                            .padding(1)
                    }
                case .circle:
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.95), location: 0.0),
                                        .init(color: .white.opacity(0.6), location: 0.3),
                                        .init(color: .white.opacity(0.4), location: 0.6),
                                        .init(color: .white.opacity(0.7), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                            .padding(1)
                    }
                }
            }
        )
        // Shadow
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .animation(.easeInOut(duration: 0.25), value: glassIntensity)
    }
}
