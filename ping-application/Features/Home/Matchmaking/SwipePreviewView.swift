//
//  SwipePreviewView.swift
//  PingNative
//
//  "Your Picks" preview screen after completing swipe batch
//

import SwiftUI

struct SwipePreviewView: View {
    @ObservedObject var viewModel: TodayViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.top, 16)
                .padding(.horizontal, 20)

            if viewModel.interestedPlaces.isEmpty {
                // Empty state
                emptyState
            } else {
                // Places list
                placesList
            }

            Spacer()

            // Action buttons
            actionButtons
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Your Picks")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Text("\(viewModel.interestedPlaces.count) places you're interested in")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)

            Text("No places selected yet")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)

            Text("Swipe right on places you're interested in")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textTertiary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Places List

    private var placesList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.interestedPlaces, id: \.id) { place in
                    PreviewPlaceRow(place: place) {
                        viewModel.removeInterestedPlace(place)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Accept / Continue to Feed
            Button(action: {
                viewModel.acceptPreview()
            }) {
                Text(viewModel.interestedPlaces.isEmpty ? "Skip to Feed" : "Continue with \(viewModel.interestedPlaces.count) Picks")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "1FC9C3"), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.97))

            // Keep Swiping
            Button(action: {
                viewModel.loadMoreSwipeCards()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 18))
                    Text("Keep Swiping (+10 more)")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                }
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.97))
        }
    }
}

// MARK: - Preview Place Row

struct PreviewPlaceRow: View {
    let place: Place
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                if let subcategory = place.subcategory {
                    Text(subcategory.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }

                if let rating = place.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }

            Spacer()

            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.textTertiary)
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.9))
        }
        .padding(12)
        .background(
            GlassSurface(cornerRadius: 16) {
                Color.clear
            }
        )
    }
}
