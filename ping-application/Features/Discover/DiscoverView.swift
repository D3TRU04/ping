//
//  DiscoverView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/discover/page.tsx
//  Generated Swift equivalent matching RN design
//

import SwiftUI
import MapKit

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var body: some View {
        ZStack {
            // 1. Map Layer (Background)
            Map(coordinateRegion: $viewModel.currentRegion, showsUserLocation: true)
                .ignoresSafeArea()
            
            // 2. Place Popup
            if let selectedPlace = viewModel.selectedPlace {
                VStack {
                    PlacePopup(
                        place: selectedPlace,
                        isSheetDown: viewModel.isSheetDown,
                        onDismiss: {
                            viewModel.selectedPlace = nil
                        }
                    )
                    Spacer()
                }
                .padding(.top, 140) // Below search bar
                .allowsHitTesting(true)
            }
            
            // 3. Top UI Layer
            VStack(spacing: 0) {
                DiscoverTopNavBar(currentUser: appEnvironment.currentUser)
                
                SearchBar(
                    searchQuery: $viewModel.searchQuery,
                    searchBarTop: 60
                )
                .padding(.top, 10)
                
                Spacer()
            }
            .allowsHitTesting(true)
            
            // 4. Bottom UI Layer (Controls and Sheet)
            VStack {
                Spacer()
                
                // Map Controls
                HStack {
                    Spacer()
                    MapControls(
                        mapType: $viewModel.mapType,
                        onLocationTap: {
                            viewModel.centerOnUserLocation()
                        }
                    )
                    .padding(.trailing, 16)
                    .padding(.bottom, 20)
                }
                
                // Bottom Sheet
                DraggableBottomSheet(
                    showFilters: $viewModel.showFilters,
                    filters: $viewModel.filters,
                    places: viewModel.places,
                    filteredPlaces: viewModel.filteredPlaces,
                    searchQuery: viewModel.searchQuery,
                    activeTab: $viewModel.activeTab,
                    loading: viewModel.loading,
                    refreshing: viewModel.refreshing,
                    onRefresh: {
                        Task {
                            await viewModel.refresh()
                        }
                    },
                    onPlaceSelect: { place in
                        viewModel.selectedPlace = place
                    }
                )
                .padding(.bottom, 100) // Space for Tab Bar
                .offset(y: viewModel.isSheetDown ? UIScreen.main.bounds.height * 0.4 : 0)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

// Placeholder components - implement based on RN components
struct DiscoverTopNavBar: View {
    let currentUser: User?
    
    var body: some View {
        HStack {
            Text("Discover")
                .font(.system(size: 20, weight: .bold))
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

struct SearchBar: View {
    @Binding var searchQuery: String
    let searchBarTop: CGFloat
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search locations...", text: $searchQuery)
                .font(.system(size: 16))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal, 16)
    }
}

struct MapControls: View {
    @Binding var mapType: String
    let onLocationTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onLocationTap) {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.mint)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            
            // Map type toggle placeholder
            Button(action: {
                mapType = mapType == "standard" ? "satellite" : "standard"
            }) {
                Image(systemName: "map")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.mint)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
    }
}

struct PlacePopup: View {
    let place: Place
    let isSheetDown: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Text(place.name)
                .font(.system(size: 18, weight: .bold))
            Text(place.address ?? "")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding()
    }
}

struct DraggableBottomSheet: View {
    @Binding var showFilters: Bool
    @Binding var filters: [String]
    let places: [Place]
    let filteredPlaces: [Place]
    let searchQuery: String
    @Binding var activeTab: String
    let loading: Bool
    let refreshing: Bool
    let onRefresh: () -> Void
    let onPlaceSelect: (Place) -> Void
    
    var body: some View {
        VStack {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            // Content placeholder
            if loading {
                ProgressView()
            } else {
                List(filteredPlaces) { place in
                    Button(action: {
                        onPlaceSelect(place)
                    }) {
                        Text(place.name)
                    }
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.7)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
