//
//  SignupViewModel+Navigation.swift
//  PingNative
//
//  Navigation and animation logic for signup flow
//

import Foundation
import SwiftUI

extension SignupViewModel {

    func selectMethod(_ method: SignupMethod) {
        signupMethod = method
        Task {
            await animateForward {
                if method == .email {
                    self.currentStep = .emailInput
                    self.progress = 0.4
                } else {
                    self.currentStep = .phoneInput
                    self.progress = 0.5
                }
            }
        }
    }

    func nextStep(appEnvironment: AppEnvironment? = nil) async {
        errorMessage = nil
        formErrors = [:]

        switch currentStep {
        case .options:
            break

        case .emailInput:
            if isFormValid {
                await animateForward {
                    self.currentStep = .passwordInput
                    self.progress = 0.6
                }
            } else {
                formErrors["email"] = "Please enter a valid email address"
            }

        case .passwordInput:
            if isFormValid {
                await animateForward {
                    self.currentStep = .confirmPassword
                    self.progress = 0.8
                }
            } else {
                formErrors["password"] = "Password must be at least 6 characters"
            }

        case .confirmPassword:
            if isFormValid {
                if let env = appEnvironment {
                    if signupMethod == .email {
                        await signupWithEmail(appEnvironment: env)
                    } else if signupMethod == .phone {
                        await sendOtpWithClerk(appEnvironment: env)
                    }
                }
            } else {
                formErrors["confirmPassword"] = "Passwords do not match"
            }

        case .phoneInput:
            if isFormValid {
                await animateForward {
                    self.currentStep = .passwordInput
                    self.progress = 0.6
                }
            } else {
                formErrors["phoneNumber"] = "Please enter a valid phone number"
            }

        case .otpInput:
            if isFormValid {
                if let env = appEnvironment {
                    await verifyOtpWithClerk(appEnvironment: env)
                }
            } else {
                formErrors["otp"] = "Please enter the 6-digit code"
            }
        }
    }

    func prevStep() {
        errorMessage = nil
        formErrors = [:]

        Task {
            switch currentStep {
            case .options:
                break
            case .emailInput:
                await animateBackward {
                    self.currentStep = .options
                    self.signupMethod = .none
                    self.progress = 0.2
                }
            case .passwordInput:
                await animateBackward {
                    if self.signupMethod == .email {
                        self.currentStep = .emailInput
                        self.progress = 0.4
                    } else if self.signupMethod == .phone {
                        self.currentStep = .phoneInput
                        self.progress = 0.5
                    }
                }
            case .confirmPassword:
                await animateBackward {
                    self.currentStep = .passwordInput
                    self.progress = 0.6
                }
            case .phoneInput:
                await animateBackward {
                    self.currentStep = .options
                    self.signupMethod = .none
                    self.progress = 0.2
                }
            case .otpInput:
                await animateBackward {
                    self.currentStep = .confirmPassword
                    self.progress = 0.8
                }
            }
        }
    }

    func animateForward(_ stepChange: @escaping () -> Void) async {
        fadeAnim = 0
        stepChange()
        slideAnim = 15

        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            fadeAnim = 1
            slideAnim = 0
        }
    }

    func animateBackward(_ stepChange: @escaping () -> Void) async {
        fadeAnim = 0
        stepChange()
        slideAnim = -15

        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            fadeAnim = 1
            slideAnim = 0
        }
    }
}
