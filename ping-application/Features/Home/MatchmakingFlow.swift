//
//  MatchmakingFlow.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/today/components/MatchmakingFlow.tsx
//  Matchmaking flow with swipeable cards
//

import SwiftUI

struct MatchmakingFlowView: View {
    let onFinished: ([String]) -> Void
    
    @State private var cardIndex: Int = 0
    @State private var swipeDirection: SwipeDirection? = nil
    @State private var pendingRemoval: Bool = false
    @State private var selectedThemes: [String] = []
    
    private let questions: [QuestionCard] = [
        QuestionCard(
            id: 1,
            text: "Are you craving spicy food today?",
            emojis: "🌶️🔥🥵",
            theme: "spicy",
            color: Color(hex: "FFB6B9")
        ),
        QuestionCard(
            id: 2,
            text: "Looking for something sweet?",
            emojis: "🍰🍦🍫",
            theme: "sweet",
            color: Color(hex: "FFD93D")
        ),
        QuestionCard(
            id: 3,
            text: "Want a healthy meal?",
            emojis: "🥗🥒🥑",
            theme: "healthy",
            color: Color(hex: "B5EAD7")
        ),
        QuestionCard(
            id: 4,
            text: "Craving something cheesy?",
            emojis: "🧀🍕🧈",
            theme: "cheesy",
            color: Color(hex: "C7CEEA")
        ),
        QuestionCard(
            id: 5,
            text: "How about a refreshing drink?",
            emojis: "🧋🥤🍹",
            theme: "drink",
            color: AppColors.mint
        )
    ]
    
    private let cardHeight = UIScreen.main.bounds.height * 0.60
    
    var body: some View {
        ZStack {
            Color(hex: "FAF6F2")
                .ignoresSafeArea()
            
            if cardIndex >= questions.count {
                // Finished state
                VStack(spacing: 24) {
                    Text("Thanks for answering!")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                }
                .onAppear {
                    onFinished(selectedThemes)
                }
            } else {
                VStack {
                    // Stack of upcoming cards
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        if index > cardIndex {
                            AnimatedStackCard(
                                top: CGFloat(16 * (index - cardIndex)),
                                zIndex: 10 - (index - cardIndex),
                                color: question.color,
                                height: cardHeight
                            ) {
                                CardContent(emojis: question.emojis, text: question.text)
                            }
                        }
                    }
                    
                    // Current swipeable card
                    if cardIndex < questions.count {
                        SwipeCard(
                            backgroundColor: questions[cardIndex].color,
                            swipeDirection: swipeDirection,
                            onSwipedOut: {
                                swipeDirection = nil
                                pendingRemoval = false
                                cardIndex += 1
                            },
                            onSwipeLeft: {
                                if !pendingRemoval {
                                    swipeDirection = .left
                                    pendingRemoval = true
                                }
                            },
                            onSwipeRight: {
                                if !pendingRemoval {
                                    let theme = questions[cardIndex].theme
                                    selectedThemes.append(theme)
                                    swipeDirection = .right
                                    pendingRemoval = true
                                }
                            },
                            pendingRemoval: pendingRemoval
                        ) {
                            CardContent(
                                emojis: questions[cardIndex].emojis,
                                text: questions[cardIndex].text
                            )
                        }
                        .frame(height: cardHeight)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.075)
            }
        }
    }
}

enum SwipeDirection {
    case left
    case right
}

struct QuestionCard {
    let id: Int
    let text: String
    let emojis: String
    let theme: String
    let color: Color
}

struct CardContent: View {
    let emojis: String
    let text: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(emojis)
                .font(.system(size: 36))
                .multilineTextAlignment(.center)
            
            Text(text)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SwipeCard<Content: View>: View {
    let backgroundColor: Color
    let swipeDirection: SwipeDirection?
    let onSwipedOut: () -> Void
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    let pendingRemoval: Bool
    @ViewBuilder let content: Content
    
    @State private var dragOffset: CGSize = .zero
    @State private var rotation: Double = 0
    
    private let swipeThreshold: CGFloat = UIScreen.main.bounds.width * 0.3
    
    var body: some View {
        content
            .background(backgroundColor)
            .cornerRadius(32)
            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 4)
            .offset(dragOffset)
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !pendingRemoval {
                            dragOffset = value.translation
                            rotation = Double(value.translation.width / 15)
                        }
                    }
                    .onEnded { value in
                        if !pendingRemoval {
                            if value.translation.width > swipeThreshold {
                                onSwipeRight()
                            } else if value.translation.width < -swipeThreshold {
                                onSwipeLeft()
                            } else {
                                withAnimation(.spring()) {
                                    dragOffset = .zero
                                    rotation = 0
                                }
                            }
                        }
                    }
            )
            .onChange(of: swipeDirection) { direction in
                if let direction = direction {
                    let targetX = direction == .right ? UIScreen.main.bounds.width * 1.2 : -UIScreen.main.bounds.width * 1.2
                    withAnimation(.easeOut(duration: 0.5)) {
                        dragOffset = CGSize(width: targetX, height: 0)
                        rotation = direction == .right ? 20 : -20
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onSwipedOut()
                    }
                }
            }
    }
}

struct AnimatedStackCard<Content: View>: View {
    let top: CGFloat
    let zIndex: Int
    let color: Color
    let height: CGFloat
    @ViewBuilder let content: Content
    
    @State private var animatedTop: CGFloat
    
    init(top: CGFloat, zIndex: Int, color: Color, height: CGFloat, @ViewBuilder content: () -> Content) {
        self.top = top
        self.zIndex = zIndex
        self.color = color
        self.height = height
        self.content = content()
        _animatedTop = State(initialValue: top)
    }
    
    var body: some View {
        content
            .background(color)
            .cornerRadius(32)
            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 4)
            .frame(height: height)
            .offset(y: animatedTop)
            .zIndex(Double(zIndex))
            .onChange(of: top) { newTop in
                withAnimation(.easeOut(duration: 0.35)) {
                    animatedTop = newTop
                }
            }
    }
}
