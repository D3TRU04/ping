//
//  PreferencesView.swift
//  PingNative
//
//  Preferences view for updating user categories and subcategories
//

import SwiftUI
import Combine

struct PreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = PreferencesViewModel()

    @State private var selectedCategories: [String] = []
    @State private var allSubcategories: [String] = []
    @State private var showSubcategorySelection = false
    @State private var currentCategoryForSubcategory: String? = nil

    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                PreferencesNavBar(onBack: { dismiss() }, onSave: {
                    Task {
                        await viewModel.savePreferences(
                            userId: appEnvironment.currentUser?.id ?? "",
                            categories: selectedCategories,
                            subcategories: allSubcategories,
                            profileService: appEnvironment.profileService
                        )
                        if viewModel.saveSuccess {
                            dismiss()
                        }
                    }
                }, isSaving: viewModel.isSaving)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        categoriesGrid
                        selectedSubcategoriesSection
                        errorSection
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .sheet(isPresented: $showSubcategorySelection) {
            if let categoryId = currentCategoryForSubcategory,
               let category = OnboardingData.categories.first(where: { $0.id == categoryId }) {
                PreferencesSubcategorySheet(
                    category: category,
                    selectedSubcategories: Binding(
                        get: {
                            allSubcategories.filter { subcatName in
                                category.subcategories.contains(where: { $0.name == subcatName })
                            }
                        },
                        set: { newSelection in
                            let categorySubcatNames = category.subcategories.map { $0.name }
                            allSubcategories.removeAll { categorySubcatNames.contains($0) }
                            allSubcategories.append(contentsOf: newSelection)
                        }
                    ),
                    onDismiss: {
                        showSubcategorySelection = false
                        currentCategoryForSubcategory = nil
                    }
                )
            }
        }
        .task {
            await viewModel.loadCurrentPreferences(
                userId: appEnvironment.currentUser?.id ?? "",
                profileService: appEnvironment.profileService
            )
            selectedCategories = viewModel.currentCategories
            allSubcategories = viewModel.currentSubcategories
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Preferences")
                .font(.system(size: 30, weight: .regular))
                .foregroundColor(AppColors.textPrimary)

            Text("Select the categories and specific interests that match what you'd like to explore.")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    private var categoriesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(OnboardingData.categories) { category in
                CategoryCard(
                    category: category,
                    isSelected: selectedCategories.contains(category.id),
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedCategories.contains(category.id) {
                                selectedCategories.removeAll { $0 == category.id }
                                let subcatNames = category.subcategories.map { $0.name }
                                allSubcategories.removeAll { subcatNames.contains($0) }
                            } else {
                                selectedCategories.append(category.id)
                                currentCategoryForSubcategory = category.id
                                showSubcategorySelection = true
                            }
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var selectedSubcategoriesSection: some View {
        if !allSubcategories.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Selected Interests")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 24)

                FlowLayout(spacing: 8) {
                    ForEach(allSubcategories, id: \.self) { subcategory in
                        PreferencesSubcategoryChip(
                            name: subcategory,
                            onRemove: {
                                allSubcategories.removeAll { $0 == subcategory }
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var errorSection: some View {
        if let error = viewModel.errorMessage {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(hex: "DC2626"))
                    .font(.system(size: 18))

                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "DC2626"))

                Spacer()
            }
            .padding()
            .background(Color(hex: "FEE2E2"))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "DC2626"), lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }
}
