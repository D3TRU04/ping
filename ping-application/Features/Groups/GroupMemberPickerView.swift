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

