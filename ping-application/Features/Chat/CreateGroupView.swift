//
//  CreateGroupView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/chat/group-chat/components/CreateGroup.tsx
//  Create group chat screen
//

import SwiftUI
import Combine

struct CreateGroupView: View {
    let selectedUsers: [User]
    let currentUser: User
    @StateObject private var viewModel = CreateGroupViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "FAF6F2").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.mint)
                    }
                    
                    Text("New Group")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.createGroup(
                                name: viewModel.groupName,
                                selectedUsers: selectedUsers,
                                currentUser: currentUser
                            )
                        }
                    }) {
                        if viewModel.creating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Create")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        viewModel.canCreate
                            ? AppColors.mint
                            : Color.gray.opacity(0.3)
                    )
                    .cornerRadius(8)
                    .disabled(!viewModel.canCreate || viewModel.creating)
                }
                .padding()
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Group Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Group Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            TextField("Enter group name...", text: $viewModel.groupName)
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(hex: "F5F6FA"))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Selected Members
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(selectedUsers.count) members selected")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                            
                            ForEach(selectedUsers) { user in
                                SelectedUserRow(user: user)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "Failed to create group")
        }
    }
}

struct SelectedUserRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let avatar = user.avatar, let url = URL(string: avatar) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    Text((user.name ?? user.username ?? "U").prefix(1).uppercased())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            Text(user.name ?? user.username ?? "User")
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

@MainActor
class CreateGroupViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var creating: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String? = nil
    
    var canCreate: Bool {
        !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func createGroup(name: String, selectedUsers: [User], currentUser: User) async {
        guard canCreate else {
            errorMessage = "Please enter a group name"
            showError = true
            return
        }
        
        guard selectedUsers.count >= 1 else {
            errorMessage = "Please select at least 1 user"
            showError = true
            return
        }
        
        creating = true
        errorMessage = nil
        
        do {
            // TODO: Create group in Supabase
            // 1. Create group record
            // 2. Add members to group_members table
            // 3. Send system message
            // 4. Navigate to group chat
            
            // Placeholder implementation
            let groupId = UUID().uuidString
            
            // After successful creation, navigate to group chat
            // This would typically be handled by the parent view
            // using NavigationLink or a callback
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        creating = false
    }
}
