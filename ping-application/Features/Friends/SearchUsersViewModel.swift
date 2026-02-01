//
//  SearchUsersViewModel.swift
//  PingNative
//
//  View model for user search functionality
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SearchUsersViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [UserSearchResult] = []
    @Published var recentSearches: [UserSearchResult] = []
    @Published var loading: Bool = false

    private let recentSearchesKey = "recent_searches"

    func searchUsers(query: String, appEnvironment: AppEnvironment) async {
        guard !query.isEmpty, query.count >= 2 else {
            searchResults = []
            return
        }

        loading = true

        do {
            let results = try await appEnvironment.profileService.searchUsers(query: query, limit: 20)

            searchResults = results.map { result in
                UserSearchResult(
                    id: result.id,
                    username: result.username,
                    fullName: result.fullName,
                    avatarUrl: result.avatarUrl
                )
            }
        } catch {
            print("Error searching users: \(error)")
            searchResults = []
        }

        loading = false
    }

    func loadRecentSearches() async {
        if let data = UserDefaults.standard.data(forKey: recentSearchesKey),
           let decoded = try? JSONDecoder().decode([UserSearchResponse].self, from: data) {
            recentSearches = decoded.map { $0.toUserSearchResult() }
        }
    }

    func saveRecentSearch(user: UserSearchResult) {
        recentSearches.removeAll { $0.id == user.id }
        recentSearches.insert(user, at: 0)

        if recentSearches.count > 5 {
            recentSearches = Array(recentSearches.prefix(5))
        }

        if let encoded = try? JSONEncoder().encode(recentSearches.map { $0.toResponse() }),
           let decoded = try? JSONDecoder().decode([UserSearchResponse].self, from: encoded) {
            if let saved = try? JSONEncoder().encode(decoded) {
                UserDefaults.standard.set(saved, forKey: recentSearchesKey)
            }
        }
    }

    func removeRecentSearch(userId: String) {
        recentSearches.removeAll { $0.id == userId }

        if let encoded = try? JSONEncoder().encode(recentSearches.map { $0.toResponse() }),
           let decoded = try? JSONDecoder().decode([UserSearchResponse].self, from: encoded) {
            if let saved = try? JSONEncoder().encode(decoded) {
                UserDefaults.standard.set(saved, forKey: recentSearchesKey)
            }
        }
    }

    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
}
