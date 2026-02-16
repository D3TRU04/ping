//
//  FilterSheet.swift
//  PingNative
//
//  Filter sheet for the ForYou feed
//
//  Related files:
//  - FilterComponents.swift - FilterSection and FilterChip components
//

import SwiftUI

struct FilterSheet: View {
    @Binding var filters: PlaceFilters
    @Binding var isPresented: Bool
    var onApply: () -> Void

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button(action: {
                        filters.reset()
                    }) {
                        Text("Reset")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(width: 60, alignment: .leading)

                    Spacer()

                    Text("Filters")
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                            )
                    }
                    .frame(width: 60, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 24) {
                        FilterSection(title: "Sort By", icon: "arrow.up.arrow.down") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(SortOption.allCases) { option in
                                    FilterChip(
                                        title: option.rawValue,
                                        icon: option.icon,
                                        isSelected: filters.sortBy == option,
                                        action: { filters.sortBy = option }
                                    )
                                }
                            }
                        }

                        FilterSection(title: "Minimum Rating", icon: "star.fill") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(RatingFilter.allCases) { rating in
                                    FilterChip(
                                        title: rating.rawValue,
                                        icon: rating == .any ? nil : "star.fill",
                                        isSelected: filters.minRating == rating,
                                        action: { filters.minRating = rating }
                                    )
                                }
                            }
                        }

                        FilterSection(title: "Max Price", icon: "dollarsign.circle") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(PriceFilter.allCases) { price in
                                    FilterChip(
                                        title: price.rawValue,
                                        icon: nil,
                                        isSelected: filters.maxPrice == price,
                                        action: { filters.maxPrice = price }
                                    )
                                }
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(24)
                }

                VStack(spacing: 16) {
                    Button(action: {
                        onApply()
                        isPresented = false
                    }) {
                        Text("Apply Filters")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    Capsule().fill(Color.white.opacity(0.12))
                                    Capsule().fill(
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
                                    Capsule().fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .center
                                        )
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
                                    Capsule()
                                        .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                                        .padding(1)
                                }
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
        }
    }
}
