//
//  DiscoverSearchBar.swift
//  PingNative
//
//  Search bar component for Discover screen
//

import SwiftUI

struct DiscoverSearchBar: View {
    @Binding var searchQuery: String
    var placeholder: String = "Search places..."
    var isSatelliteMode: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textSecondary)

            ZStack(alignment: .leading) {
                if searchQuery.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.5) : AppColors.textSecondary)
                }

                TextField("", text: $searchQuery)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(isSatelliteMode ? .white : AppColors.textPrimary)
                    .focused($isFocused)
            }

            if !searchQuery.isEmpty {
                Button(action: {
                    searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(isSatelliteMode ? Color.black.opacity(0.5) : Color.white.opacity(0.65))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
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
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}
