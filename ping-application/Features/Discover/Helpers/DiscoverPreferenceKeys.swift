//
//  DiscoverPreferenceKeys.swift
//  PingNative
//
//  Preference keys for sharing state with parent views
//

import SwiftUI

struct SheetExpansionPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Note: SatelliteModePreferenceKey is defined in RootView.swift
