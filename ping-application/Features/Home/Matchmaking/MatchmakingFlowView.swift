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
                Color(hex: "FAFAFA")
                    .ignoresSafeArea()

                VStack(spacing: 8) {
                    MatchmakingProgressBar(
                        totalRounds: totalRounds,
                        currentRound: currentRound
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                    if currentRound < totalRounds {
                        let round = allRounds[currentRound]

                        HStack(alignment: .top, spacing: 10) {
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
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
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
        HStack(spacing: 3) {
            ForEach(0..<totalRounds, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(index < currentRound ? Color.black.opacity(0.35) :
                          index == currentRound ? Color.black.opacity(0.18) : Color.black.opacity(0.08))
                    .frame(height: 3)
            }
        }
    }
}
