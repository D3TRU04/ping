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
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }

                        Spacer()

                        Text("Groups")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        Button(action: { showCreateGroup = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium)) // Slightly larger for emphasis
                                .foregroundColor(AppColors.mint)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    .background(Color.white.opacity(0.8)) // Optional: Add subtle background or keep transparent

                    // Content
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                                .scaleEffect(1.2)
                            Text("Loading groups...")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                        }
                    } else if viewModel.groups.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "6EE7E7").opacity(0.1), Color(hex: "1FC9C3").opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .blur(radius: 10)

                                Image(systemName: "person.3")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(Color(hex: "B2BEC3"))
                            }

                            VStack(spacing: 8) {
                                Text("No Groups Yet")
                                    .font(.system(size: 22, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)

                                Text("Create a group to see common places with friends")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }

                            Button(action: { showCreateGroup = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16))
                                    Text("Create Group")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color(hex: "1FC9C3"), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                            }
                            .padding(.top, 8)

                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(viewModel.groups.enumerated()), id: \.element.id) { index, group in
                                    GroupRow(
                                        group: group,
                                        isOwner: group.createdBy == appEnvironment.currentUser?.id,
                                        onTap: {
                                            selectedGroupId = group.id
                                            navigateToDetail = true
                                        },
                                        onDelete: {
                                            Task {
                                                await viewModel.deleteGroup(groupId: group.id)
                                            }
                                        }
                                    )
                                    
                                    if index < viewModel.groups.count - 1 {
                                        Divider()
                                            .padding(.leading, 70)
                                            .padding(.trailing, 0)
                                            .opacity(0.4)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            .padding(.bottom, 100)
                        }
                    }
                }

                // Navigation to GroupDetail
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

struct GroupRow: View {
    let group: GroupsService.Group
    let isOwner: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var showDeleteConfirmation = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Group Icon
                ZStack {
                    Circle()
                        .fill(AppColors.borderSubtle)
                        .frame(width: 54, height: 54)

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textSecondary)
                }

                // Group Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text("\(group.memberCount ?? 1) member\((group.memberCount ?? 1) == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)

                        if isOwner {
                            Text("Owner")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.mint)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.mint.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer()

                // Delete button (for owners) or chevron
                if isOwner {
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textTertiary)
                            .frame(width: 36, height: 36)
                            .background(Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary.opacity(0.4))
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Delete Group", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete \"\(group.name)\"? This action cannot be undone.")
        }
    }
}
