//
//  GroupMemberPickerComponents.swift
//  PingNative
//
//  Components for group member picker view
//

import SwiftUI

struct MemberChip: View {
    let member: UserSearchResult
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            if let avatarUrl = member.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                    default:
                        Circle()
                            .fill(AppColors.borderSubtle)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textTertiary)
                            )
                    }
                }
            } else {
                Circle()
                    .fill(AppColors.borderSubtle)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textTertiary)
                    )
            }

            Text(member.fullName ?? member.username)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "F3F4F6"))
        .clipShape(Capsule())
    }
}

struct SearchResultRow: View {
    let user: UserSearchResult
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
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
                                .fill(AppColors.borderSubtle)
                                .frame(width: 42, height: 42)
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
                    if let fullName = user.fullName, !fullName.isEmpty {
                        Text(fullName)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                    }

                    Text("@\(user.username)")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.mint)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
