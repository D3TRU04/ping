//
//  AuthFlowView.swift
//  PingNative
//
//  Created on 12/3/25.
//

import SwiftUI

struct AuthFlowView: View {
    @State private var showingLogin = true
    
    var body: some View {
        NavigationStack {
            Group {
                if showingLogin {
                    LoginView(showingLogin: $showingLogin)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    SignupView(showingLogin: $showingLogin)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showingLogin)
        }
    }
}
