//
//  UserSearchModels.swift
//  PingNative
//
//  Data models for user search functionality
//

import Foundation

struct UserSearchResult: Identifiable, Codable {
    let id: String
    let username: String
    let fullName: String?
    let avatarUrl: String?

    func toResponse() -> UserSearchResponse {
        UserSearchResponse(
            id: id,
            username: username,
            fullName: fullName,
            avatarUrl: avatarUrl
        )
    }
}

struct UserSearchResponse: Codable {
    let id: String
    let username: String
    let fullName: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
    }

    func toUserSearchResult() -> UserSearchResult {
        UserSearchResult(
            id: id,
            username: username,
            fullName: fullName,
            avatarUrl: avatarUrl
        )
    }
}
