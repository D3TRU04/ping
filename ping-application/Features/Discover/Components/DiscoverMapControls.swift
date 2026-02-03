//
//  DiscoverMapControls.swift
//  PingNative
//
//  Map control buttons for Discover screen
//

import SwiftUI

struct DiscoverMapControls: View {
    var isSatelliteMode: Bool = false
    let onLocationTap: () -> Void
    let onLayerTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: onLocationTap) {
                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppColors.mint)
                    .frame(width: 48, height: 48)
                    .background(isSatelliteMode ? Color.black.opacity(0.5) : Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }

            Button(action: onLayerTap) {
                Image(systemName: "square.3.layers.3d")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(isSatelliteMode ? .white : AppColors.textSecondary)
                    .frame(width: 48, height: 48)
                    .background(isSatelliteMode ? Color.black.opacity(0.5) : Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
        }
    }
}
