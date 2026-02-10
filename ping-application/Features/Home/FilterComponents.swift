//
//  FilterComponents.swift
//  PingNative
//
//  Filter UI components for the ForYou feed
//
//  Related files:
//  - FilterSheet.swift - Main filter sheet view
//

import SwiftUI

// MARK: - Filter Section
struct FilterSection<Content: View>: View {
    let title: String
    let icon: String?
    @ViewBuilder let content: Content

    init(title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(AppColors.mint)
                        .frame(width: 24, alignment: .center)
                }
                Text(title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            content
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .regular))
                        .frame(width: 16, alignment: .center)
                }
                Text(title)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .background(
                Group {
                    if isSelected {
                        ZStack {
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
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
                    } else {
                        Color.white.opacity(0.15)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(0.9), location: 0.0),
                                            .init(color: .white.opacity(0.5), location: 0.3),
                                            .init(color: .white.opacity(0.3), location: 0.6),
                                            .init(color: .white.opacity(0.7), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                : AnyShapeStyle(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(0.8), location: 0.0),
                                            .init(color: .white.opacity(0.4), location: 0.5),
                                            .init(color: .white.opacity(0.6), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                ),
                            lineWidth: isSelected ? 1 : 0.5
                        )
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            .padding(1)
                    }
                }
            )
            .shadow(
                color: isSelected ? Color(hex: "1FC9C3").opacity(0.35) : Color.black.opacity(0.05),
                radius: isSelected ? 20 : 8,
                x: 0,
                y: isSelected ? 10 : 4
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}
