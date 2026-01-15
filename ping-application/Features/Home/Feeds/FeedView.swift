//
//  FeedView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/FeedView.tsx
//  Complete feed view with ItemCard components
//

import SwiftUI

struct FeedView: View {
    let items: [Place]
    let liked: Set<String>
    let savedMap: [String: [String]]
    let refreshing: Bool
    let loading: Bool
    let onRefresh: () -> Void
    let erroredImages: Set<String>
    let setErroredImages: (Set<String>) -> Void
    let setCurrentIndex: (Int) -> Void
    let currentUserId: String
    let onLikeChange: (String, Bool) -> Void
    let onSaveChange: (String, String) -> Void
    let onUpdatePreferences: (() -> Void)?
    
    var body: some View {
        if loading {
            VStack {
                Spacer()
                ProgressView()
                Text("Finding amazing places for you...")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.top, 16)
                Spacer()
            }
        } else if items.isEmpty {
            renderEmptyState()
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        ItemCard(
                            item: item,
                            isLiked: liked.contains(item.id),
                            isSaved: (savedMap["all_saved"] ?? []).contains(item.id),
                            onImageError: {
                                var newSet = erroredImages
                                newSet.insert(item.id)
                                setErroredImages(newSet)
                            },
                            imageFailed: erroredImages.contains(item.id),
                            currentUserId: currentUserId,
                            onLikeChange: { isLiked in
                                onLikeChange(item.id, isLiked)
                            },
                            onSaveChange: { listName in
                                onSaveChange(item.id, listName)
                            },
                            showToast: {
                                // TODO: Show toast notification
                            }
                        )
                        .onAppear {
                            setCurrentIndex(index)
                        }
                    }
                }
                .padding(.bottom, 120)
            }
            .refreshable {
                onRefresh()
            }
        }
    }
    
    private func renderEmptyState() -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "F3F4F6"))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 32, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 8) {
                Text("No places found")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("We couldn't find any places matching your preferences. Try updating your interests in your profile.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
            
            Button(action: {
                onUpdatePreferences?()
            }) {
                Text("Update Preferences")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
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
            .padding(.top, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
}
