//
//  MapScreenView.swift
//  PingNative
//
//  Created on 12/3/25.
//

import SwiftUI

struct MapScreenView: View {
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map view placeholder
                // TODO: Replace with actual Mapbox map view
                MapPlaceholderView(viewModel: viewModel)
                    .ignoresSafeArea()
                
                // Overlay UI elements
                VStack {
                    // Top controls
                    HStack {
                        // Search bar placeholder
                        TextField("Search locations...", text: $viewModel.searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                        
                        Spacer()
                        
                        // Location button
                        Button(action: {
                            Task {
                                await viewModel.centerOnUserLocation()
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Bottom sheet placeholder
                    // TODO: Add bottom sheet with map details if RN app has one
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadMapData()
            }
        }
    }
}

// Placeholder Mapbox view - will be replaced with actual Mapbox SDK integration
struct MapPlaceholderView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        
        // Add placeholder label
        let label = UILabel()
        label.text = "Mapbox Map\n(Placeholder - Configure Mapbox SDK)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update map when viewModel changes
    }
}
