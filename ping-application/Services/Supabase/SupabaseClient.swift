//
//  SupabaseClient.swift
//  PingNative
//
//  Supabase client for database operations
//

import Foundation

class SupabaseClient {
    let supabaseUrl: String
    let supabaseKey: String
    let baseUrl: String

    init(supabaseUrl: String, supabaseKey: String) {
        self.supabaseUrl = supabaseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.supabaseKey = supabaseKey
        self.baseUrl = "\(self.supabaseUrl)/rest/v1"
    }

    // MARK: - Query Operations

    func fetch<T: Decodable>(
        from table: String,
        query: [String: String] = [:],
        select: String = "*",
        single: Bool = false
    ) async throws -> T {
        var urlComponents = URLComponents(string: "\(baseUrl)/\(table)")!

        var queryItems = [URLQueryItem(name: "select", value: select)]
        for (key, value) in query {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")

        if single {
            request.setValue("application/vnd.pgrst.object+json", forHTTPHeaderField: "Accept")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        if httpResponse.statusCode == 406 {
            throw SupabaseError.notFound
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.queryError(errorResponse.message)
            }
            throw SupabaseError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }

    func fetchOptional<T: Decodable>(
        from table: String,
        query: [String: String] = [:],
        select: String = "*"
    ) async throws -> T? {
        do {
            let result: T = try await fetch(from: table, query: query, select: select, single: true)
            return result
        } catch SupabaseError.notFound {
            return nil
        }
    }

    // MARK: - Insert Operations

    func insert<T: Decodable>(
        into table: String,
        values: [String: Any],
        returning: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseUrl)/\(table)") else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                throw SupabaseError.insertError(errorResponse.message)
            }
            throw SupabaseError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }
}
