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
    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.7

    private var expansionProgress: CGFloat {
        (sheetHeight - minHeight) / (maxHeight - minHeight)
    }

    var body: some View {
        VStack(spacing: 0) {
            BottomSheetHeader(
                placesCount: places.count,
                expansionProgress: expansionProgress,
                onToggle: toggleExpansion
            )
            .gesture(dragGesture)

            BottomSheetContent(
                places: places,
                loading: loading,
                sheetHeight: sheetHeight,
                onPlaceSelect: onPlaceSelect
            )
        }
        .frame(height: sheetHeight)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
        .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: -10)
    }

    private func toggleExpansion() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if sheetHeight < (minHeight + maxHeight) / 2 {
                sheetHeight = maxHeight
            } else {
                sheetHeight = minHeight
            }
            onExpansionChange?(expansionProgress)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let newHeight = sheetHeight - value.translation.height
                sheetHeight = min(max(newHeight, minHeight), maxHeight)
                onExpansionChange?(expansionProgress)
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    if sheetHeight < (minHeight + maxHeight) / 2 {
                        sheetHeight = minHeight
                    } else {
                        sheetHeight = maxHeight
                    }
                    onExpansionChange?(expansionProgress)
                }
            }
    }
}
