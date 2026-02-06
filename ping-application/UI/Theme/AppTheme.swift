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
                    // 1. Clear Glass Base (No Blur/Material)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white.opacity(0.12)) // Slightly increased opacity for visibility without blur

                    // 2. Reflective Sheen (Glossy Overlay)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
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

                    // 3. Specular Highlight (Sharp Top-Left Reflection)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.4),
                                    .white.opacity(0.1),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            // MARK: Apple Liquid Glass Border
            .overlay(
                ZStack {
                    // Crisp Glass Edge
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.7), location: 0.2),
                                    .init(color: .white.opacity(0.3), location: 0.5),
                                    .init(color: .white.opacity(0.6), location: 0.8),
                                    .init(color: .white.opacity(0.95), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    // Inner Rim for Depth
                    RoundedRectangle(cornerRadius: cornerRadius - 1, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                        .padding(1)
                }
            )
            // Crisp Shadow to lift off the vibrant background
            .shadow(color: Color.black.opacity(0.1), radius: 24, x: 0, y: 12)
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

// MARK: - Glass Input Field Modifier
struct GlassInputModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.18))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.9), location: 0.0),
                                .init(color: .white.opacity(0.5), location: 0.4),
                                .init(color: .white.opacity(0.3), location: 0.7),
                                .init(color: .white.opacity(0.7), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func glassInputStyle(cornerRadius: CGFloat = 20) -> some View {
        self.modifier(GlassInputModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Glass CTA Button
struct GlassCTAButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    // Mint gradient base
                    LinearGradient(
                        colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    // Glass sheen overlay
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.25), location: 0.0),
                            .init(color: .white.opacity(0.05), location: 0.4),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
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
                                    .init(color: .white.opacity(0.9), location: 0.0),
                                    .init(color: .white.opacity(0.5), location: 0.3),
                                    .init(color: .white.opacity(0.3), location: 0.6),
                                    .init(color: .white.opacity(0.7), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        .padding(1)
                }
            )
            .shadow(color: Color(hex: "1FC9C3").opacity(0.35), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.97))
        .disabled(isLoading || isDisabled)
        .opacity((isLoading || isDisabled) ? 0.6 : 1.0)
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
                        Capsule().fill(Color.white.opacity(0.25)) // Clear glass
                        color.opacity(0.2) // Increased tint for visibility
                    }
                } else {
                    Capsule().fill(Color.white.opacity(0.15)) // Clear glass
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
                            .init(color: .white.opacity(1.0), location: 0.0),
                            .init(color: .white.opacity(0.7), location: 0.4),
                            .init(color: .white.opacity(0.5), location: 0.7),
                            .init(color: .white.opacity(0.8), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
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
                                Circle().fill(Color.white.opacity(0.25))
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
                        Circle()
                            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
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
    var horizontalMargin: CGFloat

    init(horizontalMargin: CGFloat = 24, @ViewBuilder content: () -> Content) {
        self.horizontalMargin = horizontalMargin
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
                                    .init(color: .white.opacity(0.6), location: 0.0),
                                    .init(color: .white.opacity(0.4), location: 0.2),
                                    .init(color: .white.opacity(0.25), location: 0.5),
                                    .init(color: .white.opacity(0.3), location: 0.8),
                                    .init(color: .white.opacity(0.5), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                    // Inner glow
                    Capsule()
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                        .padding(0.5)
                }
            )
            .padding(.horizontal, horizontalMargin) // Margin from edges (configurable)
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
                                .fill(Color.white.opacity(0.25)) // Clear glass
                            
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
                            lineWidth: 1
                        )
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
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

// MARK: - TikTok-Style Tab View

struct TikTokTabView: View {
    @Binding var activeTab: SecondaryNavBarTab
    @Namespace private var tabNamespace

    var body: some View {
        HStack(spacing: 8) {
            tabButton(for: .forYou, title: "For You")
            tabButton(for: .today, title: "Today")
        }
    }

    private func tabButton(for tab: SecondaryNavBarTab, title: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                activeTab = tab
            }
        }) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: activeTab == tab ? .semibold : .regular, design: .rounded))
                    .foregroundColor(activeTab == tab ? AppColors.textPrimary : AppColors.textPrimary.opacity(0.5))

                // Animated underline indicator
                if activeTab == tab {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(AppColors.textPrimary)
                        .frame(width: 24, height: 2)
                        .matchedGeometryEffect(id: "tabIndicator", in: tabNamespace)
                } else {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.clear)
                        .frame(width: 24, height: 2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Backgrounds

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            // LAYER 1: Base Atmospheric Gradient (Richer foundation)
            LinearGradient(
                colors: [
                    Color(hex: "DCEEFF"), // Stronger pale blue
                    Color(hex: "E8E4FF"), // Stronger lavender
                    Color(hex: "FFE4E6")  // Stronger rose
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // LAYER 2: Primary Liquid Pools (Pronounced color blobs)
            GeometryReader { proxy in
                let size = proxy.size
                ZStack {
                    // Pool 1: Deep Aqua/Teal (Top Left)
                    RadialGradient(
                        colors: [
                            Color(hex: "2DD4BF").opacity(0.8),
                            Color(hex: "2DD4BF").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size.width * 0.5
                    )
                    .frame(width: size.width * 1.2, height: size.width * 1.2)
                    .offset(x: -size.width * 0.3, y: -size.height * 0.15)
                    .blur(radius: 30)

                    // Pool 2: Rich Lavender/Purple (Center Right)
                    RadialGradient(
                        colors: [
                            Color(hex: "A78BFA").opacity(0.75),
                            Color(hex: "A78BFA").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size.width * 0.45
                    )
                    .frame(width: size.width * 1.1, height: size.width * 1.1)
                    .offset(x: size.width * 0.35, y: size.height * 0.1)
                    .blur(radius: 30)

                    // Pool 3: Soft Peach/Pink (Bottom Left)
                    RadialGradient(
                        colors: [
                            Color(hex: "FB7185").opacity(0.7),
                            Color(hex: "FB7185").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size.width * 0.5
                    )
                    .frame(width: size.width * 1.2, height: size.width * 1.2)
                    .offset(x: -size.width * 0.2, y: size.height * 0.45)
                    .blur(radius: 30)

                    // Pool 4: Cyan/Mint Highlight (Top Center Accent)
                    RadialGradient(
                        colors: [
                            Color(hex: "67E8F9").opacity(0.65),
                            Color(hex: "67E8F9").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size.width * 0.38
                    )
                    .frame(width: size.width * 0.8, height: size.width * 0.8)
                    .offset(x: size.width * 0.1, y: -size.height * 0.2)
                    .blur(radius: 25)
                }
            }
            .ignoresSafeArea()

            // LAYER 3: Unifying Angled Overlay (Glass dispersion effect)
            LinearGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.overlay)
            .ignoresSafeArea()
        }
    }
}
