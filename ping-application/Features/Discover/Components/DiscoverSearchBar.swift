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
                .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textTertiary)

            ZStack(alignment: .leading) {
                if searchQuery.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.5) : AppColors.textTertiary)
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
                        .foregroundColor(isSatelliteMode ? .white.opacity(0.7) : AppColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(isSatelliteMode ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}
