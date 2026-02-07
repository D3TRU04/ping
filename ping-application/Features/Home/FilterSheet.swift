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
                .padding(.top, 16)
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
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
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
                                    .stroke(Color(hex: "1FC9C3"), lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
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
