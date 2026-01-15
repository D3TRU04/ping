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

    // Consistent background color
    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Nav Bar
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

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
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

                        // Categories Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(OnboardingData.categories) { category in
                                CategoryCard(
                                    category: category,
                                    isSelected: selectedCategories.contains(category.id),
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if selectedCategories.contains(category.id) {
                                                selectedCategories.removeAll { $0 == category.id }
                                                // Remove all subcategories of this category
                                                let subcatNames = category.subcategories.map { $0.name }
                                                allSubcategories.removeAll { subcatNames.contains($0) }
                                            } else {
                                                selectedCategories.append(category.id)
                                                // Show subcategory selection
                                                currentCategoryForSubcategory = category.id
                                                showSubcategorySelection = true
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Selected Subcategories Display
                        if !allSubcategories.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Selected Interests")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 24)

                                FlowLayout(spacing: 8) {
                                    ForEach(allSubcategories, id: \.self) { subcategory in
                                        SubcategoryChip(
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

                        // Error message
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
                    .padding(.bottom, 120)
                }
            }
        }
        .sheet(isPresented: $showSubcategorySelection) {
            if let categoryId = currentCategoryForSubcategory,
               let category = OnboardingData.categories.first(where: { $0.id == categoryId }) {
                SubcategorySelectionSheet(
                    category: category,
                    selectedSubcategories: Binding(
                        get: {
                            allSubcategories.filter { subcatName in
                                category.subcategories.contains(where: { $0.name == subcatName })
                            }
                        },
                        set: { newSelection in
                            // Remove old subcategories from this category
                            let categorySubcatNames = category.subcategories.map { $0.name }
                            allSubcategories.removeAll { categorySubcatNames.contains($0) }
                            // Add new selection
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
}

// MARK: - Preferences Nav Bar
struct PreferencesNavBar: View {
    let onBack: () -> Void
    let onSave: () -> Void
    let isSaving: Bool

    var body: some View {
        HStack(alignment: .center) {
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 17))
                }
                .foregroundColor(AppColors.mint)
            }

            Spacer()

            Text("Preferences")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Button(action: onSave) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                        .scaleEffect(0.8)
                } else {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.mint)
                }
            }
            .disabled(isSaving)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "FAFAFA").opacity(0.95), Color(hex: "FAFAFA").opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Subcategory Selection Sheet
struct SubcategorySelectionSheet: View {
    let category: Category
    @Binding var selectedSubcategories: [String]
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
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
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)

                        Text("Select your specific interests")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)

                Divider()

                // Subcategories Grid
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
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }

                // Done Button
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "1FC9C3").opacity(0.25), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color(hex: "FAFAFA"))
        }
    }
}

// MARK: - Subcategory Chip
struct SubcategoryChip: View {
    let name: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preferences ViewModel
@MainActor
class PreferencesViewModel: ObservableObject {
    @Published var currentCategories: [String] = []
    @Published var currentSubcategories: [String] = []
    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var errorMessage: String?

    func loadCurrentPreferences(userId: String, profileService: ProfileService) async {
        guard !userId.isEmpty else { return }

        do {
            let user = try await profileService.fetchProfile(userId: userId)

            // Extract category preferences from user
            // The user model stores preferences differently, so we need to adapt
            if let categoryPreferences = user.categoryPreferences {
                // If categoryPreferences is a dictionary like [String: [String]]
                // We need to convert this to our category IDs and subcategory names
                currentCategories = Array(categoryPreferences.keys)
                currentSubcategories = categoryPreferences.values.flatMap { $0 }
            }
        } catch {
            print("❌ Error loading preferences: \(error)")
            errorMessage = "Failed to load current preferences"
        }
    }

    func savePreferences(
        userId: String,
        categories: [String],
        subcategories: [String],
        profileService: ProfileService
    ) async {
        guard !userId.isEmpty else {
            errorMessage = "User ID not found"
            return
        }

        guard !categories.isEmpty else {
            errorMessage = "Please select at least one category"
            return
        }

        isSaving = true
        saveSuccess = false
        errorMessage = nil

        do {
            // Build category preferences dictionary
            var categoryPreferences: [String: [String]] = [:]
            for categoryId in categories {
                if let category = OnboardingData.categories.first(where: { $0.id == categoryId }) {
                    let categoryName = category.name
                    let categorySubcats = subcategories.filter { subcatName in
                        category.subcategories.contains(where: { $0.name == subcatName })
                    }
                    if !categorySubcats.isEmpty {
                        categoryPreferences[categoryName] = categorySubcats
                    }
                }
            }

            // Update profile with new preferences
            let updates = ProfileUpdate(categoryPreferences: categoryPreferences)
            _ = try await profileService.updateProfile(userId: userId, updates: updates)

            saveSuccess = true
        } catch {
            print("❌ Error saving preferences: \(error)")
            errorMessage = "Failed to save preferences. Please try again."
        }

        isSaving = false
    }
}
