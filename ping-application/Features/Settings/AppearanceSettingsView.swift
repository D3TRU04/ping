//
//  AppearanceSettingsView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/settings/appearance/page.tsx (implied)
//  Appearance settings screen
//

import SwiftUI
import Combine

struct AppearanceSettingsView: View {
    @StateObject private var viewModel = AppearanceSettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FAF6F2"), Color(hex: "F5F5F5")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    SettingsSection(title: "Theme") {
                        PickerRow(
                            label: "Appearance",
                            selection: $viewModel.appearanceMode,
                            options: [
                                ("System", AppearanceMode.system),
                                ("Light", AppearanceMode.light),
                                ("Dark", AppearanceMode.dark)
                            ]
                        )
                    }
                    
                    SettingsSection(title: "Display") {
                        ToggleRow(
                            label: "Reduce Motion",
                            isOn: $viewModel.reduceMotion
                        )
                        
                        ToggleRow(
                            label: "Larger Text",
                            isOn: $viewModel.largerText
                        )
                    }
                }
                .padding(.vertical, 16)
            }
            
            // Top Nav Bar
            VStack {
                SettingsTopNavBar(title: "Appearance")
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.load()
        }
    }
}

enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

@MainActor
class AppearanceSettingsViewModel: ObservableObject {
    @Published var appearanceMode: AppearanceMode = .system
    @Published var reduceMotion: Bool = false
    @Published var largerText: Bool = false
    
    func load() async {
        // TODO: Load appearance settings from UserDefaults
        if let saved = UserDefaults.standard.string(forKey: "appearance_mode"),
           let mode = AppearanceMode(rawValue: saved) {
            appearanceMode = mode
        }
    }
    
    func save() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearance_mode")
        UserDefaults.standard.set(reduceMotion, forKey: "reduce_motion")
        UserDefaults.standard.set(largerText, forKey: "larger_text")
    }
}

struct PickerRow<T: Hashable>: View {
    let label: String
    @Binding var selection: T
    let options: [(String, T)]
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.1) { option in
                    Text(option.0).tag(option.1)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
