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
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                Capsule().fill(Color.white.opacity(0.12))
                                Capsule().fill(
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
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                            }
                        )
                        .clipShape(Capsule())
                        .overlay(
                            ZStack {
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            stops: [
                                                .init(color: .white.opacity(1.0), location: 0.0),
                                                .init(color: .white.opacity(0.7), location: 0.3),
                                                .init(color: .white.opacity(0.5), location: 0.6),
                                                .init(color: .white.opacity(0.85), location: 1.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                                Capsule()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                                    .padding(1)
                            }
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color(hex: "FAFAFA"))
        }
    }
}
