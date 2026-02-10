//
//  TodayCategorySelectionView.swift
//  PingNative
//
//  Main container for 2-step category selection flow on Today page
//

import SwiftUI

struct TodayCategorySelectionView: View {
    @ObservedObject var viewModel: TodayViewModel
    @State private var activeCategoryId: String = ""

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
                    .frame(height: 100)

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
                .padding(.bottom, 160)
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
                        }
                    }
                )
                .clipShape(Circle())
                .overlay(
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.9), location: 0.0),
                                        .init(color: .white.opacity(0.5), location: 0.3),
                                        .init(color: .white.opacity(0.3), location: 0.6),
                                        .init(color: .white.opacity(0.7), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            .padding(1)
                    }
                )
                .shadow(color: Color(hex: "1FC9C3").opacity(0.35), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.9))
        .disabled(viewModel.selectedCategoryIds.isEmpty)
        .opacity(viewModel.selectedCategoryIds.isEmpty ? 0.5 : 1.0)
    }

    // MARK: - Step 2: Subcategory Selection

    private var selectedCategories: [Category] {
        viewModel.getSelectedCategories()
    }

    private var activeCategory: Category? {
        selectedCategories.first(where: { $0.id == activeCategoryId })
            ?? selectedCategories.first
    }

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
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.8), lineWidth: 0.5)
                            )
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
                .padding(.top, 100)
                .padding(.bottom, 12)

                // Category tab ribbon
                CategoryTabRibbon(
                    categories: selectedCategories,
                    activeCategoryId: $activeCategoryId,
                    selectedSubcategoryValues: viewModel.selectedSubcategoryValues
                )
                .padding(.bottom, 12)

                // Subcategory chip cloud for active category
                if let category = activeCategory {
                    SubcategoryChipCloud(
                        category: category,
                        selectedSubcategoryValues: viewModel.selectedSubcategoryValues,
                        onToggle: { value in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.toggleSubcategorySelection(value)
                            }
                        },
                        onSurpriseMe: {
                            surpriseMe(for: category)
                        }
                    )
                    .id(category.id)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }

                Spacer()
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: activeCategoryId)

            // Floating Let's Go Button (FAB style)
            letsGoButton
                .padding(.trailing, 24)
                .padding(.bottom, 160)
        }
        .onAppear {
            if activeCategoryId.isEmpty, let first = selectedCategories.first {
                activeCategoryId = first.id
            }
        }
    }

    // MARK: - Surprise Me

    private func surpriseMe(for category: Category) {
        let unselected = category.subcategories.filter {
            !viewModel.selectedSubcategoryValues.contains($0.value)
        }
        guard !unselected.isEmpty else { return }

        let count = min(Int.random(in: 3...5), unselected.count)
        let picks = Array(unselected.shuffled().prefix(count))

        for (index, subcategory) in picks.enumerated() {
            let delay = Double(index) * 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.toggleSubcategorySelection(subcategory.value)
                }
            }
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
                )
                .clipShape(Circle())
                .overlay(
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.9), location: 0.0),
                                        .init(color: .white.opacity(0.5), location: 0.3),
                                        .init(color: .white.opacity(0.3), location: 0.6),
                                        .init(color: .white.opacity(0.7), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            .padding(1)
                    }
                )
                .shadow(color: Color(hex: "1FC9C3").opacity(0.35), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.9))
    }
}
