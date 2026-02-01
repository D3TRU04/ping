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
            Color(hex: "FAF6F2")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }

                    Text("Following")
                        .font(.system(size: 20, weight: .regular))

                    Spacer()
                }
                .padding()
                .background(Color.white)

                if viewModel.loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.following.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)

                        Text("Not following anyone yet")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.gray)
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
