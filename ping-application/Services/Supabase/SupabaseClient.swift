//
//  SupabaseClient.swift
//  PingNative
//
//  Created on 12/3/25.
//

import Foundation

/// HTTP client for Supabase API calls
/// 
/// This is a basic implementation using URLSession.
/// For production, consider using the official Supabase Swift SDK:
/// https://github.com/supabase/supabase-swift
class SupabaseClient {
    private let config: AppConfig
    private let baseURL: URL
    private var accessToken: String?
    
    init(config: AppConfig) {
        self.config = config
        guard let url = URL(string: config.supabaseURL) else {
            fatalError("Invalid Supabase URL: \(config.supabaseURL)")
        }
        self.baseURL = url
    }
    
    // MARK: - Authentication
    
    func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    func clearAccessToken() {
        self.accessToken = nil
    }
    
    // MARK: - HTTP Methods
    
    func get<T: Decodable>(
        path: String,
        queryParams: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(method: "GET", path: path, queryParams: queryParams, body: nil, responseType: responseType)
    }
    
    func post<T: Decodable>(
        path: String,
        body: Encodable?,
        queryParams: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(method: "POST", path: path, queryParams: queryParams, body: body, responseType: responseType)
    }
    
    func patch<T: Decodable>(
        path: String,
        body: Encodable?,
        queryParams: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(method: "PATCH", path: path, queryParams: queryParams, body: body, responseType: responseType)
    }
    
    func put<T: Decodable>(
        path: String,
        body: Encodable?,
        queryParams: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(method: "PUT", path: path, queryParams: queryParams, body: body, responseType: responseType)
    }
    
    func delete<T: Decodable>(
        path: String,
        queryParams: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await request(method: "DELETE", path: path, queryParams: queryParams, body: nil, responseType: responseType)
    }
    
    // MARK: - Private
    
    private func request<T: Decodable>(
        method: String,
        path: String,
        queryParams: [String: String]? = nil,
        body: Encodable?,
        responseType: T.Type
    ) async throws -> T {
        // Construct URL properly
        var urlString: String
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            urlString = path
        } else {
            // Remove trailing slash from baseURL and leading slash from path to avoid double slashes
            var base = baseURL.absoluteString
            if base.hasSuffix("/") {
                base = String(base.dropLast())
            }
            var cleanPath = path
            if !cleanPath.hasPrefix("/") {
                cleanPath = "/" + cleanPath
            }
            urlString = base + cleanPath
        }

        guard var urlComponents = URLComponents(string: urlString) else {
            print("❌ Failed to create URLComponents from: \(urlString)")
            throw SupabaseError.invalidURL
        }

        // Add query parameters
        if let queryParams = queryParams, !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else {
            print("❌ Failed to create URL from URLComponents: \(urlComponents)")
            throw SupabaseError.invalidURL
        }

        print("🌐 Request URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/vnd.pgjson.object+json", forHTTPHeaderField: "Prefer")
        
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(body)
        }
        
        print("🌐 Sending \(method) request...")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw SupabaseError.invalidResponse
        }

        print("🌐 Response status: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            if let error = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                print("❌ API Error: \(error.message)")
                throw SupabaseError.apiError(error.message)
            }
            let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
            print("❌ HTTP Error \(httpResponse.statusCode): \(responseBody)")
            throw SupabaseError.httpError(httpResponse.statusCode)
        }

        print("✅ Request successful")

        // Log response data for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("📦 Response body: \(responseString)")
        } else {
            print("📦 Response body: (unable to decode as string)")
        }
        print("📦 Response data size: \(data.count) bytes")

        // Handle empty responses
        if responseType == EmptyResponse.self {
            return EmptyResponse() as! T
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        do {
            let decoded = try decoder.decode(responseType, from: data)
            print("✅ Successfully decoded response")
            return decoded
        } catch {
            print("❌ Decoding error: \(error)")
            throw error
        }
    }
}

// MARK: - Error Types

enum SupabaseError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return message
        }
    }
}

struct SupabaseErrorResponse: Decodable {
    let message: String
}

struct EmptyResponse: Decodable {
    init() {}
}
