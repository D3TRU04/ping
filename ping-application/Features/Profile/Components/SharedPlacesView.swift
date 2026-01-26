//
//  SharedPlacesView.swift
//  PingNative
//
//  View for displaying shared places between two users
//

import SwiftUI
import Combine

// MARK: - Shared Place Type
enum SharedPlaceType {
    case wantToTry
    case been
}

// MARK: - Shared Places View
struct SharedPlacesView: View {
    let title: String
    let icon: String
    let currentUserId: String
    let otherUserId: String
    let placeType: SharedPlaceType

    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = SharedPlacesViewModel()
    @Environment(\.dismiss) var dismiss

    private let backgroundColor = Color(hex: "FAFAFA")

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else if viewModel.sharedPlaces.isEmpty {
                    emptyStateView
                } else {
                    placesListView
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .task {
            await viewModel.loadSharedPlaces(
                currentUserId: currentUserId,
                otherUserId: otherUserId,
                placeType: placeType,
                appEnvironment: appEnvironment
            )
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(AppColors.mint)
            Spacer()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7").opacity(0.15), Color(hex: "1FC9C3").opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .blur(radius: 10)

                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(AppColors.mint.opacity(0.6))
            }

            VStack(spacing: 4) {
                Text("No shared places yet")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text(placeType == .wantToTry
                     ? "Places you both want to try will appear here."
                     : "Places you've both been to will appear here.")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .frame(maxWidth: 240)
            }
        }
    }

    private var placesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.sharedPlaces) { place in
                    ProfilePlaceCard(place: place)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }
}

// MARK: - Shared Places ViewModel
@MainActor
class SharedPlacesViewModel: ObservableObject {
    @Published var sharedPlaces: [PlaceListItem] = []
    @Published var isLoading: Bool = false

    func loadSharedPlaces(
        currentUserId: String,
        otherUserId: String,
        placeType: SharedPlaceType,
        appEnvironment: AppEnvironment
    ) async {
        isLoading = true

        do {
            switch placeType {
            case .wantToTry:
                let mySavedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(
                    userId: currentUserId,
                    limit: 100
                )
                let theirSavedPlaces = try await appEnvironment.collectionsService.getUserSavedPlaces(
                    userId: otherUserId,
                    limit: 100
                )

                let myPlaceIds = Set(mySavedPlaces.map { $0.placeId })
                let shared = theirSavedPlaces.filter { myPlaceIds.contains($0.placeId) }

                sharedPlaces = shared.compactMap { savedPlace -> PlaceListItem? in
                    guard let place = savedPlace.place else { return nil }
                    return PlaceListItem(
                        id: place.id,
                        name: place.name,
                        category: place.category,
                        subcategory: place.subcategory,
                        location: place.location,
                        imageUrl: place.imageUrl,
                        rating: place.rating,
                        hours: nil,
                        price: nil
                    )
                }

            case .been:
                let myVisitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(
                    userId: currentUserId,
                    limit: 100
                )
                let theirVisitedPlaces = try await appEnvironment.placesService.getUserVisitedPlaces(
                    userId: otherUserId,
                    limit: 100
                )

                let myPlaceIds = Set(myVisitedPlaces.map { $0.placeId })
                let shared = theirVisitedPlaces.filter { myPlaceIds.contains($0.placeId) }

                sharedPlaces = shared.compactMap { visit -> PlaceListItem? in
                    guard let place = visit.place else { return nil }
                    return PlaceListItem(
                        id: place.id,
                        name: place.name,
                        category: place.category ?? "Unknown",
                        subcategory: place.subcategory,
                        location: place.address ?? "",
                        imageUrl: place.imageUrl,
                        rating: place.rating,
                        hours: place.hours,
                        price: place.priceRange
                    )
                }
            }
        } catch {
            print("Error loading shared places: \(error)")
        }

        isLoading = false
    }
}
