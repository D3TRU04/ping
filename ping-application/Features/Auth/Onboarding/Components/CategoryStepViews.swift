//
//  CategoryStepViews.swift
//  PingNative
//
//  Category and subcategory selection step views for onboarding
//

import SwiftUI

// MARK: - Category Selection Step
struct CategorySelectionStepView: View {
    @Binding var selectedCategories: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What interests you most?")
                    .font(.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Select the categories that match your interests.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(OnboardingData.categories) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategories.contains(category.id),
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if selectedCategories.contains(category.id) {
                                        selectedCategories.removeAll { $0 == category.id }
                                    } else {
                                        selectedCategories.append(category.id)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(category.name)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                Text(category.icon)
                    .font(.system(size: 26))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(height: (UIScreen.main.bounds.width - 64) / 2 * 0.48)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
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
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(isSelected ? 1.0 : 0.8), location: 0.0),
                                    .init(color: .white.opacity(isSelected ? 0.7 : 0.4), location: 0.5),
                                    .init(color: .white.opacity(isSelected ? 0.85 : 0.6), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                            .padding(1)
                    }
                }
            )
            .shadow(color: isSelected ? Color.black.opacity(0.1) : Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Subcategory Selection Step
struct SubcategorySelectionStepView: View {
    let categoryId: String
    @Binding var selectedSubcategories: [String]

    var category: Category? {
        OnboardingData.categories.first { $0.id == categoryId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let category = category {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: category.gradient.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 48, height: 48)

                        Text(category.icon)
                            .font(.system(size: 24))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.system(size: 30, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("Select your specific interests")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.top, 24)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(category.subcategories) { subcategory in
                            SubcategoryCard(
                                subcategory: subcategory,
                                isSelected: selectedSubcategories.contains(subcategory.name),
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if selectedSubcategories.contains(subcategory.name) {
                                            selectedSubcategories.removeAll { $0 == subcategory.name }
                                        } else {
                                            selectedSubcategories.append(subcategory.name)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

// MARK: - Subcategory Card
struct SubcategoryCard: View {
    let subcategory: Subcategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(subcategory.icon)
                    .font(.system(size: 15))

                Text(subcategory.name)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textPrimary)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
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
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(isSelected ? 1.0 : 0.8), location: 0.0),
                                    .init(color: .white.opacity(isSelected ? 0.7 : 0.4), location: 0.5),
                                    .init(color: .white.opacity(isSelected ? 0.85 : 0.6), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                            .padding(1)
                    }
                }
            )
            .shadow(color: isSelected ? Color.black.opacity(0.1) : Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }
}
