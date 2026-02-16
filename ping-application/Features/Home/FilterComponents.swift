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
            .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.18))
                        RoundedRectangle(cornerRadius: 20).fill(
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
                        RoundedRectangle(cornerRadius: 20).fill(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                    } else {
                        RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.15))
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
                                            .init(color: .white.opacity(1.0), location: 0.0),
                                            .init(color: .white.opacity(0.7), location: 0.3),
                                            .init(color: .white.opacity(0.5), location: 0.6),
                                            .init(color: .white.opacity(0.85), location: 1.0)
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
                            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                            .padding(1)
                    }
                }
            )
            .shadow(
                color: isSelected ? Color.black.opacity(0.1) : Color.black.opacity(0.05),
                radius: isSelected ? 12 : 8,
                x: 0,
                y: isSelected ? 6 : 4
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}
