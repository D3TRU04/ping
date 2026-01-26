//
//  DiscoverNavBar.swift
//  PingNative
//
//  Navigation bar for Discover screen
//

import SwiftUI

struct DiscoverNavBar: View {
    @Binding var searchMode: DiscoverSearchMode
    var isSatelliteMode: Bool = false
    var onModeChange: (() -> Void)? = nil
    var onSearchTap: () -> Void

    private var textColor: Color {
        isSatelliteMode ? .white : AppColors.textPrimary
    }

    var body: some View {
        HStack(alignment: .center) {
            Text("Discover")
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundColor(textColor)
                .shadow(color: isSatelliteMode ? Color.black.opacity(0.3) : Color.clear, radius: 2, x: 0, y: 1)

            Spacer()

            Button(action: onSearchTap) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(textColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .shadow(color: isSatelliteMode ? Color.black.opacity(0.3) : Color.clear, radius: 2, x: 0, y: 1)
            }
        }
    }
}
