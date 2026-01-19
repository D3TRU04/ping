//
//  ProfileViewModel.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/main/page.tsx
//  Updated ViewModel matching RN state management
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var followers: Int = 0
    @Published var following: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Places data for profile tabs
    @Published var likedPlaces: [PlaceVisit] = []
    @Published var savedPlaces: [CollectionsService.SavedPlace] = []
    @Published var collections: [CollectionsService.Collection] = []
    @Published var isLoadingPlaces: Bool = false

    var currentUser: User? {
        user
    }

    var profilePicture: ImageSource {
        if let pictureUrl = user?.profilePicture, let url = URL(string: pictureUrl) {
            return .url(url)
        }
        return .image("profilepic") // Default placeholder
    }

    var creationDate: String? {
        guard let createdAt = user?.createdAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: createdAt)
    }

    func load(userId: String, appEnvironment: AppEnvironment) async {
        guard !userId.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            // Load user profile from Convex
            user = try await appEnvironment.profileService.fetchProfile(userId: userId)

            // Load follower/following counts
            await refreshFollowCounts(appEnvironment: appEnvironment)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshFollowCounts(appEnvironment: AppEnvironment) async {
        guard let userId = user?.id else { return }

        do {
            let followersList = try await appEnvironment.profileService.fetchFollowers(userId: userId)
            let followingList = try await appEnvironment.profileService.fetchFollowing(userId: userId)

            followers = followersList.count
            following = followingList.count
        } catch {
            // Handle error silently for follow counts
        }
    }

    // MARK: - Places Data (for Profile Tabs)

    func loadLikedPlaces(appEnvironment: AppEnvironment) async {
        guard let userId = user?.id else { return }

        isLoadingPlaces = true

        do {
            likedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(userId: userId, limit: 100)
        } catch {
            print("❌ Error loading liked places: \(error)")
        }

        isLoadingPlaces = false
    }

    func loadSavedPlaces(appEnvironment: AppEnvironment) async {
        guard let userId = user?.id else { return }

        isLoadingPlaces = true

        do {
            savedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(userId: userId, limit: 100)
            collections = try await appEnvironment.collectionsService.getUserCollections(userId: userId)
        } catch {
            print("❌ Error loading saved places: \(error)")
        }

        isLoadingPlaces = false
    }

    func loadAllPlaces(appEnvironment: AppEnvironment) async {
        guard let userId = user?.id else { return }

        isLoadingPlaces = true

        do {
            async let liked = appEnvironment.placesService.getUserVisitedPlaces(userId: userId, limit: 100)
            async let saved = appEnvironment.collectionsService.getUserSavedPlaces(userId: userId, limit: 100)
            async let cols = appEnvironment.collectionsService.getUserCollections(userId: userId)

            likedPlaces = try await liked
            savedPlaces = try await saved
            collections = try await cols
        } catch {
            print("❌ Error loading places: \(error)")
        }

        isLoadingPlaces = false
    }
}
