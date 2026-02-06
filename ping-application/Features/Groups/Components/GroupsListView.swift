//
//  GroupsListView.swift
//  PingNative
//
//  List view and row components for groups
//

import SwiftUI

struct GroupsListView: View {
    let groups: [GroupsService.Group]
    let currentUserId: String?
    @Binding var selectedGroupId: String?
    @Binding var navigateToDetail: Bool
    let onDeleteGroup: (String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(groups, id: \.id) { group in
                    GroupRow(
                        group: group,
                        isOwner: group.createdBy == currentUserId,
                        onTap: {
                            selectedGroupId = group.id
                            navigateToDetail = true
                        },
                        onDelete: {
                            onDeleteGroup(group.id)
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 100)
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
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 54, height: 54)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                        )

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text("\(group.memberCount ?? 1) member\((group.memberCount ?? 1) == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)

                        if isOwner {
                            Text("Owner")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.mint)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.mint.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer()

                if isOwner {
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppColors.textTertiary)
                            .frame(width: 36, height: 36)
                            .background(Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppColors.textTertiary.opacity(0.4))
                }
            }
            .padding(18)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
        .glassCardStyle(cornerRadius: 30, opacity: 0.08)
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
