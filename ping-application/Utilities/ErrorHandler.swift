//
//  ErrorHandler.swift
//  PingNative
//
//  Centralized error handling utilities
//

import Foundation
import SwiftUI
import Combine

class ErrorHandler: ObservableObject {
    @Published var currentError: AppError? = nil
    @Published var showError: Bool = false
    
    func handle(_ error: Error) {
        let appError = AppError.from(error)
        currentError = appError
        showError = true
    }
    
    func clear() {
        currentError = nil
        showError = false
    }
}

enum AppError: LocalizedError, Identifiable {
    case networkError(String)
    case authenticationError(String)
    case validationError(String)
    case serverError(String)
    case unknownError(String)
    
    var id: String {
        switch self {
        case .networkError(let message):
            return "network_\(message)"
        case .authenticationError(let message):
            return "auth_\(message)"
        case .validationError(let message):
            return "validation_\(message)"
        case .serverError(let message):
            return "server_\(message)"
        case .unknownError(let message):
            return "unknown_\(message)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .authenticationError(let message):
            return "Authentication error: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknownError(let message):
            return "An error occurred: \(message)"
        }
    }
    
    static func from(_ error: Error) -> AppError {
        // Removed SupabaseError handling
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkError("No internet connection")
            case .timedOut:
                return .networkError("Request timed out")
            default:
                return .networkError(urlError.localizedDescription)
            }
        }
        
        return .unknownError(error.localizedDescription)
    }
}

struct ErrorAlert: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorHandler.showError) {
                Button("OK") {
                    errorHandler.clear()
                }
            } message: {
                if let error = errorHandler.currentError {
                    Text(error.errorDescription ?? "An unknown error occurred")
                }
            }
    }
}

extension View {
    func errorAlert(errorHandler: ErrorHandler) -> some View {
        modifier(ErrorAlert(errorHandler: errorHandler))
    }
}
