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
    let saved: Set<String>
    let refreshing: Bool
    let loading: Bool
    let onRefresh: () async -> Void
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
            // MARK: - TikTok-style Paging Feed
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        ItemCard(
                            item: item,
                            isLiked: liked.contains(item.id),
                            isSaved: saved.contains(item.id),
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
                        .padding(.top, 20)
                        .containerRelativeFrame(.vertical, alignment: .center)
                        .scrollTransition(.animated(.spring(response: 0.35, dampingFraction: 0.86))) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.7)
                                .scaleEffect(phase.isIdentity ? 1 : 0.92)
                        }
                        .onAppear {
                            setCurrentIndex(index)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .refreshable {
                await onRefresh()
            }
        }
    }
    
    private func renderEmptyState() -> some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                
                Circle()
                    .fill(Color.white.opacity(0.2))
                
                Circle()
                    .stroke(Color.white.opacity(0.8), lineWidth: 0.5)

                    .frame(width: 80, height: 80)

                Image(systemName: "fork.knife")
                    .font(.system(size: 32, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "B2BEC3"))
            }
            .padding(.bottom, 8)

            VStack(spacing: 8) {
                Text("No places found")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
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
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
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
            .padding(.top, 16)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
