//
//  SwipeStackView.swift
//  PingNative
//
//  Card stack view with progress bar and action buttons for swipe feature
//

import SwiftUI

struct SwipeStackView: View {
    @ObservedObject var viewModel: TodayViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header with progress
            headerSection
                .padding(.top, 16)
                .padding(.horizontal, 20)

            Spacer()
                .frame(height: 12)

            // Card stack
            cardStack
                .padding(.horizontal, 20)

            Spacer()
                .frame(height: 16)

            // Action buttons
            actionButtons
                .padding(.horizontal, 40)
                .padding(.bottom, 120)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Title
            Text("Find Your Spots")
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            // Progress bar
            progressBar
        }
    }

    private var progressBar: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.swipeProgress, height: 8)
                        .animation(.spring(response: 0.3), value: viewModel.swipeProgress)
                }
            }
            .frame(height: 8)

            // Progress text
            HStack {
                Text("\(viewModel.currentSwipeIndex) of \(viewModel.totalSwipesThisBatch)")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                if viewModel.swipeBatchNumber > 1 {
                    Text("Round \(viewModel.swipeBatchNumber)")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        ZStack {
            // Show only the front card
            ForEach(visibleCardIndices, id: \.self) { index in
                let card = viewModel.swipeCards[index]

                SwipeCardView(card: card) { direction in
                    viewModel.handleSwipe(direction: direction)
                }
            }
        }
    }

    private var visibleCardIndices: [Int] {
        let start = viewModel.currentSwipeIndex
        // Only show 1 card (no background stack)
        let end = min(start + 1, viewModel.swipeCards.count)
        return Array(start..<end)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 40) {
            // Skip button (X)
            actionButton(
                icon: "xmark",
                color: AppColors.error,
                size: 64
            ) {
                viewModel.handleSwipe(direction: .left)
            }

            // Interested button (Heart)
            actionButton(
                icon: "heart.fill",
                color: AppColors.success,
                size: 64
            ) {
                viewModel.handleSwipe(direction: .right)
            }
        }
    }

    private func actionButton(icon: String, color: Color, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .regular))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.15))
                )
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.9))
        .disabled(viewModel.currentSwipeIndex >= viewModel.swipeCards.count)
        .opacity(viewModel.currentSwipeIndex >= viewModel.swipeCards.count ? 0.5 : 1.0)
    }
}
