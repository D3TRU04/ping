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
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            }

            Spacer()

            Text(viewModel.groupDetails?.name ?? "Group")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
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
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.mint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.mint.opacity(0.1))
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

                    if !viewModel.allMembers.isEmpty {
                        Divider()
                            .padding(.leading, 54)
                    }
                }

                ForEach(Array(viewModel.allMembers.enumerated()), id: \.element.id) { index, member in
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

                    if index < viewModel.allMembers.count - 1 {
                        Divider()
                            .padding(.leading, 54)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
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

            if viewModel.isLoadingPlaces {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                let places = viewModel.selectedPlaceType == .wantToTry
                    ? viewModel.wantToTryPlaces
                    : viewModel.beenPlaces

                if places.isEmpty {
                    emptyPlacesView
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(places.enumerated()), id: \.element.id) { index, place in
                            GroupCommonPlaceRow(place: place)

                            if index < places.count - 1 {
                                Divider()
                                    .padding(.leading, 70)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                }
            }
        }
    }

    var emptyPlacesView: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.selectedPlaceType == .wantToTry ? "bookmark" : "mappin.circle")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(AppColors.textTertiary)

            Text("No common \(viewModel.selectedPlaceType == .wantToTry ? "saved" : "visited") places")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)

            Text("Places that all group members have \(viewModel.selectedPlaceType == .wantToTry ? "saved" : "been to") will appear here")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}
