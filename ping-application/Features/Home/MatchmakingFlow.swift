//
//  MatchmakingFlow.swift
//  PingNative
//
//  "This or That" decision game for daily discovery
//

import SwiftUI

struct MatchmakingFlowView: View {
    let rounds: [GameRound]
    let onFinished: ([String]) -> Void
    
    @State private var currentRound: Int = 0
    @State private var selectedThemes: [String] = []
    @State private var selectedSide: String? = nil
    
    private var totalRounds: Int { rounds.count }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "FAFAFA")
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    // Compact progress indicator
                    HStack(spacing: 3) {
                        ForEach(0..<totalRounds, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(index < currentRound ? Color.black.opacity(0.35) : 
                                      index == currentRound ? Color.black.opacity(0.18) : Color.black.opacity(0.08))
                                .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    
                    // Cards fill remaining space
                    if currentRound < totalRounds {
                        let round = rounds[currentRound]
                        
                        HStack(alignment: .top, spacing: 10) {
                            SideCard(
                                option: round.optionA,
                                isSelected: selectedSide == "A"
                            ) {
                                selectOption(round.optionA, side: "A")
                            }
                            
                            SideCard(
                                option: round.optionB,
                                isSelected: selectedSide == "B"
                            ) {
                                selectOption(round.optionB, side: "B")
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                        .transition(.opacity)
                        .id(currentRound)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentRound)
    }
    
    private func selectOption(_ option: PlaceOption, side: String) {
        selectedSide = side
        selectedThemes.append(option.subcategory)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedSide = nil
                if currentRound < totalRounds - 1 {
                    currentRound += 1
                } else {
                    onFinished(selectedThemes)
                }
            }
        }
    }
}

// MARK: - Side Card

struct SideCard: View {
    let option: PlaceOption
    let isSelected: Bool
    let action: () -> Void
    
    private var priceText: String {
        guard let price = option.priceRange, price > 0 else { return "" }
        return String(repeating: "$", count: min(price, 4))
    }
    
    private func getSubcategoryColors(_ name: String) -> (light: Color, dark: Color) {
        let lowerName = name.lowercased()
        
        if lowerName.contains("coffee") || lowerName.contains("cafe") || lowerName.contains("bakery") || lowerName.contains("bread") || lowerName.contains("waffle") || lowerName.contains("crepe") || lowerName.contains("breakfast") {
            return (Color(hex: "E2D1C3"), Color(hex: "CDB4A6"))
        } else if lowerName.contains("salad") || lowerName.contains("vegan") || lowerName.contains("vegetarian") || lowerName.contains("park") || lowerName.contains("nature") || lowerName.contains("hike") {
            return (Color(hex: "A8E6CF"), Color(hex: "88D8B0"))
        } else if lowerName.contains("ocean") || lowerName.contains("sea") || lowerName.contains("water") || lowerName.contains("pool") || lowerName.contains("swim") {
            return (Color(hex: "A1C4FD"), Color(hex: "8AB6F9"))
        } else if lowerName.contains("pizza") || lowerName.contains("burger") || lowerName.contains("fast food") || lowerName.contains("taco") {
            return (Color(hex: "FAD390"), Color(hex: "F6B93B"))
        } else if lowerName.contains("dessert") || lowerName.contains("ice cream") || lowerName.contains("cake") || lowerName.contains("sweet") || lowerName.contains("donut") {
            return (Color(hex: "F8A5C2"), Color(hex: "F78FB3"))
        } else if lowerName.contains("bar") || lowerName.contains("wine") || lowerName.contains("beer") || lowerName.contains("cocktail") || lowerName.contains("night") {
            return (Color(hex: "D6A2E8"), Color(hex: "B39CD0"))
        } else if lowerName.contains("sushi") || lowerName.contains("japanese") || lowerName.contains("seafood") {
            return (Color(hex: "FFBE76"), Color(hex: "FFA502"))
        }

        let sum = name.utf8.reduce(0) { $0 + Int($1) }
        let index = sum % 8 

        switch index {
        case 0: return (Color(hex: "81ECEC"), Color(hex: "00CEC9"))
        case 1: return (Color(hex: "74B9FF"), Color(hex: "0984E3"))
        case 2: return (Color(hex: "A29BFE"), Color(hex: "6C5CE7"))
        case 3: return (Color(hex: "FAB1A0"), Color(hex: "E17055"))
        case 4: return (Color(hex: "B2BEC3"), Color(hex: "636E72"))
        case 5: return (Color(hex: "FD79A8"), Color(hex: "E84393"))
        case 6: return (Color(hex: "E0C3FC"), Color(hex: "8EC5FC"))
        case 7: return (Color(hex: "55EFC4"), Color(hex: "00B894"))
        default: return (Color(hex: "81ECEC"), Color(hex: "00CEC9"))
        }
    }
    
    var body: some View {
        let colors = getSubcategoryColors(option.subcategory)
        
        Button(action: action) {
            ZStack {
                // Base layer - frosted glass
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
                // Glass tint layer
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Top highlight - simulates light hitting glass
                VStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 80)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                // Inner glow/edge highlight
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                
                // Centered content with fixed heights for alignment
                VStack(spacing: 12) {
                    // Subcategory pill with vertical gradient and solid border
                    Text(option.subcategory)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [colors.light, colors.dark],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colors.dark, lineWidth: 1.5)
                        )
                    
                    // Name - fixed minimum height
                    Text(option.name)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 44)
                        .padding(.horizontal, 8)
                    
                    // Description - fixed height container
                    Text(option.description)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 48)
                        .padding(.horizontal, 8)
                    
                    // Price - fixed height container
                    Text(priceText.isEmpty ? " " : priceText)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(priceText.isEmpty ? .clear : AppColors.textTertiary)
                        .frame(height: 20)
                }
                .padding(16)
                
                // Selection overlay
                if isSelected {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.25))
                    
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(colors.dark)
                            }
                        }
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }
}

// MARK: - Models

struct GameRound: Identifiable {
    let id = UUID()
    let optionA: PlaceOption
    let optionB: PlaceOption
}

struct PlaceOption {
    let name: String
    let description: String
    let category: String
    let subcategory: String
    let priceRange: Int?
}
