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
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(isSatelliteMode ? .white : AppColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(isSatelliteMode ? Color.black.opacity(0.5) : Color.white.opacity(0.65))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                stops: isSatelliteMode ? [
                                    .init(color: .white.opacity(0.5), location: 0.0),
                                    .init(color: .white.opacity(0.3), location: 0.3),
                                    .init(color: .white.opacity(0.2), location: 0.6),
                                    .init(color: .white.opacity(0.4), location: 1.0)
                                ] : [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.8), location: 0.3),
                                    .init(color: .white.opacity(0.6), location: 0.6),
                                    .init(color: .white.opacity(0.9), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSatelliteMode ? 0.5 : 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isSatelliteMode)
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
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.mint)
                .frame(width: 44, height: 44)
                .background(viewModel.mapType == "satellite" ? Color.black.opacity(0.5) : Color.white.opacity(0.65))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                stops: viewModel.mapType == "satellite" ? [
                                    .init(color: .white.opacity(0.5), location: 0.0),
                                    .init(color: .white.opacity(0.3), location: 0.3),
                                    .init(color: .white.opacity(0.2), location: 0.6),
                                    .init(color: .white.opacity(0.4), location: 1.0)
                                ] : [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.8), location: 0.3),
                                    .init(color: .white.opacity(0.6), location: 0.6),
                                    .init(color: .white.opacity(0.9), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: viewModel.mapType == "satellite" ? 0.5 : 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.mapType)
        }
    }
}

// MARK: - Satellite Toggle Button
struct SatelliteToggleButton: View {
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                viewModel.mapType = viewModel.mapType == "standard" ? "satellite" : "standard"
            }
        }) {
            Image(systemName: viewModel.mapType == "satellite" ? "map.fill" : "globe.americas.fill")
                .contentTransition(.symbolEffect(.replace))
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.textSecondary)
                .frame(width: 44, height: 44)
                .background(viewModel.mapType == "satellite" ? Color.black.opacity(0.5) : Color.white.opacity(0.65))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                stops: viewModel.mapType == "satellite" ? [
                                    .init(color: .white.opacity(0.5), location: 0.0),
                                    .init(color: .white.opacity(0.3), location: 0.3),
                                    .init(color: .white.opacity(0.2), location: 0.6),
                                    .init(color: .white.opacity(0.4), location: 1.0)
                                ] : [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.8), location: 0.3),
                                    .init(color: .white.opacity(0.6), location: 0.6),
                                    .init(color: .white.opacity(0.9), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: viewModel.mapType == "satellite" ? 0.5 : 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.mapType)
    }
}

// MARK: - Loading Status Indicator
struct LoadingStatusIndicator: View {
    @ObservedObject var viewModel: DiscoverViewModel
    var bottomInset: CGFloat = 60

    var body: some View {
        VStack {
            Spacer()

            if viewModel.loading {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(viewModel.mapType == "satellite" ? .white : AppColors.mint)
                    Text("Finding places nearby...")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                }
                .foregroundColor(viewModel.mapType == "satellite" ? .white : AppColors.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    (viewModel.mapType == "satellite" ? Color.black.opacity(0.6) : Color.white.opacity(0.65))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                )
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: viewModel.mapType == "satellite" ? [
                                    .init(color: .white.opacity(0.5), location: 0.0),
                                    .init(color: .white.opacity(0.3), location: 0.3),
                                    .init(color: .white.opacity(0.2), location: 0.6),
                                    .init(color: .white.opacity(0.4), location: 1.0)
                                ] : [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.8), location: 0.3),
                                    .init(color: .white.opacity(0.6), location: 0.6),
                                    .init(color: .white.opacity(0.9), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: viewModel.mapType == "satellite" ? 0.5 : 1.5
                        )
                )
            }

            Spacer()
        }
        .padding(.bottom, bottomInset)
    }
}

// MARK: - Selected Place Overlay
struct SelectedPlaceOverlay: View {
    @ObservedObject var viewModel: DiscoverViewModel
    let place: Place
    var bottomInset: CGFloat = 100

    var body: some View {
        VStack {
            Spacer()

            DiscoverPlaceCard(
                place: place,
                isSatelliteMode: viewModel.mapType == "satellite",
                onDismiss: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        viewModel.selectedPlace = nil
                    }
                },
                onNavigate: {
                    // TODO: Open in Maps
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, bottomInset)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .offset(y: 10).combined(with: .opacity)
                )
            )
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: place.id)
        }
        .zIndex(1)
    }
}
