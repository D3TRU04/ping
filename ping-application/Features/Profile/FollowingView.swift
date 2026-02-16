//
//  FollowingView.swift
//  PingNative
//
//  Following list view
//

import SwiftUI
import Combine

struct FollowingView: View {
    let userId: String
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = FollowingViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LiquidGlassBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Glass-style nav bar
                HStack(alignment: .center) {
                    GlassCircleButton(icon: "arrow.backward", action: { dismiss() })

                    Spacer()

                    Text("Following")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    // Invisible spacer for centering
                    Color.clear
                        .frame(width: 48, height: 48)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                if viewModel.loading {
                    ProgressView()
                        .tint(AppColors.mint)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.following.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 64))
                            .foregroundColor(AppColors.textTertiary)

                        Text("Not following anyone yet")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.following) { user in
                        FollowerRow(user: user) {
                            // Navigate to user profile
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.load(userId: userId, appEnvironment: appEnvironment)
        }
    }
}

@MainActor
class FollowingViewModel: ObservableObject {
    @Published var following: [User] = []
    @Published var loading: Bool = false

    func load(userId: String, appEnvironment: AppEnvironment) async {
        loading = true

        do {
            following = try await appEnvironment.profileService.fetchFollowing(userId: userId)
        } catch {
            // Handle error
        }

        loading = false
    }
}
