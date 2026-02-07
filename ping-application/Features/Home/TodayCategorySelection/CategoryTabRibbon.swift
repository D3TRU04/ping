//
//  CategoryTabRibbon.swift
//  PingNative
//
//  Horizontal scrollable category pill tabs for subcategory selection
//

import SwiftUI

struct CategoryTabRibbon: View {
    let categories: [Category]
    @Binding var activeCategoryId: String
    let selectedSubcategoryValues: Set<String>

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories) { category in
                        categoryTab(for: category)
                            .id(category.id)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .onChange(of: activeCategoryId) { _, newId in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    proxy.scrollTo(newId, anchor: .center)
                }
            }
        }
    }

    private func categoryTab(for category: Category) -> some View {
        let isActive = category.id == activeCategoryId
        let count = selectionCount(for: category)

        return Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                activeCategoryId = category.id
            }
        }) {
            HStack(spacing: 6) {
                Text(category.icon)
                    .font(.system(size: 16))
                Text(category.name)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isActive {
                        Capsule().fill(AppColors.mint.opacity(0.2))
                    } else {
                        Capsule().fill(Color.white.opacity(0.15))
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isActive ? AppColors.mint : Color.white.opacity(0.8),
                        lineWidth: isActive ? 1.5 : 0.5
                    )
            )
            .shadow(
                color: isActive ? AppColors.mint.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(alignment: .topTrailing) {
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(AppColors.mint))
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
    }

    private func selectionCount(for category: Category) -> Int {
        category.subcategories.filter { selectedSubcategoryValues.contains($0.value) }.count
    }
}
