//
//  HomeTopNavBar.swift
//  PingNative
//
//  TikTok-style top navigation bar with centered tabs and right-side actions
//

import SwiftUI

struct HomeTopNavBar: View {
    @Binding var activeTab: SecondaryNavBarTab
    let currentUser: User?
    var filtersActive: Bool = false
    var onFilterTap: (() -> Void)? = nil
    var groups: [GroupsService.Group] = []
    @Binding var selectedGroup: GroupsService.Group?
    var onManageGroups: (() -> Void)? = nil
    var onReplayGame: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center) {
            // Logo from Assets (2.png)
            Image("2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 44)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

            Spacer()

            // TikTok-style tab selector (centered)
            TikTokTabView(activeTab: $activeTab)

            Spacer()

            // Right-side action buttons
            HStack(spacing: 8) {
                // Replay Game Button (only visible on Today tab)
                if let onReplayGame = onReplayGame {
                    GlassCircleButton(
                        icon: "arrow.counterclockwise",
                        isActive: false,
                        action: onReplayGame
                    )
                    .opacity(activeTab == .today ? 1 : 0)
                    .disabled(activeTab != .today)
                }

                // Group Menu Button
                Menu {
                    Button(action: {
                        onManageGroups?()
                    }) {
                        HStack {
                            Text("Manage Groups")
                            Image(systemName: "person.3")
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 14, weight: .regular))
                        if let group = selectedGroup {
                            Text(group.name)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(selectedGroup != nil ? .white : AppColors.textPrimary)
                    .padding(.horizontal, selectedGroup != nil ? 14 : 12)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if selectedGroup != nil {
                                ZStack {
                                    GlassSurface(cornerRadius: 20, opacity: 0.1) {
                                        Color.clear
                                    }
                                    AppColors.mint.opacity(0.8)
                                }
                            } else {
                                GlassSurface(cornerRadius: 20, opacity: 0.06) {
                                    Color.clear
                                }
                            }
                        }
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                selectedGroup != nil ? Color.white.opacity(0.4) : Color.white.opacity(0.3),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(
                        color: selectedGroup != nil ? AppColors.mint.opacity(0.4) : Color.black.opacity(0.05),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .buttonStyle(ScaleButtonStyle(scale: 0.95))

                // Filter Button
                GlassCircleButton(
                    icon: "slider.horizontal.3",
                    isActive: filtersActive,
                    action: { onFilterTap?() }
                )
            }
        }
        .padding(.bottom, 16)
        .background(Color.clear)
    }
}
