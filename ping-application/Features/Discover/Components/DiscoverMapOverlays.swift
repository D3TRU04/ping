//
//  DiscoverMapOverlays.swift
//  PingNative
//
//  Map overlay components for Discover screen
//
//  Related files:
//  - DiscoverMapButtons.swift - Button components
//

import SwiftUI
import MapKit

// MARK: - Places Map Background
struct PlacesMapBackground: View {
    @ObservedObject var viewModel: DiscoverViewModel
    var safeAreaTop: CGFloat = 59

    var body: some View {
        ZStack {
            MapboxMapView(
                coordinateRegion: $viewModel.currentRegion,
                showsUserLocation: true,
                mapType: viewModel.mapType == "satellite" ? .satellite : .standard,
                places: viewModel.filteredPlaces,
                selectedPlace: viewModel.selectedPlace,
                onPlaceSelect: { place in
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                        viewModel.selectPlace(place)
                    }
                }
            )
            .ignoresSafeArea()

            MapGradientOverlay(isSatelliteMode: viewModel.mapType == "satellite", safeAreaTop: safeAreaTop)
        }
    }
}

// MARK: - Map Gradient Overlay
struct MapGradientOverlay: View {
    let isSatelliteMode: Bool
    var safeAreaTop: CGFloat = 59

    var body: some View {
        VStack {
            LinearGradient(
                colors: isSatelliteMode
                    ? [Color.black.opacity(0.6), Color.black.opacity(0)]
                    : [Color.white.opacity(0.95), Color.white.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: safeAreaTop + 130)
            .ignoresSafeArea()

            Spacer()
        }
    }
}

// MARK: - Map Controls Overlay
struct MapControlsOverlay: View {
    @ObservedObject var viewModel: DiscoverViewModel
    let sheetExpansion: CGFloat

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                ZoomButton(icon: "plus", isSatelliteMode: viewModel.mapType == "satellite") {
                    var region = viewModel.currentRegion
                    region.span.latitudeDelta /= 2
                    region.span.longitudeDelta /= 2
                    withAnimation { viewModel.currentRegion = region }
                }

                ZoomButton(icon: "minus", isSatelliteMode: viewModel.mapType == "satellite") {
                    var region = viewModel.currentRegion
                    region.span.latitudeDelta *= 2
                    region.span.longitudeDelta *= 2
                    withAnimation { viewModel.currentRegion = region }
                }

                Rectangle()
                    .fill(viewModel.mapType == "satellite" ? Color.white.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 24, height: 1)
                    .padding(.vertical, 4)

                LocationButton(viewModel: viewModel)
                SatelliteToggleButton(viewModel: viewModel)
            }
            .padding(.trailing, 24)
            .opacity(Double(1 - sheetExpansion * 0.6))
        }
    }
}
