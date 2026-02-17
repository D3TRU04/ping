//
//  DiscoverBottomSheet.swift
//  PingNative
//
//  Bottom sheet component for Discover screen places list
//
//  Related files:
//  - DiscoverBottomSheetComponents.swift - Header, content, and state views
//

import SwiftUI

struct DiscoverBottomSheet: View {
    let places: [Place]
    let loading: Bool
    let onPlaceSelect: (Place) -> Void
    var onExpansionChange: ((CGFloat) -> Void)? = nil

    @State private var sheetHeight: CGFloat = 140

    private let minHeight: CGFloat = 140

    var body: some View {
        GeometryReader { geometry in
            let maxHeight = geometry.size.height * 0.7
            let expansionProgress = (sheetHeight - minHeight) / (maxHeight - minHeight)

            VStack(spacing: 0) {
                BottomSheetHeader(
                    placesCount: places.count,
                    expansionProgress: expansionProgress,
                    onToggle: { toggleExpansion(maxHeight: maxHeight) }
                )
                .gesture(dragGesture(maxHeight: maxHeight))

                BottomSheetContent(
                    places: places,
                    loading: loading,
                    sheetHeight: sheetHeight,
                    onPlaceSelect: onPlaceSelect
                )
            }
            .frame(height: sheetHeight)
            .background(Color.white.opacity(0.65))
            .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
            .overlay(
                RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(1.0), location: 0.0),
                                .init(color: .white.opacity(0.8), location: 0.3),
                                .init(color: .white.opacity(0.6), location: 0.6),
                                .init(color: .white.opacity(0.9), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: -10)
        }
        .frame(height: sheetHeight)
    }

    private func toggleExpansion(maxHeight: CGFloat) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if sheetHeight < (minHeight + maxHeight) / 2 {
                sheetHeight = maxHeight
            } else {
                sheetHeight = minHeight
            }
            let progress = (sheetHeight - minHeight) / (maxHeight - minHeight)
            onExpansionChange?(progress)
        }
    }

    private func dragGesture(maxHeight: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let newHeight = sheetHeight - value.translation.height
                sheetHeight = min(max(newHeight, minHeight), maxHeight)
                let progress = (sheetHeight - minHeight) / (maxHeight - minHeight)
                onExpansionChange?(progress)
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    if sheetHeight < (minHeight + maxHeight) / 2 {
                        sheetHeight = minHeight
                    } else {
                        sheetHeight = maxHeight
                    }
                    let progress = (sheetHeight - minHeight) / (maxHeight - minHeight)
                    onExpansionChange?(progress)
                }
            }
    }
}
