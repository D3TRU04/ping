//
//  SettingsSection.swift
//  PingNative
//
//  Settings section container component
//

import SwiftUI

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}
