//
//  DiscoverMapButtons.swift
//  PingNative
//
//  Map control buttons for Discover screen
//

import SwiftUI

// MARK: - Zoom Button
struct ZoomButton: View {
    let icon: String
    let isSatelliteMode: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSatelliteMode ? .white : AppColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(isSatelliteMode ? Color.black.opacity(0.5) : Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Location Button
struct LocationButton: View {
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                viewModel.centerOnUserLocation()
            }
        }) {
            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.mint)
                .frame(width: 44, height: 44)
                .background(viewModel.mapType == "satellite" ? Color.black.opacity(0.5) : Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Satellite Toggle Button
struct SatelliteToggleButton: View {
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        Button(action: {
            viewModel.mapType = viewModel.mapType == "standard" ? "satellite" : "standard"
        }) {
            Image(systemName: viewModel.mapType == "satellite" ? "map.fill" : "globe.americas.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.textSecondary)
                .frame(width: 44, height: 44)
                .background(viewModel.mapType == "satellite" ? Color.black.opacity(0.5) : Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Loading Status Indicator
struct LoadingStatusIndicator: View {
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        VStack {
            Spacer()

            if viewModel.loading {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(viewModel.mapType == "satellite" ? .white : AppColors.mint)
                    Text("Finding places nearby...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    (viewModel.mapType == "satellite" ? Color.black.opacity(0.6) : Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                )
                .cornerRadius(25)
            }

            Spacer()
        }
        .padding(.bottom, 60)
    }
}

// MARK: - Selected Place Overlay
struct SelectedPlaceOverlay: View {
    @ObservedObject var viewModel: DiscoverViewModel
    let place: Place

    var body: some View {
        VStack {
            Spacer()

            DiscoverPlaceCard(
                place: place,
                isSatelliteMode: viewModel.mapType == "satellite",
                onDismiss: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        viewModel.selectedPlace = nil
                    }
                },
                onNavigate: {
                    // TODO: Open in Maps
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 130)
            .transition(
                .asymmetric(
                    insertion: .offset(y: 20).combined(with: .opacity),
                    removal: .offset(y: 10).combined(with: .opacity)
                )
            )
            .animation(.easeOut(duration: 0.3), value: place.id)
        }
        .zIndex(1)
    }
}
