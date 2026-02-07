//
//  DiscoverView.swift
//  PingNative
//
//  Clean, minimal discover screen with Mapbox integration
//

import SwiftUI
import MapKit

struct DiscoverView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = DiscoverViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var sheetExpansion: CGFloat = 0

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                if viewModel.searchMode == .places {
                    if viewModel.locationReady {
                        PlacesMapBackground(viewModel: viewModel)
                    } else {
                        Color(hex: "E8E8E8").ignoresSafeArea()
                    }
                } else {
                    LiquidGlassBackground()
                }

                DiscoverContent(
                    viewModel: viewModel,
                    path: $path,
                    sheetExpansion: $sheetExpansion,
                    userSelectedCategories: appEnvironment.currentUser?.categoryPreferences?.categories
                )
            }
            .navigationDestination(for: String.self) { route in
                destinationView(for: route)
            }
            .onAppear {
                viewModel.requestLocationPermission()
            }
            .task {
                viewModel.configure(
                    placesService: appEnvironment.placesService,
                    profileService: appEnvironment.profileService,
                    currentUser: appEnvironment.currentUser
                )
                await viewModel.load()
            }
        }
        .preference(key: SheetExpansionPreferenceKey.self, value: sheetExpansion)
        .preference(key: SatelliteModePreferenceKey.self, value: viewModel.mapType == "satellite")
    }

    @ViewBuilder
    private func destinationView(for route: String) -> some View {
        if route == "searchUsers" {
            SearchUsersView()
                .environmentObject(appEnvironment)
                .navigationBarBackButtonHidden(true)
        } else if route.starts(with: "user:") {
            let userId = String(route.dropFirst(5))
            PublicProfileView(userId: userId)
                .environmentObject(appEnvironment)
        }
    }
}

// MARK: - Discover Content
private struct DiscoverContent: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @Binding var path: NavigationPath
    @Binding var sheetExpansion: CGFloat
    let userSelectedCategories: [String]?

    var body: some View {
        VStack(spacing: 10) {
            DiscoverNavBar(
                searchMode: $viewModel.searchMode,
                isSatelliteMode: viewModel.mapType == "satellite",
                onModeChange: {
                    viewModel.searchQuery = ""
                    viewModel.userResults = []
                    viewModel.filteredPlaces = viewModel.places
                },
                onSearchTap: {
                    path.append("searchUsers")
                }
            )
            .padding(.horizontal, 24)
            .padding(.top, 8)

            if viewModel.searchMode == .places {
                DiscoverSearchBar(
                    searchQuery: $viewModel.searchQuery,
                    placeholder: "Search places...",
                    isSatelliteMode: viewModel.mapType == "satellite"
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                DiscoverCategoryFilterBar(
                    activeCategory: $viewModel.activeTab,
                    isSatelliteMode: viewModel.mapType == "satellite",
                    userSelectedCategories: userSelectedCategories
                ) { category in
                    viewModel.filterByCategory(category)
                }
                .padding(.bottom, 16)
            }

            if viewModel.searchMode == .places {
                MapControlsOverlay(viewModel: viewModel, sheetExpansion: sheetExpansion)
            }

            Spacer()
        }

        if viewModel.searchMode == .places && viewModel.selectedPlace == nil {
            LoadingStatusIndicator(viewModel: viewModel)
        }

        if let selectedPlace = viewModel.selectedPlace {
            SelectedPlaceOverlay(viewModel: viewModel, place: selectedPlace)
        }
    }
}
