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
    
    var body: some View {
        if loading {
            VStack {
                Spacer()
                ProgressView()
                Text("Finding amazing places for you...")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.mint)
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
            
            Image(systemName: "fork.knife")
                .font(.system(size: 80))
                .foregroundColor(AppColors.mint)
            
            Text("No places found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("We couldn't find any places matching your preferences. Try updating your interests in your profile.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                // TODO: Navigate to profile preferences
            }) {
                Text("Update Preferences")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.mint)
                    .cornerRadius(16)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
