//
//  GroupsView.swift
//  PingNative
//
//  Main groups list sheet
//

import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = GroupsViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showCreateGroup = false
    @State private var selectedGroupId: String?
    @State private var navigateToDetail = false

    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    GroupsHeader(
                        onDismiss: { dismiss() },
                        onCreateGroup: { showCreateGroup = true }
                    )

                    if viewModel.isLoading {
                        GroupsLoadingView()
                    } else if viewModel.groups.isEmpty {
                        GroupsEmptyStateView(onCreateGroup: { showCreateGroup = true })
                    } else {
                        GroupsListView(
                            groups: viewModel.groups,
                            currentUserId: appEnvironment.currentUser?.id,
                            selectedGroupId: $selectedGroupId,
                            navigateToDetail: $navigateToDetail,
                            onDeleteGroup: { groupId in
                                Task {
                                    await viewModel.deleteGroup(groupId: groupId)
                                }
                            }
                        )
                    }
                }

                NavigationLink(
                    destination: Group {
                        if let groupId = selectedGroupId {
                            GroupDetailView(groupId: groupId)
                                .environmentObject(appEnvironment)
                        }
                    },
                    isActive: $navigateToDetail
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCreateGroup) {
            CreateGroupSheet(onGroupCreated: {
                Task {
                    await viewModel.loadGroups()
                }
            })
            .environmentObject(appEnvironment)
        }
        .task {
            viewModel.configure(
                groupsService: appEnvironment.groupsService,
                userId: appEnvironment.currentUser?.id
            )
            await viewModel.loadGroups()
        }
    }
}
