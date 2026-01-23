//
//  GroupsViewModel.swift
//  PingNative
//
//  State management for groups list
//

import Foundation
import Combine

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var groups: [GroupsService.Group] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var groupsService: GroupsService?
    private var currentUserId: String?

    func configure(groupsService: GroupsService, userId: String?) {
        self.groupsService = groupsService
        self.currentUserId = userId
    }

    func loadGroups() async {
        guard let groupsService = groupsService, let userId = currentUserId else {
            errorMessage = "Groups service not configured"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            groups = try await groupsService.getUserGroups(userId: userId)
        } catch {
            print("Error loading groups: \(error)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteGroup(groupId: String) async {
        guard let groupsService = groupsService, let userId = currentUserId else {
            return
        }

        do {
            try await groupsService.deleteGroup(groupId: groupId, userId: userId)
            // Remove from local list
            groups.removeAll { $0.id == groupId }
        } catch {
            print("Error deleting group: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await loadGroups()
    }
}
