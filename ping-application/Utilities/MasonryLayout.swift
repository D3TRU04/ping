//
//  MasonryLayout.swift
//  PingNative
//
//  SwiftUI Layout for 2-column masonry grid with varied heights
//

import SwiftUI

struct MasonryLayout: Layout {
    var columns: Int = 2
    var spacing: CGFloat = 12

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = calculateLayout(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = calculateLayout(in: bounds.width, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            let size = result.sizes[index]
            subview.place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
        }
    }

    private func calculateLayout(in maxWidth: CGFloat, subviews: Subviews) -> MasonryResult {
        let columnWidth = (maxWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        var columnHeights = Array(repeating: CGFloat(0), count: columns)
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []

        for subview in subviews {
            // Find the shortest column
            let shortestColumn = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0

            // Get the preferred size for this subview
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))
            let itemHeight = size.height

            // Calculate position
            let x = CGFloat(shortestColumn) * (columnWidth + spacing)
            let y = columnHeights[shortestColumn]

            positions.append(CGPoint(x: x, y: y))
            sizes.append(CGSize(width: columnWidth, height: itemHeight))

            // Update column height
            columnHeights[shortestColumn] += itemHeight + spacing
        }

        // Calculate total height
        let maxHeight = columnHeights.max() ?? 0
        let finalHeight = maxHeight > 0 ? maxHeight - spacing : 0

        return MasonryResult(
            size: CGSize(width: maxWidth, height: finalHeight),
            positions: positions,
            sizes: sizes
        )
    }

    struct MasonryResult {
        var size: CGSize
        var positions: [CGPoint]
        var sizes: [CGSize]
    }
}
