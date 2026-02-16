//
//  FollowListViewModel.swift
//  PingNative
//
//  ViewModel for inline followers/following list on profile screen
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FollowListViewModel: ObservableObject {
    @Published var followers: [User] = []
    @Published var following: [User] = []
    @Published var isLoading: Bool = false
    @Published var searchQuery: String = ""

    // Maps user ID -> whether the current user is following them
    @Published var isFollowingMap: [String: Bool] = [:]
    // Maps user ID -> whether they follow the current user
    @Published var theyFollowMeMap: [String: Bool] = [:]

    func load(userId: String, appEnvironment: AppEnvironment) async {
        guard !userId.isEmpty else { return }

        isLoading = true

        do {
            async let fetchedFollowers = appEnvironment.profileService.fetchFollowers(userId: userId)
            async let fetchedFollowing = appEnvironment.profileService.fetchFollowing(userId: userId)

            let followersList = try await fetchedFollowers
            let followingList = try await fetchedFollowing

            followers = followersList
            following = followingList

            // Build follow maps from the lists:
            // "following" list = users the current user follows
            // "followers" list = users who follow the current user
            let followingIds = Set(followingList.map { $0.id })
            let followerIds = Set(followersList.map { $0.id })

            var newIsFollowingMap: [String: Bool] = [:]
            var newTheyFollowMeMap: [String: Bool] = [:]

            // For all users in both lists, build maps
            let allUsers = Set(followersList.map { $0.id } + followingList.map { $0.id })
            for uid in allUsers {
                newIsFollowingMap[uid] = followingIds.contains(uid)
                newTheyFollowMeMap[uid] = followerIds.contains(uid)
            }

            isFollowingMap = newIsFollowingMap
            theyFollowMeMap = newTheyFollowMeMap
        } catch {
            print("Error loading follow lists: \(error)")
        }

        isLoading = false
    }

    func filteredFollowers() -> [User] {
        guard !searchQuery.isEmpty else { return followers }
        let query = searchQuery.lowercased()
        return followers.filter {
            ($0.fullName?.lowercased().contains(query) ?? false) ||
            ($0.username?.lowercased().contains(query) ?? false)
        }
    }

    func filteredFollowing() -> [User] {
        guard !searchQuery.isEmpty else { return following }
        let query = searchQuery.lowercased()
        return following.filter {
            ($0.fullName?.lowercased().contains(query) ?? false) ||
            ($0.username?.lowercased().contains(query) ?? false)
        }
    }

    func toggleFollow(userId: String, currentUserId: String, appEnvironment: AppEnvironment) async {
        let wasFollowing = isFollowingMap[userId] ?? false

        // Optimistic update
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            isFollowingMap[userId] = !wasFollowing
        }

        do {
            if !wasFollowing {
                // Follow
                try await appEnvironment.profileService.followUser(
                    followerId: currentUserId,
                    followingId: userId
                )
                // Send follow notification
                let senderName = appEnvironment.currentUser?.fullName ?? appEnvironment.currentUser?.username ?? "Someone"
                try? await appEnvironment.notificationsService.createNotification(
                    recipientId: userId,
                    senderId: currentUserId,
                    type: "follow",
                    title: "New Follower",
                    message: "\(senderName) started following you",
                    metadata: ["sender_name": senderName, "sender_id": currentUserId]
                )
            } else {
                // Unfollow
                try await appEnvironment.profileService.unfollowUser(
                    followerId: currentUserId,
                    followingId: userId
                )
            }
        } catch {
            print("Error toggling follow: \(error)")
            // Rollback on error
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                isFollowingMap[userId] = wasFollowing
            }
        }
    }
}
