//
//  GroupFeedPage.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/components/GroupFeedPage.tsx
//  Complete group feed page with place cards
//

import SwiftUI
import Combine

struct GroupFeedPage: View {
    let group: Group
    let currentUser: User?
    let onBack: () -> Void
    var hideHeader: Bool = false
    
    @StateObject private var viewModel = GroupFeedViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "FAF6F2")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                if !hideHeader {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                        }
                        
                        VStack(spacing: 2) {
                            Text(group.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Group Feed")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Spacer for alignment
                        Color.clear
                            .frame(width: 40)
                    }
                    .padding()
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 1),
                        alignment: .bottom
                    )
                }
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        // Feed Header Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.mint)
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(group.name) Feed")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Places recommended for your group")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Text("Places that match the preferences of everyone in your group.")
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Places Feed
                        if viewModel.loading {
                            ProgressView()
                                .padding()
                        } else if viewModel.places.isEmpty {
                            renderEmptyState()
                        } else {
                            ForEach(viewModel.places) { place in
                                ItemCard(
                                    item: place,
                                    isLiked: viewModel.likedPlaces.contains(place.id),
                                    isSaved: (viewModel.savedMap["all_saved"] ?? []).contains(place.id),
                                    onImageError: {
                                        // Handle image error
                                    },
                                    imageFailed: false,
                                    currentUserId: currentUser?.id ?? "",
                                    onLikeChange: { isLiked in
                                        viewModel.toggleLike(placeId: place.id, isLiked: isLiked)
                                    },
                                    onSaveChange: { listName in
                                        viewModel.toggleSave(placeId: place.id, listName: listName)
                                    },
                                    showToast: {
                                        // Show toast
                                    }
                                )
                            }
                        }
                    }
                    .padding(.bottom, 120)
                }
                .refreshable {
                    await viewModel.refresh(groupId: group.id)
                }
            }
        }
        .task {
            await viewModel.loadPlaces(groupId: group.id)
        }
    }
    
    private func renderEmptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.system(size: 80))
                .foregroundColor(AppColors.mint)
            
            Text("No places found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("We couldn't find any places matching your group's preferences. Try updating your interests in your profile.")
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
        }
        .padding(.vertical, 64)
        .padding(.horizontal, 32)
    }
}

@MainActor
class GroupFeedViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var loading: Bool = false
    @Published var likedPlaces: Set<String> = []
    @Published var savedMap: [String: [String]] = [:]
    
    func loadPlaces(groupId: String) async {
        loading = true
        // TODO: Fetch group places from Supabase
        // For now, placeholder
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        loading = false
    }
    
    func refresh(groupId: String) async {
        await loadPlaces(groupId: groupId)
    }
    
    func toggleLike(placeId: String, isLiked: Bool) {
        if isLiked {
            likedPlaces.insert(placeId)
        } else {
            likedPlaces.remove(placeId)
        }
        // TODO: Update in Supabase
    }
    
    func toggleSave(placeId: String, listName: String) {
        if savedMap[listName] == nil {
            savedMap[listName] = []
        }
        if let index = savedMap[listName]?.firstIndex(of: placeId) {
            savedMap[listName]?.remove(at: index)
        } else {
            savedMap[listName]?.append(placeId)
        }
        // TODO: Update in Supabase
    }
}
