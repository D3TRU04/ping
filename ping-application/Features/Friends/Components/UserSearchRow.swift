//
//  UserSearchRow.swift
//  PingNative
//
//  Row component for user search results
//

import SwiftUI

struct UserSearchRow: View {
    let user: UserSearchResult
    let onTap: () -> Void
    var onRemove: (() -> Void)? = nil

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(AppColors.borderSubtle)
                        .frame(width: 54, height: 54)

                    if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 54, height: 54)
                                    .clipShape(Circle())
                            default:
                                Image(systemName: "person.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }

                // User Info
                VStack(alignment: .leading, spacing: 3) {
                    if let fullName = user.fullName, !fullName.isEmpty {
                        Text(fullName)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                    }

                    Text("@\(user.username)")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                if let onRemove = onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppColors.textTertiary)
                            .frame(width: 30, height: 30)
                            .background(Color.black.opacity(0.04))
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppColors.textTertiary.opacity(0.4))
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
