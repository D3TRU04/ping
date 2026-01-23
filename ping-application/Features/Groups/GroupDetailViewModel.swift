//
//  GroupDetailViewModel.swift
//  PingNative
//
//  State management for group detail view
//

import Foundation
import Combine

@MainActor
class GroupDetailViewModel: ObservableObject {
    @Published var groupDetails: GroupsService.GroupDetails?
    @Published var wantToTryPlaces: [GroupsService.CommonPlace] = []
    @Published var beenPlaces: [GroupsService.CommonPlace] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingPlaces: Bool = false
    @Published var errorMessage: String?
    @Published var selectedPlaceType: PlaceTypeTab = .wantToTry

    private var groupsService: GroupsService?
    private var currentUserId: String?

    enum PlaceTypeTab: String, CaseIterable {
        case wantToTry = "Want to Try"
        case been = "Been"
    }

    func configure(groupsService: GroupsService, userId: String?) {
        self.groupsService = groupsService
        self.currentUserId = userId
    }

    var isOwner: Bool {
        groupDetails?.createdBy == currentUserId
    }

    var allMembers: [GroupsService.GroupMember] {
        groupDetails?.members ?? []
    }

    var memberCount: Int {
        (groupDetails?.members.count ?? 0) + 1 // +1 for owner
    }

    func loadGroupDetails(groupId: String) async {
        guard let groupsService = groupsService else {
            errorMessage = "Groups service not configured"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            groupDetails = try await groupsService.getGroupDetails(groupId: groupId)
        } catch {
            print("Error loading group details: \(error)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadCommonPlaces(groupId: String) async {
        guard let groupsService = groupsService else {
            return
        }

        isLoadingPlaces = true

        do {
            async let wantToTry = groupsService.getGroupCommonPlaces(
                groupId: groupId,
                placeType: .saved
            )
            async let been = groupsService.getGroupCommonPlaces(
                groupId: groupId,
                placeType: .been
            )

            wantToTryPlaces = try await wantToTry
            beenPlaces = try await been
        } catch {
            print("Error loading common places: \(error)")
        }

        isLoadingPlaces = false
    }

    func removeMember(groupId: String, userId: String) async {
        guard let groupsService = groupsService, let requesterId = currentUserId else {
            return
        }

        do {
            try await groupsService.removeMember(
                groupId: groupId,
                userId: userId,
                requesterId: requesterId
            )
            // Reload group details
            await loadGroupDetails(groupId: groupId)
        } catch {
            print("Error removing member: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func refresh(groupId: String) async {
        await loadGroupDetails(groupId: groupId)
        await loadCommonPlaces(groupId: groupId)
    }
}
