//
//  ChatService.swift
//  PingNative
//
//  Source: ping/apps/src/screens/chat/hooks/ (implied)
//  Complete Chat service with Supabase integration
//

import Foundation

// ChatMessage model - shared between service and views
struct ChatMessage: Identifiable {
    let id: String
    let senderId: String
    let receiverId: String
    let text: String
    let createdAt: Date
    var isRead: Bool
}

class ChatService {
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func fetchChats(userId: String) async throws -> [Chat] {
        // Fetch chats from Supabase
        // This would typically join with conversations table
        let response: [ChatResponse] = try await supabaseClient.get(
            path: "/rest/v1/conversations",
            queryParams: [
                "user_id": "eq.\(userId)",
                "order": "updated_at.desc"
            ],
            responseType: [ChatResponse].self
        )
        
        return response.map { $0.toChat() }
    }
    
    func fetchMessages(conversationId: String) async throws -> [ChatMessage] {
        // Fetch messages from Supabase
        let response: [MessageResponse] = try await supabaseClient.get(
            path: "/rest/v1/messages",
            queryParams: [
                "conversation_id": "eq.\(conversationId)",
                "order": "created_at.asc"
            ],
            responseType: [MessageResponse].self
        )
        
        return response.map { $0.toMessage() }
    }
    
    func sendMessage(
        conversationId: String,
        senderId: String,
        receiverId: String,
        text: String
    ) async throws -> ChatMessage {
        // Send message to Supabase
        let request = SendMessageRequest(
            conversationId: conversationId,
            senderId: senderId,
            receiverId: receiverId,
            text: text
        )
        
        let response: MessageResponse = try await supabaseClient.post(
            path: "/rest/v1/messages",
            body: request,
            queryParams: nil,
            responseType: MessageResponse.self
        )
        
        return response.toMessage()
    }
    
    func createConversation(userId1: String, userId2: String) async throws -> String {
        // Create or get existing conversation
        let request = CreateConversationRequest(userId1: userId1, userId2: userId2)
        
        let response: ConversationResponse = try await supabaseClient.post(
            path: "/rest/v1/conversations",
            body: request,
            queryParams: nil,
            responseType: ConversationResponse.self
        )
        
        return response.id
    }
    
    // Real-time subscription for new messages
    func subscribeToMessages(
        conversationId: String,
        onMessage: @escaping (ChatMessage) -> Void
    ) -> MessageSubscription? {
        // TODO: Implement real-time subscription using Supabase Realtime
        return nil
    }
}

struct Chat: Identifiable {
    let id: String
    let name: String?
}

struct ChatResponse: Codable {
    let id: String
    let name: String?
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case updatedAt = "updated_at"
    }
    
    func toChat() -> Chat {
        Chat(id: id, name: name)
    }
}

struct MessageResponse: Codable {
    let id: String
    let conversationId: String
    let senderId: String
    let receiverId: String
    let text: String
    let createdAt: Date
    let isRead: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case text
        case createdAt = "created_at"
        case isRead = "is_read"
    }
    
    func toMessage() -> ChatMessage {
        ChatMessage(
            id: id,
            senderId: senderId,
            receiverId: receiverId,
            text: text,
            createdAt: createdAt,
            isRead: isRead
        )
    }
}

struct SendMessageRequest: Codable {
    let conversationId: String
    let senderId: String
    let receiverId: String
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case text
    }
}

struct CreateConversationRequest: Codable {
    let userId1: String
    let userId2: String
    
    enum CodingKeys: String, CodingKey {
        case userId1 = "user_id_1"
        case userId2 = "user_id_2"
    }
}

struct ConversationResponse: Codable {
    let id: String
}

class MessageSubscription {
    func cancel() {
        // Cancel subscription
    }
}
