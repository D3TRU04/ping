//
//  MarketingStepView.swift
//  PingNative
//
//  Marketing/splash step view for onboarding
//

import SwiftUI

struct MarketingStepView: View {
    let titlePart1: String
    let highlightedText: String
    let titlePart2: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            (Text(titlePart1) +
             Text(highlightedText)
                .foregroundColor(AppColors.mint) +
             Text(titlePart2))
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle)
                .font(.system(size: 20))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .font(.system(size: 36, weight: .regular))
        .foregroundColor(AppColors.textPrimary)
    }
}
