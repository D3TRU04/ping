//
//  TodayCategorySelectionView.swift
//  PingNative
//
//  Main container for 2-step category selection flow on Today page
//

import SwiftUI

struct TodayCategorySelectionView: View {
    @ObservedObject var viewModel: TodayViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            // Clear background - relies on parent LiquidGlassBackground from HomeView
            Color.clear

            VStack(spacing: 0) {
                switch viewModel.categorySelectionStep {
                case .categories:
                    categorySelectionStep
                case .subcategories:
                    subcategorySelectionStep
                case .swipe, .preview, .complete:
                    EmptyView()
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: viewModel.categorySelectionStep)
    }

    // MARK: - Step 1: Category Selection

    private var categorySelectionStep: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 24)

                // Header
                VStack(spacing: 4) {
                    Text("What are you feeling")
                        .font(.system(size: 26, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Text("today?")
                        .font(.system(size: 26, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()
                    .frame(height: 8)

                // Category Grid (no ScrollView - fits on screen)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(OnboardingData.categories) { category in
                        TodayCategoryCard(
                            category: category,
                            isSelected: viewModel.selectedCategoryIds.contains(category.id),
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.toggleCategorySelection(category.id)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }

            // Floating Continue Button (FAB style)
            continueButton
                .padding(.trailing, 24)
                .padding(.bottom, 24)
        }
    }

    private var continueButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                viewModel.proceedToSubcategories()
            }
        }) {
            Image(systemName: "arrow.right")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Group {
                        if viewModel.selectedCategoryIds.isEmpty {
                            Circle().fill(Color.white.opacity(0.2))
                        } else {
                            Circle().fill(
                                LinearGradient(
                                    colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        }
                    }
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.9))
        .disabled(viewModel.selectedCategoryIds.isEmpty)
        .opacity(viewModel.selectedCategoryIds.isEmpty ? 0.5 : 1.0)
    }

    // MARK: - Step 2: Subcategory Selection

    private var subcategorySelectionStep: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Header with back button
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            viewModel.goBackToCategories()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                    }
                    .buttonStyle(ScaleButtonStyle(scale: 0.9))

                    Spacer()

                    Text("Narrow it down")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    // Invisible spacer for alignment
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Pinterest-style masonry grid for subcategories
                MasonrySubcategoryGrid(
                    viewModel: viewModel,
                    categories: viewModel.getSelectedCategories()
                )

                Spacer()
            }

            // Floating Let's Go Button (FAB style)
            letsGoButton
                .padding(.trailing, 24)
                .padding(.bottom, 24)
        }
    }

    private var letsGoButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                viewModel.markCategorySelectionComplete()
            }
        }) {
            Image(systemName: "arrow.right")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle().fill(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.9))
    }
}
