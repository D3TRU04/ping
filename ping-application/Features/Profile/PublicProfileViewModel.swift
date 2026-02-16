//
//  PublicProfileViewModel.swift
//  PingNative
//
//  ViewModel for public profile view
//

import SwiftUI
import Combine

@MainActor
class PublicProfileViewModel: ObservableObject {
    @Published var profile: User?
    @Published var followers: Int?
    @Published var following: Int?
    @Published var isFollowing: Bool = false
    @Published var theyFollowMe: Bool = false
    @Published var isMutualFollow: Bool = false
    @Published var isLoading: Bool = false
    @Published var wantToTryCount: Int = 0
    @Published var beenCount: Int = 0
    @Published var sharedWantToTryCount: Int = 0
    @Published var sharedBeenCount: Int = 0

    // Actual place data for tabs
    @Published var savedPlaces: [CollectionsService.SavedPlace] = []
    @Published var visitedPlaces: [PlaceVisit] = []
    @Published var isLoadingPlaces: Bool = false

    private var loadedUserId: String?

    var profilePicture: ImageSource {
        if let pictureUrl = profile?.profilePicture, let url = URL(string: pictureUrl) {
            return .url(url)
        }
        return .placeholder
    }

    var creationDate: String? {
        guard let createdAt = profile?.createdAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: createdAt)
    }

    var profileUser: User? { profile }

    func load(userId: String, appEnvironment: AppEnvironment) async {
        // Skip if already loaded for this user (prevents reloading on minor view updates)
        if loadedUserId == userId && profile != nil {
            return
        }

        isLoading = true
        loadedUserId = userId

        do {
            profile = try await appEnvironment.profileService.fetchProfile(userId: userId)
            await loadFollowStatus(userId: userId, appEnvironment: appEnvironment)
            await loadPlaces(userId: userId, appEnvironment: appEnvironment)
        } catch {
            #if DEBUG
            print("❌ Error loading public profile: \(error)")
            #endif
        }

        isLoading = false
    }

    /// Refresh data when returning to the view
    func refresh(userId: String, appEnvironment: AppEnvironment) async {
        // Skip refresh if initial load is in progress or hasn't happened yet
        guard !isLoading, loadedUserId == userId else { return }

        await loadFollowStatus(userId: userId, appEnvironment: appEnvironment)
        await loadPlaces(userId: userId, appEnvironment: appEnvironment)
    }

    private func loadFollowStatus(userId: String, appEnvironment: AppEnvironment) async {
        guard let currentUserId = appEnvironment.currentUser?.id else { return }

        do {
            // Fetch follow status
            isFollowing = try await appEnvironment.profileService.isFollowing(
                followerId: currentUserId,
                followingId: userId
            )
            theyFollowMe = try await appEnvironment.profileService.isFollowing(
                followerId: userId,
                followingId: currentUserId
            )
            isMutualFollow = isFollowing && theyFollowMe

            // Fetch follow counts
            let followersList = try await appEnvironment.profileService.fetchFollowers(userId: userId)
            let followingList = try await appEnvironment.profileService.fetchFollowing(userId: userId)
            followers = followersList.count
            following = followingList.count
        } catch {
            #if DEBUG
            print("❌ Error loading follow status: \(error)")
            #endif
        }
    }

    private func loadPlaces(userId: String, appEnvironment: AppEnvironment) async {
        isLoadingPlaces = true

        do {
            savedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(userId: userId, limit: 100)
            visitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(userId: userId, limit: 100)
            wantToTryCount = savedPlaces.count
            beenCount = visitedPlaces.count

            // Calculate shared places if mutual follow
            if isMutualFollow, let currentUserId = appEnvironment.currentUser?.id {
                let mySavedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(userId: currentUserId, limit: 100)
                let myVisitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(userId: currentUserId, limit: 100)

                let mySavedIds = Set(mySavedPlaces.map { $0.placeId })
                let myVisitedIds = Set(myVisitedPlaces.map { $0.placeId })

                sharedWantToTryCount = savedPlaces.filter { mySavedIds.contains($0.placeId) }.count
                sharedBeenCount = visitedPlaces.filter { myVisitedIds.contains($0.placeId) }.count
            }
        } catch {
            #if DEBUG
            print("❌ Error loading places: \(error)")
            #endif
        }

        isLoadingPlaces = false
    }

    /// Handle follow toggle with optimistic update
    func handleFollowChange(isNowFollowing: Bool, appEnvironment: AppEnvironment) {
        // Update local state immediately (optimistic update)
        isFollowing = isNowFollowing
        isMutualFollow = isNowFollowing && theyFollowMe

        // Optimistically update follower count
        if let currentFollowers = followers {
            followers = isNowFollowing ? currentFollowers + 1 : max(0, currentFollowers - 1)
        }

        // Refresh from server in background to ensure consistency
        Task {
            guard let userId = profile?.id else { return }
            // Small delay to allow the follow action to complete
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await loadFollowStatus(userId: userId, appEnvironment: appEnvironment)

            // Recalculate shared places if mutual follow status changed
            if isMutualFollow {
                await loadPlaces(userId: userId, appEnvironment: appEnvironment)
            }
        }
    }

    func updateFollowCounts(appEnvironment: AppEnvironment) async {
        guard let userId = profile?.id else { return }

        do {
            let followersList = try await appEnvironment.profileService.fetchFollowers(userId: userId)
            let followingList = try await appEnvironment.profileService.fetchFollowing(userId: userId)
            followers = followersList.count
            following = followingList.count
        } catch {}
    }
}
