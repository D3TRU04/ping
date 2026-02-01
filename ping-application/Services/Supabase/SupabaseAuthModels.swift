//
//  SupabaseAuthModels.swift
//  PingNative
//
//  Model types for auth service
//  Note: No CodingKeys needed - SupabaseClient uses .convertFromSnakeCase
//

import Foundation

struct AuthSession: Codable, Identifiable {
    let id: String
    let userId: String
    let token: String
    let refreshToken: String
    let expiresAt: Date
    let createdAt: Date
}

struct OTPCode: Codable, Identifiable {
    let id: String
    let destination: String
    let code: String
    let expiresAt: Date
    let verified: Bool
    let attempts: Int
    let createdAt: Date
}

struct IdMapping: Codable, Identifiable {
    let id: String
    let supabaseId: String
    let convexId: String
    let tableName: String
    let createdAt: Date
}
