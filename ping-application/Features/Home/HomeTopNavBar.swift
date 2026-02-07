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

    private var showRedo: Bool {
        activeTab == .today && onReplayGame != nil
    }

    var body: some View {
        ZStack {
            // Left: Logo
            HStack {
                Image("2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 56)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                Spacer()
            }

            // Center: Tabs (absolutely centered, shifts left when redo visible)
            TikTokTabView(activeTab: $activeTab)
                .offset(x: showRedo ? -56 : 0)

            // Right: Action buttons
            HStack {
                Spacer()

                HStack(spacing: 8) {
                    // Replay Game Button (only visible on Today tab)
                    if let onReplayGame = onReplayGame {
                        GlassCircleButton(
                            icon: "arrow.counterclockwise",
                            isActive: false,
                            action: onReplayGame
                        )
                        .opacity(showRedo ? 1 : 0)
                        .scaleEffect(showRedo ? 1 : 0.5)
                        .disabled(!showRedo)
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
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(selectedGroup != nil ? .white : AppColors.textPrimary)
                            .frame(width: 48, height: 48)
                            .background(
                                Group {
                                    if selectedGroup != nil {
                                        ZStack {
                                            Circle().fill(Color.white.opacity(0.25))
                                            AppColors.mint.opacity(0.8)
                                        }
                                    } else {
                                        GlassSurface(cornerRadius: 24, opacity: 0.05) {
                                            Color.clear
                                        }
                                    }
                                }
                            )
                            .clipShape(Circle())
                            .overlay(
                                ZStack {
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                stops: [
                                                    .init(color: .white.opacity(0.95), location: 0.0),
                                                    .init(color: .white.opacity(0.6), location: 0.3),
                                                    .init(color: .white.opacity(0.4), location: 0.6),
                                                    .init(color: .white.opacity(0.7), location: 1.0)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                    Circle()
                                        .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                                        .padding(1)
                                }
                            )
                            .shadow(
                                color: selectedGroup != nil ? AppColors.mint.opacity(0.4) : Color.black.opacity(0.08),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                    }
                    .buttonStyle(ScaleButtonStyle(scale: 0.9))

                    // Filter Button
                    GlassCircleButton(
                        icon: "slider.horizontal.3",
                        isActive: filtersActive,
                        action: { onFilterTap?() }
                    )
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activeTab)
        .padding(.bottom, 8)
    }
}
