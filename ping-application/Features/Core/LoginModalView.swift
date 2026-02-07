//
//  LoginModalView.swift
//  PingNative
//
//  Modal view for user login with phone/email
//

import SwiftUI

/// Border shape that traces only the top (with rounded corners) and both sides, open at the bottom
private struct SheetBorderShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
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
            // Header with Back / Close Buttons
            HStack {
                if viewModel.step == .otp {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.step = .input
                            viewModel.otpCode = ""
                            viewModel.errorMessage = nil
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(10)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            stops: [
                                                .init(color: .white.opacity(0.9), location: 0.0),
                                                .init(color: .white.opacity(0.5), location: 0.5),
                                                .init(color: .white.opacity(0.7), location: 1.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    }
                }

                Spacer()

                Button(action: {
                    showLoginModal = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(10)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(0.9), location: 0.0),
                                            .init(color: .white.opacity(0.5), location: 0.5),
                                            .init(color: .white.opacity(0.7), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 80)

            Spacer()

            ZStack {
                LoginInputStepView(
                    viewModel: viewModel,
                    isEmailMode: $isEmailMode,
                    appEnvironment: appEnvironment
                )
                .opacity(viewModel.step == .input ? 1 : 0)

                LoginOtpStepView(
                    viewModel: viewModel,
                    appEnvironment: appEnvironment
                )
                .opacity(viewModel.step == .otp ? 1 : 0)
            }

            Spacer()

            // Footer Terms
            VStack(spacing: 6) {
                Text("By continuing, you agree to our")
                    .foregroundColor(AppColors.textSecondary)
                HStack(spacing: 4) {
                    Text("Terms of Service")
                        .underline()
                    Text("and")
                    Text("Privacy Policy")
                        .underline()
                }
                .foregroundColor(AppColors.textSecondary)
            }
            .font(.system(size: 12, design: .rounded))
            .padding(.bottom, 48)
        }
        .background(LiquidGlassBackground())
        .overlay(
            SheetBorderShape(cornerRadius: 32)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(1.0), location: 0.0),
                            .init(color: .white.opacity(0.7), location: 0.25),
                            .init(color: .white.opacity(0.4), location: 0.5),
                            .init(color: .white.opacity(0.6), location: 0.75),
                            .init(color: .white.opacity(0.9), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .allowsHitTesting(false)
        )
        .interactiveDismissDisabled(false)
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.step)
    }
}
