//
//  SwipeCardView.swift
//  PingNative
//
//  Single swipe card with drag gesture, rotation, and INTERESTED/SKIP labels
//

import SwiftUI

struct SwipeCardView: View {
    let card: SwipeCard
    let onSwipe: (SwipeDirection) -> Void

    @State private var offset: CGSize = .zero
    @State private var isGestureActive: Bool = false

    private let swipeThreshold: CGFloat = 100
    private let rotationMultiplier: Double = 20

    private var rotationAngle: Double {
        Double(offset.width) / rotationMultiplier
    }

    private var swipeProgress: CGFloat {
        min(abs(offset.width) / swipeThreshold, 1.0)
    }

    private var isSwipingRight: Bool {
        offset.width > 0
    }

    var body: some View {
        ZStack {
            cardContent
            swipeLabels
        }
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .background(
            GlassSurface(cornerRadius: 24) {
                Color.clear
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .offset(x: offset.width, y: offset.height * 0.3)
        .rotationEffect(.degrees(rotationAngle))
        .gesture(dragGesture)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7), value: offset)
    }

    // MARK: - Card Content

    private var cardContent: some View {
        VStack(spacing: 16) {
            Spacer()

            // Large emoji icon
            Text(subcategoryIcon(for: card.place.subcategory ?? "default"))
                .font(.system(size: 48))

            // Place name
            Text(card.place.name)
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Subcategory pill
            if let subcategory = card.place.subcategory {
                HStack(spacing: 6) {
                    Text(subcategory.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.white.opacity(0.2)))
            }

            // Description
            if let description = card.place.description {
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Spacer()

            // Rating and price row
            HStack(spacing: 16) {
                if let rating = card.place.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                if let priceRange = card.place.priceRange {
                    Text(String(repeating: "$", count: priceRange))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Swipe Labels

    private var swipeLabels: some View {
        ZStack {
            // INTERESTED label (right swipe)
            Text("INTERESTED")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(AppColors.success)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.success, lineWidth: 4)
                )
                .rotationEffect(.degrees(-15))
                .offset(x: -40, y: -150)
                .opacity(isSwipingRight ? Double(swipeProgress) : 0)

            // SKIP label (left swipe)
            Text("SKIP")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(AppColors.error)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.error, lineWidth: 4)
                )
                .rotationEffect(.degrees(15))
                .offset(x: 40, y: -150)
                .opacity(!isSwipingRight && offset.width != 0 ? Double(swipeProgress) : 0)
        }
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isGestureActive = true
                offset = value.translation
            }
            .onEnded { value in
                isGestureActive = false

                if abs(value.translation.width) > swipeThreshold {
                    let direction: SwipeDirection = value.translation.width > 0 ? .right : .left
                    withAnimation(.easeOut(duration: 0.3)) {
                        offset = CGSize(
                            width: value.translation.width > 0 ? 500 : -500,
                            height: value.translation.height
                        )
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSwipe(direction)
                        offset = .zero
                    }
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        offset = .zero
                    }
                }
            }
    }

    // MARK: - Helpers

    private func subcategoryIcon(for subcategory: String) -> String {
        // Map subcategory values to icons
        let iconMap: [String: String] = [
            "fast_food": "🍟", "seafood": "🦞", "desserts": "🍰", "vegan": "🥗",
            "japanese": "🍣", "chinese": "🥡", "italian": "🍝", "mexican": "🌮",
            "malls": "🏬", "boutiques": "👗", "farmers_markets": "🥕", "thrift": "👕",
            "painting": "🖌️", "pottery": "🏺", "diy": "🔨", "photography": "📸",
            "bars": "🍺", "clubs": "🎵", "karaoke": "🎤", "lounges": "🥂",
            "gym": "🏋️", "yoga": "🧘", "sports": "⚽", "swimming": "🏊",
            "hiking": "🥾", "parks": "🌳", "lakes": "🏞️", "camping": "⛺",
            "escape_rooms": "🔐", "bowling": "🎳", "arcades": "🕹️", "laser_tag": "🔫",
            "museums": "🏛️", "landmarks": "🗽", "architecture": "🏗️", "historical_sites": "🏰"
        ]
        return iconMap[subcategory.lowercased()] ?? "📍"
    }
}
