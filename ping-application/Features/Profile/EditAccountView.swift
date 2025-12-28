//
//  EditAccountView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/profile/edit/page.tsx (implied)
//  Edit account view - similar to AccountInfoView but focused on editing
//

import SwiftUI
import Combine

struct EditAccountView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = EditAccountViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        AccountInfoView()
            .navigationBarTitleDisplayMode(.inline)
    }
}

// Reuse AccountInfoView for editing
// EditAccountViewModel can extend AccountInfoViewModel if needed
@MainActor
class EditAccountViewModel: ObservableObject {
    // Can extend AccountInfoViewModel functionality
}
