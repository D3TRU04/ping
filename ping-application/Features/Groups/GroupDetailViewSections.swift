//
//  GroupDetailView+Sections.swift
//  PingNative
//
//  Section views for group detail
//

import SwiftUI

extension GroupDetailView {

    var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                    )
            }

            Spacer()

            Text(viewModel.groupDetails?.name ?? "Group")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Members")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text("\(viewModel.memberCount)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.mint)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(AppColors.mint.opacity(0.15))
                    .clipShape(Capsule())
            }

            VStack(spacing: 0) {
                if let owner = viewModel.groupDetails?.owner {
                    GroupMemberRow(
                        username: owner.username,
                        fullName: owner.fullName,
                        profilePicture: owner.profilePicture,
                        isOwner: true,
                        canRemove: false,
                        onRemove: {}
                    )
                }

                ForEach(viewModel.allMembers, id: \.id) { member in
                    GroupMemberRow(
                        username: member.username,
                        fullName: member.fullName,
                        profilePicture: member.profilePicture,
                        isOwner: false,
                        canRemove: viewModel.isOwner,
                        onRemove: {
                            Task {
                                await viewModel.removeMember(groupId: groupId, userId: member.id)
                            }
                        }
                    )
                }
            }
            .glassCardStyle(cornerRadius: 30, opacity: 0.08)
        }
    }

    var commonPlacesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Common Places")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .textCase(.uppercase)
                .tracking(0.5)
                .foregroundColor(AppColors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GroupDetailViewModel.PlaceTypeTab.allCases, id: \.rawValue) { tab in
                        GroupPlaceTypeTabButton(
                            title: tab.rawValue,
                            count: tab == .wantToTry ? viewModel.wantToTryPlaces.count : viewModel.beenPlaces.count,
                            isActive: viewModel.selectedPlaceType == tab
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                viewModel.selectedPlaceType = tab
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)
            }

            Group {
                if viewModel.isLoadingPlaces {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    .transition(.opacity)
                } else {
                    let places = viewModel.selectedPlaceType == .wantToTry
                        ? viewModel.wantToTryPlaces
                        : viewModel.beenPlaces

                    if places.isEmpty {
                        emptyPlacesView
                            .transition(.opacity)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(places, id: \.id) { place in
                                GroupCommonPlaceRow(place: place)
                            }
                        }
                        .glassCardStyle(cornerRadius: 30, opacity: 0.08)
                        .transition(.opacity)
                    }
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.selectedPlaceType)
            .animation(.easeInOut(duration: 0.25), value: viewModel.isLoadingPlaces)
        }
    }

    var emptyPlacesView: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.selectedPlaceType == .wantToTry ? "bookmark" : "mappin.circle")
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(AppColors.textSecondary)

            Text("No common \(viewModel.selectedPlaceType == .wantToTry ? "saved" : "visited") places")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Text("Places that all group members have \(viewModel.selectedPlaceType == .wantToTry ? "saved" : "been to") will appear here")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .glassCardStyle(cornerRadius: 30, opacity: 0.08)
    }
}
