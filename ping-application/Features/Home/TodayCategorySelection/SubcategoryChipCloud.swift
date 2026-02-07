//
//  SubcategoryChipCloud.swift
//  PingNative
//
//  FlowLayout chip cloud for subcategory selection within a single category
//

import SwiftUI

struct SubcategoryChipCloud: View {
    let category: Category
    let selectedSubcategoryValues: Set<String>
    let onToggle: (String) -> Void
    let onSurpriseMe: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // Category header
                HStack(spacing: 10) {
                    Text(category.icon)
                        .font(.system(size: 22))
                    Text(category.name)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.leading, 4)

                // Chip cloud
                FlowLayout(spacing: 8) {
                    ForEach(category.subcategories) { subcategory in
                        SubcategoryGlassChip(
                            subcategory: subcategory,
                            isSelected: selectedSubcategoryValues.contains(subcategory.value),
                            onTap: {
                                onToggle(subcategory.value)
                            }
                        )
                    }
                }

                // Surprise Me button
                Button(action: onSurpriseMe) {
                    HStack(spacing: 8) {
                        Text("🎲")
                            .font(.system(size: 14))
                        Text("Surprise Me")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.white.opacity(0.15)))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(1.0), location: 0.0),
                                        .init(color: .white.opacity(0.7), location: 0.4),
                                        .init(color: .white.opacity(0.5), location: 0.7),
                                        .init(color: .white.opacity(0.8), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle(scale: 0.95))
                .padding(.top, 4)

                // Selection counter
                let count = category.subcategories.filter { selectedSubcategoryValues.contains($0.value) }.count
                if count > 0 {
                    Text("\(count) selected")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
}
