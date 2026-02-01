//
//  SupabaseAuthService.swift
//  PingNative
//
//  Legacy Auth service for Supabase integration
//  Handles auth_sessions, otp_codes, and id_mappings tables
//  Note: Primary auth is handled by Clerk - these are legacy/utility tables
//

import Foundation

class SupabaseAuthService {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Auth Sessions (Legacy)

    func getSession(token: String) async throws -> AuthSession? {
        return try await client.fetchOptional(
            from: "auth_sessions",
            query: ["token": "eq.\(token)"]
        )
    }

    func getSessionByRefreshToken(refreshToken: String) async throws -> AuthSession? {
        return try await client.fetchOptional(
            from: "auth_sessions",
            query: ["refresh_token": "eq.\(refreshToken)"]
        )
    }

    func getUserSessions(userId: String) async throws -> [AuthSession] {
        return try await client.fetch(
            from: "auth_sessions",
            query: ["user_id": "eq.\(userId)"]
        )
    }

    func createSession(
        userId: String,
        token: String,
        refreshToken: String,
        expiresAt: Date
    ) async throws -> AuthSession {
        return try await client.insert(
            into: "auth_sessions",
            values: [
                "user_id": userId,
                "token": token,
                "refresh_token": refreshToken,
                "expires_at": ISO8601DateFormatter().string(from: expiresAt)
            ]
        )
    }

    func deleteSession(token: String) async throws {
        try await client.delete(
            from: "auth_sessions",
            query: ["token": "eq.\(token)"]
        )
    }

    func deleteUserSessions(userId: String) async throws {
        try await client.delete(
            from: "auth_sessions",
            query: ["user_id": "eq.\(userId)"]
        )
    }

    func deleteExpiredSessions() async throws {
        let now = ISO8601DateFormatter().string(from: Date())
        try await client.delete(
            from: "auth_sessions",
            query: ["expires_at": "lt.\(now)"]
        )
    }

    // MARK: - Helpers

    func generateOTPCode(length: Int = 6) -> String {
        let digits = "0123456789"
        return String((0..<length).map { _ in digits.randomElement()! })
    }

    func generateToken() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<64).map { _ in characters.randomElement()! })
    }
}
