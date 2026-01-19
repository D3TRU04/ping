//
//  SaveToCollectionSheet.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/components/SaveToCollectionSheet.tsx
//  Modal sheet for saving places to collections
//

import SwiftUI

struct SaveToCollectionSheet: View {
    @Binding var visible: Bool
    let savedMap: [String: [String]]
    
    private let backgroundColor = Color(hex: "FAFAFA")
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 0) {
                // Drag indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "D1D5DB"))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                
                HStack {
                    Text("Save to Collection")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { visible = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textTertiary)
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "F3F4F6"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    // Create New Collection Button
                    Button(action: {
                        // TODO: Implement create new collection
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "6EE7E7").opacity(0.3), Color(hex: "1FC9C3").opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(AppColors.mint)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Create New Collection")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Organize your saved places")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Section Header
                    if !savedMap.isEmpty {
                        HStack {
                            Text("Your Collections")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textTertiary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                    }
                    
                    // Collections List
                    ForEach(Array(savedMap.keys.sorted().filter { $0 != "all_saved" }), id: \.self) { name in
                        CollectionRow(
                            name: name.replacingOccurrences(of: "_", with: " ").capitalized,
                            itemCount: savedMap[name]?.count ?? 0,
                            icon: collectionIcon(for: name)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(backgroundColor)
        }
        .background(Color.white)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
    
    private func collectionIcon(for name: String) -> String {
        let lowercased = name.lowercased()
        if lowercased.contains("want") || lowercased.contains("go") {
            return "flag.fill"
        } else if lowercased.contains("favorite") || lowercased.contains("love") {
            return "heart.fill"
        } else if lowercased.contains("food") || lowercased.contains("eat") || lowercased.contains("restaurant") {
            return "fork.knife"
        } else if lowercased.contains("coffee") || lowercased.contains("cafe") {
            return "cup.and.saucer.fill"
        } else if lowercased.contains("bar") || lowercased.contains("drink") {
            return "wineglass.fill"
        } else {
            return "bookmark.fill"
        }
    }
}

// MARK: - Collection Row
struct CollectionRow: View {
    let name: String
    let itemCount: Int
    let icon: String
    
    var body: some View {
        Button(action: {
            // TODO: Save to this collection
        }) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "F3F4F6"))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.mint)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("\(itemCount) place\(itemCount == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Checkmark circle (for selection state)
                Circle()
                    .stroke(Color(hex: "E5E7EB"), lineWidth: 2)
                    .frame(width: 24, height: 24)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
