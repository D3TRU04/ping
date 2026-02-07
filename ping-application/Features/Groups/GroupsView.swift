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

    var body: some View {
        NavigationView {
            ZStack {
                LiquidGlassBackground()

                VStack(spacing: 0) {
                    GroupsHeader(
                        onDismiss: { dismiss() },
                        onCreateGroup: { showCreateGroup = true }
                    )

                    Group {
                        if viewModel.isLoading {
                            GroupsLoadingView()
                                .transition(.opacity)
                        } else if viewModel.groups.isEmpty {
                            GroupsEmptyStateView(onCreateGroup: { showCreateGroup = true })
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.isLoading)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.groups.isEmpty)
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
