//
//  CreateGroupSheet.swift
//  PingNative
//
//  Modal for creating new groups
//

import SwiftUI

struct CreateGroupSheet: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = CreateGroupViewModel()
    @Environment(\.dismiss) var dismiss
    let onGroupCreated: () -> Void

    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Group Name Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Group Name")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .foregroundColor(AppColors.textSecondary)

                            TextField("Enter group name", text: $viewModel.groupName)
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.borderSubtle, lineWidth: 1)
                                )
                        }

                        // Members Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Add Members")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                    .foregroundColor(AppColors.textSecondary)

                                Spacer()

                                if !viewModel.selectedMembers.isEmpty {
                                    Text("\(viewModel.selectedMembers.count) selected")
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.mint)
                                }
                            }

                            GroupMemberPickerView(
                                searchQuery: $viewModel.searchQuery,
                                searchResults: $viewModel.searchResults,
                                selectedMembers: $viewModel.selectedMembers,
                                isSearching: viewModel.isSearching,
                                onSearch: { query in
                                    await viewModel.searchUsers(query: query)
                                },
                                onAddMember: { member in
                                    viewModel.addMember(member)
                                },
                                onRemoveMember: { member in
                                    viewModel.removeMember(member)
                                }
                            )
                        }

                        // Error Message
                        if let error = viewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(AppColors.error)
                                Text(error)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.error)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(AppColors.error.opacity(0.1))
                            .cornerRadius(12)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }

                // Create Button
                VStack {
                    Spacer()

                    Button(action: {
                        Task {
                            let success = await viewModel.createGroup()
                            if success {
                                onGroupCreated()
                                dismiss()
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if viewModel.isCreating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 16))
                                Text("Create Group")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16) // Increased padding
                        .background(
                            Group {
                                if viewModel.isValid && !viewModel.isCreating {
                                    LinearGradient(
                                        colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                } else {
                                    Color(hex: "E5E5EA")
                                }
                            }
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(viewModel.isValid && !viewModel.isCreating ? Color(hex: "1FC9C3") : Color.clear, lineWidth: 1)
                        )
                        .shadow(
                            color: viewModel.isValid ? Color.black.opacity(0.12) : Color.clear,
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                    }
                    .disabled(!viewModel.isValid || viewModel.isCreating)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .background(
                        LinearGradient(
                            colors: [backgroundColor.opacity(0), backgroundColor],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        .allowsHitTesting(false)
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("New Group")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .onAppear {
            viewModel.configure(
                groupsService: appEnvironment.groupsService,
                profileService: appEnvironment.profileService,
                userId: appEnvironment.currentUser?.id
            )
        }
    }
}
