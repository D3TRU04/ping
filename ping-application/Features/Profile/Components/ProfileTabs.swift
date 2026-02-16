//
//  ProfileTabs.swift
//  PingNative
//
//  Profile tab selector component
//  Refactored to Threads-style top tab strip (text-only + underline)
//

import SwiftUI

enum ProfileTabType: String, CaseIterable, Identifiable {
    case been = "Been to"
    case wantToTry = "Want to try"
    case saved = "Saved"
    
    var id: String { rawValue }
}

struct ProfileTabs: View {
    @Binding var activeTab: ProfileTabType
    // Counts are accepted for compatibility but not rendered in this minimal design
    let wantToTryCount: Int
    let beenCount: Int
    
    @Namespace private var animation
    
    init(activeTab: Binding<ProfileTabType>, wantToTryCount: Int = 0, beenCount: Int = 0) {
        self._activeTab = activeTab
        self.wantToTryCount = wantToTryCount
        self.beenCount = beenCount
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(ProfileTabType.allCases) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            activeTab = tab
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(tab.rawValue)
                                .font(.system(size: 15, weight: activeTab == tab ? .semibold : .regular, design: .rounded))
                                .foregroundColor(activeTab == tab ? .primary : .secondary)
                                .frame(maxWidth: .infinity)
                            
                            // Underline indicator
                            if activeTab == tab {
                                Rectangle()
                                    .fill(Color.primary)
                                    .frame(height: 1.5)
                                    .matchedGeometryEffect(id: "activeTabUnderline", in: animation)
                                    // Underline matches text width roughly, or full tab width if preferred.
                                    // Here we use padding to make it slightly narrower than full tab
                                    .padding(.horizontal, 16)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 1.5)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
            .padding(.top, 12)
            
            // Bottom divider rule
            Divider()
                .overlay(Color.primary.opacity(0.05))
        }
        .background(Color(hex: "FAFAFA")) // Match profile background
    }
}

