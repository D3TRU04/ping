//
//  SupabaseClient+Operations.swift
//  PingNative
//
//  Update, upsert, delete, and RPC operations for SupabaseClient
//

import Foundation

extension SupabaseClient {

    // MARK: - Update Operations

    func update<T: Decodable>(
        table: String,
        values: [String: Any],
        query: [String: String],
        returning: Bool = true
    ) async throws -> T {
        var urlComponents = URLComponents(string: "\(baseUrl)/\(table)")!
        urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = urlComponents.url else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")

        if returning {
            request.setValue("return=representation", forHTTPHeaderField: "Prefer")
            request.setValue("application/vnd.pgrst.object+json", forHTTPHeaderField: "Accept")
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: values)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.updateError(errorResponse.message)
            }
            throw SupabaseError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Upsert Operations

    func upsert<T: Decodable>(
        into table: String,
        values: [String: Any],
        onConflict: String,
        returning: Bool = true
    ) async throws -> T {
        var urlComponents = URLComponents(string: "\(baseUrl)/\(table)")!
        urlComponents.queryItems = [URLQueryItem(name: "on_conflict", value: onConflict)]

        guard let url = urlComponents.url else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")

        if returning {
            request.addValue("return=representation", forHTTPHeaderField: "Prefer")
            request.setValue("application/vnd.pgrst.object+json", forHTTPHeaderField: "Accept")
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: values)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.upsertError(errorResponse.message)
            }
            throw SupabaseError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Delete Operations

    func delete(
        from table: String,
        query: [String: String]
    ) async throws {
        var urlComponents = URLComponents(string: "\(baseUrl)/\(table)")!
        urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = urlComponents.url else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.deleteError(errorResponse.message)
            }
            throw SupabaseError.httpError(httpResponse.statusCode)
        }
    }

    // MARK: - RPC (Remote Procedure Call)

    func rpc<T: Decodable>(
        function: String,
        params: [String: Any] = [:]
    ) async throws -> T {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/rpc/\(function)") else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")

        request.httpBody = try JSONSerialization.data(withJSONObject: params)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.rpcError(errorResponse.message)
            }
            throw SupabaseError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }
}
