//
//  GroupDetailView.swift
//  PingNative
//
//  View group details and common places
//

import SwiftUI

struct GroupDetailView: View {
    let groupId: String
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = GroupDetailViewModel()
    @Environment(\.dismiss) var dismiss

    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 18, weight: .medium))
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

                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)

                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.mint))
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Members Section
                            membersSection

                            // Common Places Section
                            commonPlacesSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
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

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Members")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text("\(viewModel.memberCount)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.mint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.mint.opacity(0.1))
                    .clipShape(Capsule())
            }

            VStack(spacing: 0) {
                // Owner
                if let owner = viewModel.groupDetails?.owner {
                    MemberRow(
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

                // Members
                ForEach(Array(viewModel.allMembers.enumerated()), id: \.element.id) { index, member in
                    MemberRow(
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

    private var commonPlacesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Common Places")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .textCase(.uppercase)
                .tracking(0.5)
                .foregroundColor(AppColors.textSecondary)

            // Tab Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GroupDetailViewModel.PlaceTypeTab.allCases, id: \.rawValue) { tab in
                        PlaceTypeTabButton(
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
                .padding(.horizontal, 4) // Add slight padding for shadow clipping
            }

            // Places List
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
                            CommonPlaceRow(place: place)

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

    private var emptyPlacesView: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.selectedPlaceType == .wantToTry ? "bookmark" : "mappin.circle")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(AppColors.textTertiary)

            Text("No common \(viewModel.selectedPlaceType == .wantToTry ? "saved" : "visited") places")
                .font(.system(size: 15, weight: .medium, design: .rounded))
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

struct MemberRow: View {
    let username: String?
    let fullName: String?
    let profilePicture: String?
    let isOwner: Bool
    let canRemove: Bool
    let onRemove: () -> Void
    @State private var showRemoveConfirmation = false

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let profilePicture = profilePicture, let url = URL(string: profilePicture) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 42, height: 42)
                            .clipShape(Circle())
                    default:
                        Circle()
                            .fill(AppColors.borderSubtle)
                            .frame(width: 42, height: 42)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppColors.textTertiary)
                            )
                    }
                }
            } else {
                Circle()
                    .fill(AppColors.borderSubtle)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textTertiary)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(fullName ?? username ?? "User")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    if isOwner {
                        Text("Owner")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.mint)
                            .clipShape(Capsule())
                    }
                }

                if let username = username {
                    Text("@\(username)")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if canRemove && !isOwner {
                Button(action: { showRemoveConfirmation = true }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.error.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .alert("Remove Member", isPresented: $showRemoveConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("Are you sure you want to remove this member from the group?")
        }
    }
}

struct PlaceTypeTabButton: View {
    let title: String
    let count: Int
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                Text("\(count)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isActive ? Color.white.opacity(0.3) : Color.black.opacity(0.05))
                    .clipShape(Capsule())
            }
            .foregroundColor(isActive ? .white : AppColors.textSecondary)
            .padding(.horizontal, 14) // Slightly reduced horizontal padding
            .padding(.vertical, 10)
            .fixedSize(horizontal: true, vertical: false) // Ensure container grows with text
            .background(
                Group {
                    if isActive {
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color(hex: "F3F4F6")
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                isActive ? Capsule().stroke(Color(hex: "1FC9C3"), lineWidth: 1) : nil
            )
            .shadow(
                color: isActive ? Color.black.opacity(0.12) : Color.clear,
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
    }
}

struct CommonPlaceRow: View {
    let place: GroupsService.CommonPlace

    var body: some View {
        HStack(spacing: 12) {
            // Place Image
            if let imageUrl = place.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 56, height: 56)
                            .cornerRadius(12)
                    default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.borderSubtle)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.textTertiary)
                            )
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.borderSubtle)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textTertiary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(place.category)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)

                    if let subcategory = place.subcategory {
                        Text("·")
                            .foregroundColor(AppColors.textTertiary)
                        Text(subcategory)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .lineLimit(1)

                Text(place.location)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            if let rating = place.rating {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "FFD700"))
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .padding(12)
    }
}

extension GroupDetailView {
    private func getSubcategoryGradient(_ name: String) -> [Color] {
        let lowerName = name.lowercased()
        
        if lowerName.contains("coffee") || lowerName.contains("cafe") || lowerName.contains("bakery") || lowerName.contains("bread") || lowerName.contains("waffle") || lowerName.contains("crepe") || lowerName.contains("breakfast") {
            return [Color(hex: "E2D1C3"), Color(hex: "CDB4A6")]
        } else if lowerName.contains("salad") || lowerName.contains("vegan") || lowerName.contains("vegetarian") || lowerName.contains("park") || lowerName.contains("nature") || lowerName.contains("hike") {
            return [Color(hex: "A8E6CF"), Color(hex: "88D8B0")]
        } else if lowerName.contains("ocean") || lowerName.contains("sea") || lowerName.contains("water") || lowerName.contains("pool") || lowerName.contains("swim") {
            return [Color(hex: "A1C4FD"), Color(hex: "8AB6F9")]
        } else if lowerName.contains("pizza") || lowerName.contains("burger") || lowerName.contains("fast food") || lowerName.contains("taco") {
            return [Color(hex: "FAD390"), Color(hex: "F6B93B")]
        } else if lowerName.contains("dessert") || lowerName.contains("ice cream") || lowerName.contains("cake") || lowerName.contains("sweet") || lowerName.contains("donut") {
            return [Color(hex: "F8A5C2"), Color(hex: "F78FB3")]
        } else if lowerName.contains("bar") || lowerName.contains("wine") || lowerName.contains("beer") || lowerName.contains("cocktail") || lowerName.contains("night") {
            return [Color(hex: "D6A2E8"), Color(hex: "B39CD0")]
        } else if lowerName.contains("sushi") || lowerName.contains("japanese") || lowerName.contains("seafood") {
            return [Color(hex: "FFBE76"), Color(hex: "FFA502")]
        }

        let sum = name.utf8.reduce(0) { $0 + Int($1) }
        let index = sum % 8

        switch index {
        case 0: return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
        case 1: return [Color(hex: "74B9FF"), Color(hex: "0984E3")]
        case 2: return [Color(hex: "A29BFE"), Color(hex: "6C5CE7")]
        case 3: return [Color(hex: "FAB1A0"), Color(hex: "E17055")]
        case 4: return [Color(hex: "B2BEC3"), Color(hex: "636E72")]
        case 5: return [Color(hex: "FD79A8"), Color(hex: "E84393")]
        case 6: return [Color(hex: "E0C3FC"), Color(hex: "8EC5FC")]
        case 7: return [Color(hex: "55EFC4"), Color(hex: "00B894")]
        default: return [Color(hex: "81ECEC"), Color(hex: "00CEC9")]
        }
    }
}
