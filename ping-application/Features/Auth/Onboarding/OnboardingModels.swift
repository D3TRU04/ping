//
//  OnboardingModels.swift
//  PingNative
//
//  Data models for onboarding flow
//

import Foundation

// MARK: - Onboarding Error
enum OnboardingError: Error {
    case noClerkUser
}

// MARK: - Onboarding Form Data
struct OnboardingFormData {
    var email: String = ""
    var otpCode: String = ""
    var password: String = ""
    var fullName: String = ""
    var birthday: Date = Date()
    var username: String = ""
    var phoneNumber: String = ""
    var profilePicture: String? = nil
    var selectedCategories: [String] = []
    var selectedSubcategories: [String] = []
}

// MARK: - Step Config
struct StepConfig {
    let type: String
    let title: String?
    let subtitle: String?
    var titlePart1: String? = nil
    var highlightedText: String? = nil
    var titlePart2: String? = nil
    var categoryId: String? = nil
}
