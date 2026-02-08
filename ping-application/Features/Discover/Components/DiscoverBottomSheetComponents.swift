//
//  DiscoverBottomSheetComponents.swift
//  PingNative
//
//  Components for Discover bottom sheet
//

import SwiftUI

// MARK: - Bottom Sheet Header
struct BottomSheetHeader: View {
    let placesCount: Int
    let expansionProgress: CGFloat
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.4))
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
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "1FC9C3"))
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Nearby")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("\(placesCount) places")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                Button(action: onToggle) {
                    Image(systemName: expansionProgress > 0.5 ? "chevron.compact.down" : "chevron.compact.up")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(AppColors.textTertiary)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.65))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(1.0), location: 0.0),
                                            .init(color: .white.opacity(0.8), location: 0.3),
                                            .init(color: .white.opacity(0.6), location: 0.6),
                                            .init(color: .white.opacity(0.9), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.65))
    }
}

// MARK: - Bottom Sheet Content
struct BottomSheetContent: View {
    let places: [Place]
    let loading: Bool
    let sheetHeight: CGFloat
    let onPlaceSelect: (Place) -> Void

    var body: some View {
        ZStack {
            Color.white.opacity(0.06)

            if loading {
                BottomSheetLoadingView()
            } else if places.isEmpty {
                BottomSheetEmptyView()
            } else {
                BottomSheetPlacesListView(places: places, onPlaceSelect: onPlaceSelect)
            }
        }
        .frame(height: max(sheetHeight - 90, 50))
    }
}

// MARK: - Loading State View
struct BottomSheetLoadingView: View {
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
struct BottomSheetEmptyView: View {
    var body: some View {
        VStack(spacing: 14) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.65))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(1.0), location: 0.0),
                                        .init(color: .white.opacity(0.8), location: 0.3),
                                        .init(color: .white.opacity(0.6), location: 0.6),
                                        .init(color: .white.opacity(0.9), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)

                Image(systemName: "mappin.slash")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }

            VStack(spacing: 4) {
                Text("No places nearby")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
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
struct BottomSheetPlacesListView: View {
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
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
}
