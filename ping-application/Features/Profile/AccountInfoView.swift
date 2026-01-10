//
//  AccountInfoView.swift
//  PingNative
//
//  Account information editing view
//

import SwiftUI

struct AccountInfoView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FAF6F2"), Color(hex: "F5F5F5")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Account Info")
                        .font(.system(size: 24, weight: .bold))
                        .padding()

                    Text("Account information editing screen")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding()

                    // TODO: Add account editing fields
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
