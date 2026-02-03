//
//  MatchmakingFlowView.swift
//  PingNative
//
//  "This or That" decision game for daily discovery
//

import SwiftUI

struct MatchmakingFlowView: View {
    let rounds: [GameRound]
    let onFinished: ([String]) -> Void
    let onRequestMoreRounds: (([String]) async -> [GameRound])?
    let onUpdatePreview: (([String]) -> [Place])?

    @State private var currentRound: Int = 0
    @State private var selectedThemes: [String] = []
    @State private var selectedSide: String? = nil
    @State private var showPreview: Bool = false
    @State private var additionalRounds: [GameRound] = []
    @State private var isLoadingMoreRounds: Bool = false
    @State private var currentPreviewPlaces: [Place] = []

    private var allRounds: [GameRound] {
        rounds + additionalRounds
    }
    private var totalRounds: Int { allRounds.count }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background provided by parent

                // MARK: - Matchmaking Layout with Consistent Margins
                VStack(spacing: 8) {
                    MatchmakingProgressBar(
                        totalRounds: totalRounds,
                        currentRound: currentRound
                    )
                    .padding(.horizontal, 24) // Increased margin from screen edges
                    .padding(.vertical, 12)
                    .padding(.top, 4)

                    if currentRound < totalRounds {
                        let round = allRounds[currentRound]

                        HStack(spacing: 12) {
                            MatchmakingSideCard(
                                option: round.optionA,
                                isSelected: selectedSide == "A"
                            ) {
                                selectOption(round.optionA, side: "A")
                            }

                            MatchmakingSideCard(
                                option: round.optionB,
                                isSelected: selectedSide == "B"
                            ) {
                                selectOption(round.optionB, side: "B")
                            }
                        }
                        .frame(maxHeight: .infinity) // Stretch vertically
                        .padding(.horizontal, 24) // Increased margin from screen edges
                        .padding(.bottom, 32) // Space above bottom nav
                        .transition(.opacity)
                        .id(currentRound)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentRound)
        .sheet(isPresented: $showPreview) {
            MatchmakingPreviewPopup(
                places: currentPreviewPlaces,
                selectedThemes: selectedThemes,
                isLoadingMoreRounds: isLoadingMoreRounds,
                onAccept: {
                    showPreview = false
                    onFinished(selectedThemes)
                },
                onKeepPlaying: {
                    Task {
                        await loadMoreRounds()
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
        }
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
                    if let onUpdatePreview = onUpdatePreview {
                        currentPreviewPlaces = onUpdatePreview(selectedThemes)
                    }
                    showPreview = true
                }
            }
        }
    }

    private func loadMoreRounds() async {
        guard let onRequestMoreRounds = onRequestMoreRounds else {
            showPreview = false
            onFinished(selectedThemes)
            return
        }

        isLoadingMoreRounds = true

        let newRounds = await onRequestMoreRounds(selectedThemes)

        await MainActor.run {
            isLoadingMoreRounds = false
            if newRounds.isEmpty {
                showPreview = false
                onFinished(selectedThemes)
            } else {
                additionalRounds.append(contentsOf: newRounds)
                if let onUpdatePreview = onUpdatePreview {
                    currentPreviewPlaces = onUpdatePreview(selectedThemes)
                }
                showPreview = false
            }
        }
    }
}

// MARK: - Progress Bar

struct MatchmakingProgressBar: View {
    let totalRounds: Int
    let currentRound: Int

    var body: some View {
        // Restyled to be a subtle continuous line instead of segmented dashes
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Subtle track
                Capsule()
                    .fill(Color.black.opacity(0.04))
                    .frame(height: 2)
                
                // Subtle progress indicator
                if totalRounds > 0 {
                    Capsule()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: geometry.size.width * CGFloat(currentRound) / CGFloat(totalRounds), height: 2)
                }
            }
        }
        .frame(height: 2)
    }
}
