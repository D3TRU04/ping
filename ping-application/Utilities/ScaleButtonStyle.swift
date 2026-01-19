//
//  ScaleButtonStyle.swift
//  PingNative
//
//  A button style that scales down when pressed
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    var duration: Double = 0.1
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeOut(duration: duration), value: configuration.isPressed)
    }
}
