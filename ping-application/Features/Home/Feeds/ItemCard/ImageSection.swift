//
//  ImageSection.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/item-card/components/ImageSection.tsx
//  Image section with Mapbox map, double-tap to like, heart animation
//

import SwiftUI
import MapKit
import CoreLocation

struct ImageSection: View {
    let imageUrl: String?
    let imageFailed: Bool
    let onImageError: () -> Void
    let subtopic: String?
    let isLiked: Bool
    let isSaved: Bool
    let onLike: () -> Void
    let onSave: () -> Void
    let onShare: () -> Void
    let longitude: Double
    let latitude: Double
    
    @State private var is3DEnabled: Bool = false
    @State private var showHeart: Bool = false
    @State private var heartScale: CGFloat = 0
    @State private var heartOpacity: Double = 0
    @State private var lastTapTime: Date?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Map View
            MapboxMapView(
                coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: latitude,
                            longitude: longitude
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                ),
                showsUserLocation: false,
                places: [],
                onPlaceSelect: nil
            )
            .frame(height: 320)
            .onTapGesture(count: 2) {
                handleDoubleTap()
            }
            
            // Animated Heart
            if showHeart {
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.red)
                    .scaleEffect(heartScale)
                    .opacity(heartOpacity)
                    .animation(.easeOut(duration: 0.3), value: heartScale)
            }
            
            // Top Action Buttons
            TopActionButtons(
                isLiked: isLiked,
                isSaved: isSaved,
                onLike: onLike,
                onSave: onSave,
                onShare: onShare
            )
            .padding(.top, 16)
            .padding(.trailing, 16)
            
            // Category Badge (if subtopic exists)
            if let subtopic = subtopic {
                HStack {
                    Text(getDisplayNameFromValue(subtopic))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(20)
                }
                .padding(.top, 16)
                .padding(.leading, 16)
            }
        }
        .background(Color.white)
    }
    
    private func handleDoubleTap() {
        let now = Date()
        if let lastTap = lastTapTime,
           now.timeIntervalSince(lastTap) < 0.3 {
            // Double tap detected
            if !isLiked {
                onLike()
            }
            triggerHeartAnimation()
        }
        lastTapTime = now
    }
    
    private func triggerHeartAnimation() {
        showHeart = true
        heartScale = 0
        heartOpacity = 1
        
        withAnimation(.easeOut(duration: 0.15)) {
            heartScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                heartScale = 0
                heartOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showHeart = false
            }
        }
    }
    
    private func getDisplayNameFromValue(_ value: String) -> String {
        // TODO: Map subtopic value to display name using categories
        return value.capitalized
    }
}
