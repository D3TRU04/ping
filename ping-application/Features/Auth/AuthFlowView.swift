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
            if showingLogin {
                LoginView(showingLogin: $showingLogin)
            } else {
                SignupView(showingLogin: $showingLogin)
            }
        }
    }
}
