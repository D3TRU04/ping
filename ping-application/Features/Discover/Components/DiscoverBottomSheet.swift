//
//  DiscoverBottomSheet.swift
//  PingNative
//
//  Bottom sheet component for Discover screen places list
//

import SwiftUI

struct DiscoverBottomSheet: View {
    let places: [Place]
    let loading: Bool
    let onPlaceSelect: (Place) -> Void
    var onExpansionChange: ((CGFloat) -> Void)? = nil

    @State private var sheetHeight: CGFloat = 140

    private let minHeight: CGFloat = 140
    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.7

    private var expansionProgress: CGFloat {
        (sheetHeight - minHeight) / (maxHeight - minHeight)
    }

    var body: some View {
        VStack(spacing: 0) {
            BottomSheetHeader(
                placesCount: places.count,
                expansionProgress: expansionProgress,
                onToggle: toggleExpansion
            )
            .gesture(dragGesture)

            BottomSheetContent(
                places: places,
                loading: loading,
                sheetHeight: sheetHeight,
                onPlaceSelect: onPlaceSelect
            )
        }
        .frame(height: sheetHeight)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
        .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: -10)
    }

    private func toggleExpansion() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if sheetHeight < (minHeight + maxHeight) / 2 {
                sheetHeight = maxHeight
            } else {
                sheetHeight = minHeight
            }
            onExpansionChange?(expansionProgress)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let newHeight = sheetHeight - value.translation.height
                sheetHeight = min(max(newHeight, minHeight), maxHeight)
                onExpansionChange?(expansionProgress)
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    if sheetHeight < (minHeight + maxHeight) / 2 {
                        sheetHeight = minHeight
                    } else {
                        sheetHeight = maxHeight
                    }
                    onExpansionChange?(expansionProgress)
                }
            }
    }
}

// MARK: - Bottom Sheet Header
private struct BottomSheetHeader: View {
    let placesCount: Int
    let expansionProgress: CGFloat
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "D1D5DB"))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 10)

            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "6EE7E7").opacity(0.3), Color(hex: "1FC9C3").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)

                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "1FC9C3"))
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Nearby")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("\(placesCount) places")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                Button(action: onToggle) {
                    Image(systemName: expansionProgress > 0.5 ? "chevron.compact.down" : "chevron.compact.up")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

// MARK: - Bottom Sheet Content
private struct BottomSheetContent: View {
    let places: [Place]
    let loading: Bool
    let sheetHeight: CGFloat
    let onPlaceSelect: (Place) -> Void

    var body: some View {
        ZStack {
            Color(hex: "F5F5F7")

            if loading {
                LoadingStateView()
            } else if places.isEmpty {
                EmptyStateView()
            } else {
                PlacesListView(places: places, onPlaceSelect: onPlaceSelect)
            }
        }
        .frame(height: max(sheetHeight - 90, 50))
    }
}

// MARK: - Loading State View
private struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1FC9C3")))
                .scaleEffect(1.2)
            Text("Finding places...")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Empty State View
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 14) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)

                Image(systemName: "mappin.slash")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }

            VStack(spacing: 4) {
                Text("No places nearby")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Try a different location")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - Places List View
private struct PlacesListView: View {
    let places: [Place]
    let onPlaceSelect: (Place) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(places) { place in
                    DiscoverPlaceRow(place: place)
                        .onTapGesture {
                            onPlaceSelect(place)
                        }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
}
