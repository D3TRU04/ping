//
//  ProfileTabs.swift
//  PingNative
//
//  Profile tab selector component
//

import SwiftUI

enum ProfileTabType: String {
    case wantToTry = "Want to Try"
    case been = "Been"
}

struct ProfileTabs: View {
    @Binding var activeTab: ProfileTabType
    let tabs: [ProfileTabType]
    let wantToTryCount: Int
    let beenCount: Int

    init(activeTab: Binding<ProfileTabType>, tabs: [ProfileTabType] = [.wantToTry, .been], wantToTryCount: Int = 0, beenCount: Int = 0) {
        self._activeTab = activeTab
        self.tabs = tabs
        self.wantToTryCount = wantToTryCount
        self.beenCount = beenCount
    }

    private func countForTab(_ tab: ProfileTabType) -> Int {
        switch tab {
        case .wantToTry:
            return wantToTryCount
        case .been:
            return beenCount
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeTab = tab
                    }
                }) {
                    HStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                        Text("\(countForTab(tab))")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                activeTab == tab
                                    ? Color.white.opacity(0.25)
                                    : AppColors.textSecondary.opacity(0.15)
                            )
                            .clipShape(Capsule())
                    }
                    .foregroundColor(activeTab == tab ? .white : AppColors.textSecondary)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        activeTab == tab ?
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(
                                colors: [Color(hex: "F3F4F6"), Color(hex: "F3F4F6")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(activeTab == tab ? Color(hex: "1FC9C3") : Color.clear, lineWidth: 1)
                    )
                    .shadow(color: activeTab == tab ? Color(hex: "1FC9C3").opacity(0.25) : Color.clear, radius: 10, x: 0, y: 5)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}
