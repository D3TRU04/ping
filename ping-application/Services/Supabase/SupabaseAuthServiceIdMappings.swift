//
//  SupabaseAuthService+IdMappings.swift
//  PingNative
//
//  ID mapping operations for auth service
//

import Foundation

extension SupabaseAuthService {

    // MARK: - ID Mappings

    func getMapping(supabaseId: String, tableName: String) async throws -> IdMapping? {
        return try await client.fetchOptional(
            from: "id_mappings",
            query: [
                "supabase_id": "eq.\(supabaseId)",
                "table_name": "eq.\(tableName)"
            ]
        )
    }

    func getMappingByConvexId(convexId: String) async throws -> IdMapping? {
        return try await client.fetchOptional(
            from: "id_mappings",
            query: ["convex_id": "eq.\(convexId)"]
        )
    }

    func getMappingsForTable(tableName: String) async throws -> [IdMapping] {
        return try await client.fetch(
            from: "id_mappings",
            query: ["table_name": "eq.\(tableName)"]
        )
    }

    func createMapping(supabaseId: String, convexId: String, tableName: String) async throws -> IdMapping {
        return try await client.insert(
            into: "id_mappings",
            values: [
                "supabase_id": supabaseId,
                "convex_id": convexId,
                "table_name": tableName
            ]
        )
    }

    func deleteMapping(id: String) async throws {
        try await client.delete(
            from: "id_mappings",
            query: ["id": "eq.\(id)"]
        )
    }

    func deleteMappingsForTable(tableName: String) async throws {
        try await client.delete(
            from: "id_mappings",
            query: ["table_name": "eq.\(tableName)"]
        )
    }
}
