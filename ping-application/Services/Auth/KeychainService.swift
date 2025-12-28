//
//  KeychainService.swift
//  PingNative
//
//  Secure token storage using iOS Keychain
//

import Foundation
import Security

/// Service for securely storing and retrieving auth tokens using iOS Keychain
class KeychainService {
    private let service = "com.ping.app"

    enum KeychainKey: String {
        case accessToken = "convex_access_token"
        case refreshToken = "convex_refresh_token"
    }

    // MARK: - Public Methods

    /// Save a string value to Keychain
    func save(_ value: String, forKey key: KeychainKey) {
        let data = value.data(using: .utf8)!

        // Delete any existing value first
        delete(key)

        // Create query for adding new item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("⚠️ Keychain save failed for \(key.rawValue): \(status)")
        }
    }

    /// Retrieve a string value from Keychain
    func get(_ key: KeychainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }

        return nil
    }

    /// Delete a value from Keychain
    func delete(_ key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        SecItemDelete(query as CFDictionary)
    }

    /// Clear all auth tokens
    func clearAll() {
        delete(.accessToken)
        delete(.refreshToken)
    }

    // MARK: - Migration Helper

    /// Migrate tokens from UserDefaults to Keychain (one-time operation)
    func migrateFromUserDefaults() {
        // Check if we have old Supabase tokens in UserDefaults
        if let oldAccessToken = UserDefaults.standard.string(forKey: "supabase_access_token") {
            print("🔄 Migrating access token from UserDefaults to Keychain")
            // Note: We won't actually migrate Supabase tokens since they're incompatible
            // This just cleans up the old storage
            UserDefaults.standard.removeObject(forKey: "supabase_access_token")
        }

        if let oldRefreshToken = UserDefaults.standard.string(forKey: "supabase_refresh_token") {
            print("🔄 Migrating refresh token from UserDefaults to Keychain")
            UserDefaults.standard.removeObject(forKey: "supabase_refresh_token")
        }
    }
}
