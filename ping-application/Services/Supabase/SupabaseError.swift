//
//  SupabaseError.swift
//  PingNative
//
//  Error types for Supabase operations
//

import Foundation

enum SupabaseError: LocalizedError {
    case invalidURL
    case invalidResponse
    case notFound
    case httpError(Int)
    case queryError(String)
    case insertError(String)
    case updateError(String)
    case deleteError(String)
    case upsertError(String)
    case rpcError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Supabase URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .notFound:
            return "Record not found"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .queryError(let message):
            return "Query error: \(message)"
        case .insertError(let message):
            return "Insert error: \(message)"
        case .updateError(let message):
            return "Update error: \(message)"
        case .deleteError(let message):
            return "Delete error: \(message)"
        case .upsertError(let message):
            return "Upsert error: \(message)"
        case .rpcError(let message):
            return "RPC error: \(message)"
        }
    }
}

struct SupabaseErrorResponse: Decodable {
    let message: String
    let code: String?
    let details: String?
    let hint: String?
}
