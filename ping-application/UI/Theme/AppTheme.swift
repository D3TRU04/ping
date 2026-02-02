//
//  AppTheme.swift
//  PingNative
//
//  Created on 12/3/25.
//

import SwiftUI

/// App-wide theme constants
struct AppTheme {
    // Colors
    static let primaryColor = Color.black
    static let secondaryColor = Color.gray
    static let backgroundColor = Color(hex: "FAFAFA")
    static let cardBackgroundColor = Color.white
    
    // Spacing
    static let padding: CGFloat = 24
    static let cornerRadius: CGFloat = 32
    
    // Typography
    static let titleFont = Font.system(size: 32, weight: .regular, design: .default)
    static let headlineFont = Font.system(size: 18, weight: .regular, design: .default)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
}

// MARK: - ScreenContainer
/// Screen-level layout container that owns all outer margins
/// Use this at the root of each screen to ensure consistent containment
struct ScreenContainer<Content: View>: View {
    let content: Content
    var horizontalPadding: CGFloat = 20
    var topPadding: CGFloat = 8
    var bottomPadding: CGFloat = 16

    init(
        horizontalPadding: CGFloat = 20,
        topPadding: CGFloat = 8,
        bottomPadding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.horizontalPadding = horizontalPadding
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.content = content()
    }

    var body: some View {
        content
            // MARK: SafeArea Handling
            .safeAreaPadding(.top, topPadding)
            .safeAreaPadding(.bottom, bottomPadding)
            .padding(.horizontal, horizontalPadding)
    }
}

// MARK: - LIQUID GLASS SYSTEM

/// Core glass primitive
struct GlassSurface<Content: View>: View {
    var cornerRadius: CGFloat = 32
    var opacity: CGFloat = 0.08 // Default for cards
    let content: Content

    init(cornerRadius: CGFloat = 32, opacity: CGFloat = 0.08, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.opacity = opacity
        self.content = content()
    }

    var body: some View {
        content
            .background(
                ZStack {
                    // 1. Base Material
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // 2. Translucent Overlay (Tint)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(opacity + 0.06),
                                    .white.opacity(opacity)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // 3. Specular Highlight (Top-Left Sheen)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.15),
                                    .white.opacity(0.04),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )

                    // 4. Inner Depth (Subtle inner shadow simulation)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.black.opacity(0.06), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                        .padding(1)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            // MARK: Apple Liquid Glass Border
            .overlay(
                ZStack {
                    // Outer luminous border - bright top-left, fading around
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.95), location: 0.0),
                                    .init(color: .white.opacity(0.7), location: 0.2),
                                    .init(color: .white.opacity(0.4), location: 0.5),
                                    .init(color: .white.opacity(0.5), location: 0.8),
                                    .init(color: .white.opacity(0.8), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                    // Inner glow for depth
                    RoundedRectangle(cornerRadius: cornerRadius - 1, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .padding(1)
                }
            )
            // Soft Ambient Shadow
            .shadow(color: Color.black.opacity(0.15), radius: 32, x: 0, y: 16)
    }
}

// Modifier for easy application
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 32
    var opacity: CGFloat = 0.08
    
    func body(content: Content) -> some View {
        GlassSurface(cornerRadius: cornerRadius, opacity: opacity) {
            content
        }
    }
}

extension View {
    func glassCardStyle(cornerRadius: CGFloat = 32, opacity: CGFloat = 0.08) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - Components

/// Glass Pill for Tags/Chips
struct GlassPill: View {
    let text: String
    var icon: String? = nil
    var isActive: Bool = false
    var color: Color = AppColors.mint
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .regular))
            }
            Text(text)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .lineLimit(1) // Prevent wrapping
                .fixedSize(horizontal: true, vertical: false) // Force horizontal expansion
                .minimumScaleFactor(1.0) // Do NOT shrink text
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Group {
                if isActive {
                    ZStack {
                        Capsule().fill(.ultraThinMaterial)
                        color.opacity(0.15) // Tint
                    }
                } else {
                    Capsule().fill(.ultraThinMaterial)
                }
            }
        )
        .clipShape(Capsule())
        // MARK: Apple Liquid Glass Border
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.85), location: 0.0),
                            .init(color: .white.opacity(0.5), location: 0.4),
                            .init(color: .white.opacity(0.4), location: 0.7),
                            .init(color: .white.opacity(0.6), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

/// Glass Circle Button for Icons
struct GlassCircleButton: View {
    let icon: String
    var isActive: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(isActive ? .white : AppColors.textPrimary)
                .frame(width: 48, height: 48)
                .background(
                    Group {
                        if isActive {
                            ZStack {
                                Circle().fill(.ultraThinMaterial)
                                AppColors.mint.opacity(0.8)
                            }
                        } else {
                            GlassSurface(cornerRadius: 24, opacity: 0.05) {
                                Color.clear
                            }
                        }
                    }
                )
                .clipShape(Circle())
                // MARK: Apple Liquid Glass Border
                .overlay(
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
                                lineWidth: 2
                            )
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            .padding(1)
                    }
                )
                .shadow(
                    color: isActive ? AppColors.mint.opacity(0.4) : Color.black.opacity(0.08),
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.9))
    }
}

