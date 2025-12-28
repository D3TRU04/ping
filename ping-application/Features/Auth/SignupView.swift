//
//  SignupView.swift
//  PingNative
//
//  Created on 12/3/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SignupViewModel()
    @Binding var showingLogin: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo/Title
            VStack(spacing: 8) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 32)
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Enter your email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                SecureField("Enter your password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Confirm Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                SecureField("Confirm your password", text: $viewModel.confirmPassword)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            // Sign up button
            Button(action: {
                Task {
                    await viewModel.signup(appEnvironment: appEnvironment)
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || !viewModel.isFormValid)
            
            // Login link
            HStack {
                Text("Already have an account?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button("Log In") {
                    dismiss()
                }
                .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
}
