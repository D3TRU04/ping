//
//  StartupView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/core/startup/page.tsx
//  Generated Swift equivalent
//

import SwiftUI

struct StartupView: View {
    @State private var showLoginModal = false
    @State private var loginDetent: PresentationDetent = .medium
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background: Cyan to White
            LinearGradient(
                colors: [Color(hex: "1FC9C3"), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo
                Image("1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 320)
                    .brightness(0.2)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 40)
                
                Spacer()
                
                // Main Buttons Container
                VStack(spacing: 20) {
                    // Get Started Button
                    NavigationLink(value: NavigationDestination.signUp) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "1FC9C3"), lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 32)
                    
                    // Login Text
                    Button(action: {
                        showLoginModal = true
                    }) {
                        Text("Already have an account? Log in")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.bottom, 24)
                }
                
                // Privacy Policy Text
                Text("By tapping 'Get Started', you agree to our Privacy Policy and Terms of Service.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)
                    .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showLoginModal) {
            NavigationStack {
                LoginModalView(showLoginModal: $showLoginModal)
                    .onAppear { loginDetent = .medium }
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case .signIn:
                            LoginView(showingLogin: .constant(true))
                                .onAppear { loginDetent = .large }
                        case .signUp:
                            SignupView(showingLogin: .constant(false))
                                .onAppear { loginDetent = .large }
                        case .onboarding:
                            OnboardingView()
                        }
                    }
            }
            .presentationDetents([.medium, .large], selection: $loginDetent)
            .presentationDragIndicator(.visible)
        }
    }
}

struct LoginModalView: View {
    @Binding var showLoginModal: Bool
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = LoginViewModel()
    @State private var isEmailMode: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Close Button
            HStack {
                Spacer()
                Button(action: {
                    showLoginModal = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(10)
                        .background(Color(hex: "F3F4F6"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 64)
            
            if viewModel.step == .input {
                // MARK: - INPUT STEP
                
                // Icon & Title
                VStack(spacing: 12) {
                    Image(systemName: isEmailMode ? "envelope" : "iphone")
                        .font(.system(size: 44))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.bottom, 4)
                    
                    Text("Sign In")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isEmailMode.toggle()
                        }
                    }) {
                        Text(isEmailMode ? "Use phone instead" : "Use email instead")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
                
                // Unified Input Container
                HStack(spacing: 0) {
                    if !isEmailMode {
                        // Country Code Section (Internal to container)
                        HStack(spacing: 8) {
                            Text("🇺🇸")
                                .font(.system(size: 20))
                            Text("+1")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Rectangle()
                                .fill(AppColors.borderSubtle)
                                .frame(width: 1, height: 24)
                                .padding(.horizontal, 8)
                        }
                        .padding(.leading, 16)
                        
                        TextField("Phone number", text: $viewModel.phoneNumber)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                            .keyboardType(.numberPad)
                            .padding(.trailing, 16)
                            .onChange(of: viewModel.phoneNumber) { newValue in
                                viewModel.phoneNumber = formatPhoneNumber(newValue)
                            }
                    } else {
                        TextField("Email address", text: $viewModel.email)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 20)
                    }
                }
                .frame(height: 64)
                .background(Color(hex: "F3F4F6"))
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                // CTA Button
                Button(action: {
                    if isEmailMode {
                        // Email Login (TODO)
                    } else {
                        Task {
                            await viewModel.sendOtpWithClerk(appEnvironment: appEnvironment)
                        }
                    }
                }) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "1FC9C3"), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                }
                .disabled(viewModel.isLoading || (isEmailMode ? viewModel.email.isEmpty : viewModel.phoneNumber.isEmpty))
                .opacity((viewModel.isLoading || (isEmailMode ? viewModel.email.isEmpty : viewModel.phoneNumber.isEmpty)) ? 0.5 : 1)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
            } else {
                // MARK: - OTP STEP
                
                VStack(spacing: 12) {
                    Text("OTP")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Code sent to \(viewModel.phoneNumber)")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
                
                // OTP Input
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield")
                        .foregroundColor(AppColors.textSecondary)
                        .font(.system(size: 20))
                    
                    TextField("6-digit code", text: $viewModel.otpCode)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.otpCode) { newValue in
                            if newValue.count > 6 {
                                viewModel.otpCode = String(newValue.prefix(6))
                            }
                        }
                }
                .frame(height: 64)
                .padding(.horizontal, 20)
                .background(Color(hex: "F3F4F6"))
                .cornerRadius(20)
                .padding(.horizontal, 24)
                
                // Error Message & Dev Hint
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.error)
                        .padding(.top, 8)
                }
                
                Spacer().frame(height: 24)
                
                // Verify Button
                Button(action: {
                    Task {
                        await viewModel.verifyOtpWithClerk(appEnvironment: appEnvironment)
                    }
                }) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Verify")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "1FC9C3"), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                }
                .disabled(viewModel.isLoading || viewModel.otpCode.count != 6)
                .opacity((viewModel.isLoading || viewModel.otpCode.count != 6) ? 0.5 : 1)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            Spacer()
            
            // Footer Terms
            VStack(spacing: 6) {
                Text("By continuing, you agree to our")
                    .foregroundColor(AppColors.textTertiary)
                HStack(spacing: 4) {
                    Text("Terms of Service")
                        .underline()
                    Text("and")
                            .foregroundColor(AppColors.textTertiary)
                    Text("Privacy Policy")
                        .underline()
                }
                .foregroundColor(AppColors.textSecondary)
            }
            .font(.system(size: 12))
            .padding(.bottom, 48)
        }
        .background(Color.white)
        .interactiveDismissDisabled(false)
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.step)
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let cleanNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "XXX-XXX-XXXX"
        var result = ""
        var index = cleanNumber.startIndex
        
        for ch in mask where index < cleanNumber.endIndex {
            if ch == "X" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
