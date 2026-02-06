//
//  ScrollOffsetTracking.swift
//  PingNative
//
//  PreferenceKey + ViewModifier to track scroll offset from any ScrollView
//

import SwiftUI

// MARK: - Preference Key

struct ContentScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - View Modifier

struct ScrollOffsetTracker: ViewModifier {
    func body(content: Content) -> some View {
        content
            .coordinateSpace(name: "scrollOffset")
    }
}

extension View {
    func trackScrollOffset() -> some View {
        modifier(ScrollOffsetTracker())
    }

    /// Place this as the first child inside a ScrollView's content to report offset
    var scrollOffsetSensor: some View {
        GeometryReader { geo in
            Color.clear.preference(
                key: ContentScrollOffsetPreferenceKey.self,
                value: -geo.frame(in: .named("scrollOffset")).minY
            )
        }
        .frame(height: 0)
    }
}
