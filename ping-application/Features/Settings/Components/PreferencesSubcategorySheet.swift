//
//  PreferencesSubcategorySheet.swift
//  PingNative
//
//  Sheet for selecting subcategories within a category
//

import SwiftUI

struct PreferencesSubcategorySheet: View {
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
                        .font(.system(size: 18, weight: .regular))
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
