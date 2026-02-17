//
//  SettingsComponents.swift
//  PingNative
//
//  Shared UI components for Settings screens
//

import SwiftUI

// MARK: - Settings Section
struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .tracking(1.0)
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                Color.white.opacity(0.18)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(1.0), location: 0.0),
                                    .init(color: .white.opacity(0.7), location: 0.3),
                                    .init(color: .white.opacity(0.5), location: 0.6),
                                    .init(color: .white.opacity(0.85), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                        .padding(1)
                }
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Settings Row (Navigation)
struct SettingsRowContent: View {
    let icon: String
    let title: String
    var showChevron: Bool = true
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.mint)
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let icon: String?
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    init(icon: String? = nil, title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.mint)
                    .frame(width: 28)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColors.mint)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// MARK: - Settings Text Field Row
struct SettingsTextFieldRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 80, alignment: .leading)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
