//
//  SettingsTopNavBar.swift
//  PingNative
//
//  Top navigation bar for Settings screens
//

import SwiftUI

struct SettingsTopNavBar: View {
    let title: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.primary)

            Spacer()

            // Placeholder for alignment
            Color.clear
                .frame(width: 20)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
