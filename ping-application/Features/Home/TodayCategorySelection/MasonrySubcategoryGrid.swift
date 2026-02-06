//
//  MasonrySubcategoryGrid.swift
//  PingNative
//
//  Container with category headers and Pinterest-style masonry layout for subcategories
//

import SwiftUI

struct MasonrySubcategoryGrid: View {
    @ObservedObject var viewModel: TodayViewModel
    let categories: [Category]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                ForEach(categories) { category in
                    categorySection(for: category)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    private func categorySection(for category: Category) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack(spacing: 10) {
                Text(category.icon)
                    .font(.system(size: 22))
                Text(category.name)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.leading, 4)

            // Masonry grid of subcategories
            MasonryLayout(columns: 2, spacing: 12) {
                ForEach(Array(category.subcategories.enumerated()), id: \.element.id) { index, subcategory in
                    SubcategoryMasonryCard(
                        subcategory: subcategory,
                        isSelected: viewModel.selectedSubcategoryValues.contains(subcategory.value),
                        height: SubcategoryCardHeight.forIndex(index, totalCount: category.subcategories.count),
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.toggleSubcategorySelection(subcategory.value)
                            }
                        }
                    )
                }
            }
        }
    }
}
