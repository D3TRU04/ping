//
//  AuthService.swift
//  PingNative
//
//  DEPRECATED: Replaced by Clerk authentication
//  Kept for rollback purposes
//

import Foundation

/// Authentication service using Convex Auth
class AuthService {
    private let convexClient: ConvexClient
    private let keychainService: KeychainService

    init(convexClient: ConvexClient, keychainService: KeychainService) {
        self.convexClient = convexClient
        self.keychainService = keychainService
    }

    // MARK: - Authentication

    /// Sign up a new user with email and password
    func signup(email: String, password: String) async throws -> User {
        #if DEBUG
        print("🔵 Calling Convex signUp action...")
        #endif

        // Call Convex action via standard API: POST /api/action
        let response: ConvexAuthResponse = try await convexClient.callAction(
            function: "authActions:signUpAction",
            args: [
                "email": email,
                "password": password
            ]
        )

        #if DEBUG
        print("✅ Signup successful! User ID: \(response.userId)")
        #endif

        // Store tokens securely in Keychain
        keychainService.save(response.token, forKey: .accessToken)
        keychainService.save(response.refreshToken, forKey: .refreshToken)

        // Set token in client for subsequent requests
        convexClient.setAccessToken(response.token)

        // Return user object
        return User(
            id: response.userId,
            email: email,
            hasOnboarded: false
        )
    }

    /// Sign up a new user with phone number and password
    func signupWithPhone(phoneNumber: String, password: String) async throws -> User {
        #if DEBUG
        print("🔵 Calling Convex signUpWithPhone action...")
        #endif

        // Call Convex action via standard API: POST /api/action
        let response: ConvexAuthResponse = try await convexClient.callAction(
            function: "authActions:signUpWithPhoneAction",
            args: [
                "phoneNumber": phoneNumber,
                "password": password
            ]
        )

        #if DEBUG
        print("✅ Phone signup successful! User ID: \(response.userId)")
        #endif

        // Store tokens securely in Keychain
        keychainService.save(response.token, forKey: .accessToken)
        keychainService.save(response.refreshToken, forKey: .refreshToken)

        // Set token in client for subsequent requests
        convexClient.setAccessToken(response.token)

        // Return user object
        return User(
            id: response.userId,
            email: nil,
            phoneNumber: phoneNumber,
            hasOnboarded: false
        )
    }

    /// Log in existing user with email and password
    func login(email: String, password: String) async throws -> User {
        print("🔵 Calling Convex signIn action...")

        // Call Convex action via standard API: POST /api/action
        let response: ConvexAuthResponse = try await convexClient.callAction(
            function: "authActions:signInAction",
            args: [
                "email": email,
                "password": password
            ]
        )

        print("✅ Login successful! User ID: \(response.userId)")

        // Store tokens securely in Keychain
        keychainService.save(response.token, forKey: .accessToken)
        keychainService.save(response.refreshToken, forKey: .refreshToken)

        // Set token in client for subsequent requests
        convexClient.setAccessToken(response.token)

        // Fetch full user profile from Convex
        return try await fetchUserProfile(userId: response.userId)
    }

    /// Log out current user
    func logout() async {
        print("🔵 Logging out...")

        // Get current token for logout request
        if let token = keychainService.get(.accessToken) {
            do {
                // Call Convex mutation via standard API: POST /api/mutation
                let _: EmptyResponse = try await convexClient.mutation(
                    function: "auth:signOut",
                    args: ["token": token]
                )
                print("✅ Server logout successful")
            } catch {
                print("⚠️ Server logout failed: \(error.localizedDescription)")
                // Continue with local cleanup even if server call fails
            }
        }

        // Clear local tokens
        keychainService.clearAll()
        convexClient.clearAccessToken()

        print("✅ Local tokens cleared")
    }

    /// Get currently authenticated user
    func getCurrentUser() async -> User? {
        // Check if we have a stored token
        guard let accessToken = keychainService.get(.accessToken) else {
            print("⚠️ No access token found in Keychain")
            return nil
        }

        // Set token in client
        convexClient.setAccessToken(accessToken)

        do {
            // Query Convex for current user profile
            // This assumes you have a query: users:getCurrentUser
            let user: User = try await convexClient.query(
                function: "users:getCurrentUser",
                args: [:]
            )

            print("✅ Current user loaded: \(user.id)")
            return user

        } catch ConvexError.unauthorized {
            print("⚠️ Token expired or invalid, clearing session")
            await logout()
            return nil
        } catch {
            print("❌ Failed to get current user: \(error.localizedDescription)")
            return nil
        }
    }

    /// Refresh expired access token
    func refreshToken() async throws {
        guard let refreshToken = keychainService.get(.refreshToken) else {
            throw AuthError.noRefreshToken
        }

        print("🔵 Refreshing access token...")

        // Call Convex action via standard API: POST /api/action
        let response: ConvexAuthResponse = try await convexClient.callAction(
            function: "authActions:refreshTokenAction",
            args: ["refreshToken": refreshToken]
        )

        print("✅ Token refreshed successfully")

        // Update stored tokens
        keychainService.save(response.token, forKey: .accessToken)
        keychainService.save(response.refreshToken, forKey: .refreshToken)

        // Update token in client
        convexClient.setAccessToken(response.token)
    }

    // MARK: - OTP Verification

    /// Send OTP code to email or phone
    func sendOtp(destination: String, type: OtpType) async throws -> String {
        #if DEBUG
        print("🔵 Sending OTP to \(destination) via \(type)...")
        #endif

        // Call Convex action
        let response: OtpSendResponse = try await convexClient.callAction(
            function: "authActions:sendOtpAction",
            args: [
                "destination": destination,
                "type": type.rawValue
            ]
        )

        #if DEBUG
        if let code = response.code {
            print("🔐 OTP Code (DEV ONLY): \(code)")
        }
        print("✅ OTP sent successfully")
        #endif

        return response.destination
    }

    /// Verify OTP code
    func verifyOtp(destination: String, code: String) async throws -> Bool {
        #if DEBUG
        print("🔵 Verifying OTP for \(destination)...")
        #endif

        // Call Convex action
        let response: OtpVerifyResponse = try await convexClient.callAction(
            function: "authActions:verifyOtpAction",
            args: [
                "destination": destination,
                "code": code
            ]
        )

        #if DEBUG
        print("✅ OTP verified: \(response.verified)")
        #endif

        return response.verified
    }

    // MARK: - Private Helpers

    private func fetchUserProfile(userId: String) async throws -> User {
        // Query Convex for user profile by ID
        // This assumes you have a query: users:getById
        let user: User = try await convexClient.query(
            function: "users:getById",
            args: ["userId": userId]
        )
        return user
    }
}

// MARK: - Response Models

/// Response from Convex Auth actions (signUp, signIn, refreshToken)
struct ConvexAuthResponse: Decodable {
    let token: String          // JWT access token
    let refreshToken: String   // Refresh token
    let userId: String         // Convex user _id
}

private struct EmptyResponse: Decodable {}

/// Response from Convex OTP send action
struct OtpSendResponse: Decodable {
    let success: Bool
    let destination: String
    let code: String? // Only in development
}

/// Response from Convex OTP verify action
struct OtpVerifyResponse: Decodable {
    let success: Bool
    let verified: Bool
}

// MARK: - OTP Type

enum OtpType: String {
    case email = "email"
    case phone = "phone"
}

// MARK: - Error Types

enum AuthError: LocalizedError {
    case noRefreshToken
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "No refresh token available - please log in again"
        case .invalidResponse:
            return "Invalid response from authentication server"
        }
    }
}
