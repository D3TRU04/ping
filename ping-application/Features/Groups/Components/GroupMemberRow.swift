//
//  GroupMemberRow.swift
//  PingNative
//
//  Member row component for group detail view
//

import SwiftUI

struct GroupMemberRow: View {
    let username: String?
    let fullName: String?
    let profilePicture: String?
    let isOwner: Bool
    let canRemove: Bool
    let onRemove: () -> Void
    @State private var showRemoveConfirmation = false

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let profilePicture = profilePicture, let url = URL(string: profilePicture) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 42, height: 42)
                            .clipShape(Circle())
                    default:
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 42, height: 42)
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppColors.textTertiary)
                            )
                    }
                }
            } else {
                Circle()
                    .fill(AppColors.borderSubtle)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textTertiary)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(fullName ?? username ?? "User")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    if isOwner {
                        Text("Owner")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.mint)
                            .clipShape(Capsule())
                    }
                }

                if let username = username {
                    Text("@\(username)")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if canRemove && !isOwner {
                Button(action: { showRemoveConfirmation = true }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.error.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .alert("Remove Member", isPresented: $showRemoveConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("Are you sure you want to remove this member from the group?")
        }
    }
}
