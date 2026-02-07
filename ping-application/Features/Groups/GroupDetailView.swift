//
//  GroupDetailView.swift
//  PingNative
//
//  View group details and common places
//
//  Related files:
//  - GroupDetailView+Sections.swift - Section views
//

import SwiftUI

struct GroupDetailView: View {
    let groupId: String
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject var viewModel = GroupDetailViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                headerSection

                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                        Spacer()
                    }
                    .transition(.opacity)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            membersSection
                            commonPlacesSection
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.isLoading)
        }
        .navigationBarHidden(true)
        .task {
            viewModel.configure(
                groupsService: appEnvironment.groupsService,
                userId: appEnvironment.currentUser?.id
            )
            await viewModel.loadGroupDetails(groupId: groupId)
            await viewModel.loadCommonPlaces(groupId: groupId)
        }
    }
}
