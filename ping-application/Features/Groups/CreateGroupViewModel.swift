//
//  CreateGroupViewModel.swift
//  PingNative
//
//  State management for group creation
//

import Foundation
import Combine

@MainActor
class CreateGroupViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var selectedMembers: [UserSearchResult] = []
    @Published var searchQuery: String = ""
    @Published var searchResults: [UserSearchResult] = []
    @Published var isSearching: Bool = false
    @Published var isCreating: Bool = false
    @Published var errorMessage: String?

    private var groupsService: GroupsService?
    private var profileService: ProfileService?
    private var currentUserId: String?

    func configure(groupsService: GroupsService, profileService: ProfileService, userId: String?) {
        self.groupsService = groupsService
        self.profileService = profileService
        self.currentUserId = userId
    }

    var isValid: Bool {
        !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !selectedMembers.isEmpty
    }

    func searchUsers(query: String) async {
        guard !query.isEmpty, query.count >= 2, let profileService = profileService else {
            searchResults = []
            return
        }

        isSearching = true

        do {
            let results = try await profileService.searchUsers(query: query, limit: 20)

            // Filter out already selected members and current user
            searchResults = results
                .filter { result in
                    !selectedMembers.contains(where: { $0.id == result.id }) &&
                    result.id != currentUserId
                }
                .map { result in
                    UserSearchResult(
                        id: result.id,
                        username: result.username,
                        fullName: result.fullName,
                        avatarUrl: result.avatarUrl
                    )
                }
        } catch {
            print("Error searching users: \(error)")
            searchResults = []
        }

        isSearching = false
    }

    func addMember(_ user: UserSearchResult) {
        if !selectedMembers.contains(where: { $0.id == user.id }) {
            selectedMembers.append(user)
            // Remove from search results
            searchResults.removeAll { $0.id == user.id }
        }
    }

    func removeMember(_ user: UserSearchResult) {
        selectedMembers.removeAll { $0.id == user.id }
    }

    func createGroup() async -> Bool {
        guard let groupsService = groupsService, let userId = currentUserId else {
            errorMessage = "Groups service not configured"
            return false
        }

        guard isValid else {
            errorMessage = "Please enter a group name and add at least one member"
            return false
        }

        isCreating = true
        errorMessage = nil

        do {
            let memberIds = selectedMembers.map { $0.id }
            _ = try await groupsService.createGroup(
                ownerId: userId,
                name: groupName.trimmingCharacters(in: .whitespacesAndNewlines),
                memberIds: memberIds
            )
            isCreating = false
            return true
        } catch {
            print("Error creating group: \(error)")
            errorMessage = error.localizedDescription
            isCreating = false
            return false
        }
    }

    func reset() {
        groupName = ""
        selectedMembers = []
        searchQuery = ""
        searchResults = []
        errorMessage = nil
    }
}