/// Glass Dock (Bottom Bar Container)
struct GlassDock<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                GlassSurface(cornerRadius: 44, opacity: 0.12) {
                    Color.clear
                }
            )
            .clipShape(Capsule())
            // MARK: Apple Liquid Glass Border
            .overlay(
                ZStack {
                    // Outer luminous border
                    Capsule()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.95), location: 0.0),
                                    .init(color: .white.opacity(0.7), location: 0.2),
                                    .init(color: .white.opacity(0.4), location: 0.5),
                                    .init(color: .white.opacity(0.5), location: 0.8),
                                    .init(color: .white.opacity(0.85), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                    // Inner glow
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .padding(1)
                }
            )
            .padding(.horizontal, 24) // Margin from edges
            .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 12)
    }
}

// MARK: - Legacy Adapters (For compatibility with existing code)

struct GlassPillButton: View {
    let title: String
    var icon: String? = nil
    var isActive: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .regular))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .lineLimit(1) // MARK: Fix text wrapping
                    .fixedSize(horizontal: true, vertical: false) // MARK: Force horizontal expansion
                    .minimumScaleFactor(1.0) // Do NOT shrink text
            }
            .foregroundColor(isActive ? .white : AppColors.textPrimary.opacity(0.85))
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Group {
                    if isActive {
                        ZStack {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(.ultraThinMaterial)
                            
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7").opacity(0.8), Color(hex: "1FC9C3").opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    } else {
                        GlassSurface(cornerRadius: 30, opacity: 0.05) {
                            Color.clear
                        }
                    }
                }
            )
            .clipShape(Capsule())
            // MARK: Apple Liquid Glass Border
            .overlay(
                ZStack {
                    Capsule()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(isActive ? 1.0 : 0.9), location: 0.0),
                                    .init(color: .white.opacity(isActive ? 0.8 : 0.6), location: 0.3),
                                    .init(color: .white.opacity(isActive ? 0.5 : 0.35), location: 0.6),
                                    .init(color: .white.opacity(isActive ? 0.7 : 0.6), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .padding(1)
                }
            )
            .shadow(
                color: isActive ? Color(hex: "1FC9C3").opacity(0.4) : Color.black.opacity(0.08),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
    }
}

struct GlassIconCircleButtonAdapter: View { // Renamed to avoid conflict if needed, or kept as Alias
    // Keeping original name in file as GlassIconCircleButton is used in other files
    // The content is identical to the new one above
    let icon: String
    var isActive: Bool = false
    var action: () -> Void
    
    var body: some View {
        GlassCircleButton(icon: icon, isActive: isActive, action: action)
    }
}

// MARK: - Backgrounds

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            // LAYER 1: Base Atmospheric Gradient (Editorial foundation)
            LinearGradient(
                colors: [
                    Color(hex: "EBF4FF"), // Very pale blue
                    Color(hex: "F5F3FF"), // Pale lavender
                    Color(hex: "FFF1F2")  // Pale rose
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // LAYER 2: Primary Liquid Pools (The "Ink" drops)
            GeometryReader { proxy in
                let size = proxy.size
                ZStack {
                    // Pool 1: Deep Aqua/Teal (Top Left)
                    RadialGradient(
                        colors: [
                            Color(hex: "2DD4BF").opacity(0.35),
                            Color(hex: "2DD4BF").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size.width * 0.6
                    )
                    .frame(width: size.width * 1.2, height: size.width * 1.2)
                    .offset(x: -size.width * 0.3, y: -size.height * 0.15)
                    .blur(radius: 60)
                    
                    // Pool 2: Rich Lavender/Purple (Center Right)
                    RadialGradient(
                        colors: [
                            Color(hex: "A78BFA").opacity(0.32),
                            Color(hex: "A78BFA").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size.width * 0.55
                    )
                    .frame(width: size.width * 1.1, height: size.width * 1.1)
                    .offset(x: size.width * 0.35, y: size.height * 0.1)
                    .blur(radius: 60)
                    
                    // Pool 3: Soft Peach/Pink (Bottom Left)
                    RadialGradient(
                        colors: [
                            Color(hex: "FB7185").opacity(0.28),
                            Color(hex: "FB7185").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size.width * 0.6
                    )
                    .frame(width: size.width * 1.2, height: size.width * 1.2)
                    .offset(x: -size.width * 0.2, y: size.height * 0.45)
                    .blur(radius: 60)
                    
                    // Pool 4: Cyan/Mint Highlight (Top Center Accent)
                    RadialGradient(
                        colors: [
                            Color(hex: "67E8F9").opacity(0.25),
                            Color(hex: "67E8F9").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size.width * 0.4
                    )
                    .frame(width: size.width * 0.8, height: size.width * 0.8)
                    .offset(x: size.width * 0.1, y: -size.height * 0.2)
                    .blur(radius: 50)
                }
            }
            .ignoresSafeArea()
            
            // LAYER 3: Unifying Angled Overlay (Glass dispersion effect)
            LinearGradient(
                colors: [
                    Color.white.opacity(0.4),
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.overlay)
            .ignoresSafeArea()
            
            // LAYER 4: Atmospheric Blur (De-banding)
            Color.clear
                .background(.ultraThinMaterial)
                .opacity(0.3)
                .ignoresSafeArea()
        }
    }
}
