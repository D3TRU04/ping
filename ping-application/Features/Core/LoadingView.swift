//
//  LoadingView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/core/loading/page.tsx
//  Generated Swift equivalent
//

import SwiftUI

struct LoadingView: View {
    @State private var fadeAnim: Double = 0
    @State private var scaleAnim: Double = 0.2
    @State private var slideAnim: Double = 0
    @State private var pulseAnim: Double = 1
    @State private var bounceAnim: Double = 0
    @State private var foundPulseAnim: Double = 1
    @State private var pingBounceAnim: Double = 0
    @State private var exitFadeAnim: Double = 1
    @State private var exitScaleAnim: Double = 1
    
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var onFinished: (() -> Void)?
    
    var body: some View {
        ZStack {
            LiquidGlassBackground()
            
            // Logo Image with animations
            Image("ping-logo-white")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 320, height: 320) // Adjust size as needed
                .brightness(0.2)
                .opacity(fadeAnim * exitFadeAnim)
                .scaleEffect(scaleAnim * pulseAnim * foundPulseAnim * exitScaleAnim)
                .offset(y: slideAnim + bounceAnim + pingBounceAnim)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Entrance animations
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            fadeAnim = 1
            scaleAnim = 1.2
            slideAnim = 1
        }
        
        // Bounce animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.3).repeatForever(autoreverses: true)) {
                bounceAnim = -20
            }
        }
        
        // Ping bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pingBounceAnim = -15
            }
        }
        
        // Found pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                foundPulseAnim = 1.1
            }
        }
        
        // Logo pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseAnim = 1.05
            }
        }
        
        // Exit animation after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.6)) {
                exitFadeAnim = 0
                exitScaleAnim = 0.8
            }
            
            // Navigate after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                // Navigation handled by parent
                onFinished?()
            }
        }
    }
}
