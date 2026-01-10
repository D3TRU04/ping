//
//  ConvexClient.swift
//  PingNative
//
//  HTTP client for Convex API calls
//

import Foundation

/// HTTP client for Convex backend communication
class ConvexClient {
    private let deploymentUrl: String
    private let keychainService: KeychainService

    init(deploymentUrl: String, keychainService: KeychainService) {
        self.deploymentUrl = deploymentUrl
        self.keychainService = keychainService
    }

    // MARK: - Authentication Token

    func setAccessToken(_ token: String) {
        keychainService.save(token, forKey: .accessToken)
    }

    func clearAccessToken() {
        keychainService.clearAll()
    }

    // MARK: - Convex Queries

    /// Execute a Convex query
    /// - Parameters:
    ///   - function: Query function path (e.g., "users:getProfile")
    ///   - args: Query arguments as dictionary
    /// - Returns: Decoded response of type T
    func query<T: Decodable>(
        function: String,
        args: [String: Any] = [:]
    ) async throws -> T {
        return try await convexRequest(
            endpoint: "/api/query",
            function: function,
            args: args
        )
    }

    // MARK: - Convex Mutations

    /// Execute a Convex mutation
    /// - Parameters:
    ///   - function: Mutation function path (e.g., "messages:send")
    ///   - args: Mutation arguments as dictionary
    /// - Returns: Decoded response of type T
    func mutation<T: Decodable>(
        function: String,
        args: [String: Any] = [:]
    ) async throws -> T {
        return try await convexRequest(
            endpoint: "/api/mutation",
            function: function,
            args: args
        )
    }

    // MARK: - Convex Actions

    /// Execute a Convex action via standard API
    /// - Parameters:
    ///   - function: Action function path (e.g., "authActions:signUpAction")
    ///   - args: Action arguments as dictionary
    /// - Returns: Decoded response of type T
    func callAction<T: Decodable>(
        function: String,
        args: [String: Any] = [:]
    ) async throws -> T {
        return try await convexRequest(
            endpoint: "/api/action",
            function: function,
            args: args
        )
    }

    // MARK: - HTTP Actions (for Auth - DEPRECATED, use callAction instead)

    /// Execute a Convex HTTP action
    /// - Parameters:
    ///   - path: Action path (e.g., "/signIn", "/signUp")
    ///   - body: Request body
    /// - Returns: Decoded response of type T
    @available(*, deprecated, message: "Use callAction() instead - HTTP routes returning 404")
    func action<T: Decodable>(
        path: String,
        body: Encodable
    ) async throws -> T {
        guard let url = URL(string: deploymentUrl + path) else {
            throw ConvexError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        print("🌐 Convex Action: \(path)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConvexError.invalidResponse
        }

        print("🌐 Response status: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(ConvexErrorResponse.self, from: data) {
                throw ConvexError.actionError(errorResponse.message)
            }
            throw ConvexError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Private Helpers

    private func convexRequest<T: Decodable>(
        endpoint: String,
        function: String,
        args: [String: Any]
    ) async throws -> T {
        guard let url = URL(string: deploymentUrl + endpoint) else {
            throw ConvexError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Inject auth token if available
        if let token = keychainService.get(.accessToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Build Convex request body
        let requestBody: [String: Any] = [
            "path": function,
            "args": args
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        #if DEBUG
        print("🌐 Convex \(endpoint): \(function)")
        #endif

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConvexError.invalidResponse
        }

        #if DEBUG
        print("🌐 Response status: \(httpResponse.statusCode)")
        print("🌐 Response data length: \(data.count) bytes")

        // Debug: Print raw response FIRST
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🌐 Raw response: \(jsonString)")
        } else {
            print("⚠️ Could not convert response to string")
        }
        #endif

        // Handle unauthorized (token expired or invalid)
        if httpResponse.statusCode == 401 {
            throw ConvexError.unauthorized
        }

        // Check for non-2xx status codes
        guard (200...299).contains(httpResponse.statusCode) else {
            let decoder = JSONDecoder()
            if let errorResponse = try? decoder.decode(ConvexErrorResponse.self, from: data) {
                throw ConvexError.queryError(errorResponse.message)
            }
            throw ConvexError.httpError(httpResponse.statusCode)
        }

        // Check for error responses even with 200 status
        // Convex can return { "status": "error", "errorMessage": "..." } with 200 status
        // Parse as dictionary first to check for error status
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let status = json["status"] as? String,
           status == "error",
           let errorMessage = json["errorMessage"] as? String {
            print("❌ Convex error response: \(errorMessage)")
            throw ConvexError.queryError(errorMessage)
        }

        // Convex wraps responses in { "value": ... }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Try to decode as ConvexResponse wrapper first
        if let wrapper = try? decoder.decode(ConvexResponse<T>.self, from: data) {
            return wrapper.value
        }

        // Fallback: try direct decode
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Decoding error: \(error)")
            throw error
        }
    }
}

// MARK: - Response Wrappers

struct ConvexResponse<T: Decodable>: Decodable {
    let value: T
}

// MARK: - Error Types

enum ConvexError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case queryError(String)
    case actionError(String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Convex URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .queryError(let message):
            return message
        case .actionError(let message):
            return message
        case .unauthorized:
            return "Unauthorized - please log in again"
        }
    }
}

struct ConvexErrorResponse: Decodable {
    let message: String
}

struct ConvexErrorStatusResponse: Decodable {
    let status: String
    let errorMessage: String
}
