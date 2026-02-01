//
//  SupabaseAuthService+OTP.swift
//  PingNative
//
//  OTP code operations for auth service
//

import Foundation

extension SupabaseAuthService {

    // MARK: - OTP Codes (Legacy)

    func getOTP(destination: String) async throws -> OTPCode? {
        return try await client.fetchOptional(
            from: "otp_codes",
            query: [
                "destination": "eq.\(destination)",
                "verified": "eq.false",
                "order": "created_at.desc",
                "limit": "1"
            ]
        )
    }

    func createOTP(destination: String, code: String, expiresInMinutes: Int = 10) async throws -> OTPCode {
        let expiresAt = Date().addingTimeInterval(TimeInterval(expiresInMinutes * 60))

        return try await client.insert(
            into: "otp_codes",
            values: [
                "destination": destination,
                "code": code,
                "expires_at": ISO8601DateFormatter().string(from: expiresAt),
                "verified": false,
                "attempts": 0
            ]
        )
    }

    func verifyOTP(destination: String, code: String) async throws -> Bool {
        guard let otp = try await getOTP(destination: destination) else {
            return false
        }

        if otp.expiresAt < Date() {
            return false
        }

        if otp.code != code {
            let _: OTPCode = try await client.update(
                table: "otp_codes",
                values: ["attempts": otp.attempts + 1],
                query: ["id": "eq.\(otp.id)"]
            )
            return false
        }

        let _: OTPCode = try await client.update(
            table: "otp_codes",
            values: ["verified": true],
            query: ["id": "eq.\(otp.id)"]
        )

        return true
    }

    func deleteExpiredOTPs() async throws {
        let now = ISO8601DateFormatter().string(from: Date())
        try await client.delete(
            from: "otp_codes",
            query: ["expires_at": "lt.\(now)"]
        )
    }
}
