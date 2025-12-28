//
//  SecondaryNavBar.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/components/SecondaryNavBar.tsx
//  Secondary navigation bar with Groups dropdown and ForYou tab
//

import SwiftUI

struct SecondaryNavBar: View {
    @Binding var activeTab: SecondaryNavBarTab
    let currentUser: User?
    let onGroupSelect: (Group) -> Void
    @State private var showGroupsDropdown: Bool = false
    @State private var userGroups: [Group] = []
    @State private var groupsLoading: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Groups button with dropdown
            Button(action: {
                showGroupsDropdown.toggle()
                if !groupsLoading && userGroups.isEmpty {
                    Task {
                        await fetchUserGroups()
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Text("Groups")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(activeTab == .groups ? AppColors.mint : Color(hex: "B3B3B3"))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20))
                        .foregroundColor(activeTab == .groups ? AppColors.mint : Color(hex: "B3B3B3"))
                }
                .padding(.vertical, 6)
                .overlay(
                    Rectangle()
                        .frame(height: 3)
                        .foregroundColor(activeTab == .groups ? AppColors.mint : Color.clear)
                        .offset(y: 15)
                )
            }
            .padding(.horizontal, 12)
            
            // ForYou button
            Button(action: {
                activeTab = .forYou
            }) {
                Text("For You")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(activeTab == .forYou ? AppColors.mint : Color(hex: "B3B3B3"))
                    .padding(.vertical, 6)
                    .overlay(
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(activeTab == .forYou ? AppColors.mint : Color.clear)
                            .offset(y: 15)
                    )
            }
            .padding(.horizontal, 12)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.1)),
            alignment: .bottom
        )
        .sheet(isPresented: $showGroupsDropdown) {
            GroupsDropdownView(
                groups: userGroups,
                loading: groupsLoading,
                onGroupSelect: { group in
                    onGroupSelect(group)
                    showGroupsDropdown = false
                },
                onRefresh: {
                    Task {
                        await fetchUserGroups(forceRefresh: true)
                    }
                }
            )
        }
        .task {
            if userGroups.isEmpty {
                await fetchUserGroups()
            }
        }
    }
    
    func fetchUserGroups(forceRefresh: Bool = false) async {
        guard !groupsLoading else { return }
        groupsLoading = true
        
        // TODO: Fetch groups from Supabase
        // For now, placeholder
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        groupsLoading = false
    }
}

struct GroupsDropdownView: View {
    let groups: [Group]
    let loading: Bool
    let onGroupSelect: (Group) -> Void
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("GROUPS")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(loading ? .gray : .gray)
                }
                .disabled(loading)
            }
            .padding()
            .background(Color(hex: "F5F6FA"))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.1)),
                alignment: .bottom
            )
            
            // Groups list
            if loading {
                ProgressView()
                    .padding()
            } else if groups.isEmpty {
                Text("No groups yet")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(groups) { group in
                    Button(action: {
                        onGroupSelect(group)
                    }) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(AppColors.mint)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            
                            Text(group.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
