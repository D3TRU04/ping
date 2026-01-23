//
//  GroupMemberPickerView.swift
//  PingNative
//
//  User selection with multi-select for group members
//

import SwiftUI

struct GroupMemberPickerView: View {
    @Binding var searchQuery: String
    @Binding var searchResults: [UserSearchResult]
    @Binding var selectedMembers: [UserSearchResult]
    let isSearching: Bool
    let onSearch: (String) async -> Void
    let onAddMember: (UserSearchResult) -> Void
    let onRemoveMember: (UserSearchResult) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Selected Members Chips
            if !selectedMembers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedMembers) { member in
                            MemberChip(member: member) {
                                onRemoveMember(member)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }

            // Search Input
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppColors.textTertiary)

                TextField("Search friends to add...", text: $searchQuery)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .onChange(of: searchQuery) { newValue in
                        Task {
                            await onSearch(newValue)
                        }
                    }

                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.borderSubtle, lineWidth: 1)
            )

            // Search Results
            if isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                    Spacer()
                }
                .padding(.vertical, 8)
            } else if !searchQuery.isEmpty && searchResults.isEmpty {
                Text("No users found")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else if !searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(searchResults.prefix(5).enumerated()), id: \.element.id) { index, user in
                        SearchResultRow(user: user) {
                            onAddMember(user)
                            searchQuery = ""
                        }

                        if index < min(searchResults.count, 5) - 1 {
                            Divider()
                                .padding(.leading, 54)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.borderSubtle, lineWidth: 1)
                )
            }
        }
    }
}

struct MemberChip: View {
    let member: UserSearchResult
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Avatar
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
                    .font(.system(size: 10, weight: .bold))
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
                // Avatar
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
