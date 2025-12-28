//
//  ChatRoomView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/chat/chat-room/page.tsx
//  Chat room screen matching RN implementation
//

import SwiftUI
import Combine

struct ChatRoomView: View {
    let currentUser: User
    let otherUser: User
    let conversationId: String
    @StateObject private var viewModel = ChatRoomViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Header
            ChatHeader(
                otherUser: otherUser,
                onBack: { dismiss() },
                onProfilePress: {
                    // Navigate to profile
                }
            )
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.chatItems) { item in
                            if item.type == .date {
                                DateSeparator(date: item.dateString ?? "")
                            } else if let message = item.message {
                                MessageBubble(
                                    message: message,
                                    isFromCurrentUser: message.senderId == currentUser.id
                                )
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.chatItems.count) { _ in
                    if let lastItem = viewModel.chatItems.last {
                        withAnimation {
                            proxy.scrollTo(lastItem.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Message Input
            MessageInput(
                text: $viewModel.inputText,
                sending: viewModel.sending,
                onSend: {
                    Task {
                        await viewModel.sendMessage(
                            conversationId: conversationId,
                            currentUserId: currentUser.id
                        )
                    }
                }
            )
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadMessages(conversationId: conversationId)
        }
    }
}

@MainActor
class ChatRoomViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var optimisticMessages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var sending: Bool = false
    @Published var loading: Bool = false
    
    var chatItems: [ChatRoomItem] {
        var items: [ChatRoomItem] = []
        var lastDate: String? = nil
        
        let allMessages = (messages + optimisticMessages).sorted { $0.createdAt < $1.createdAt }
        
        for message in allMessages {
            let messageDate = formatDate(message.createdAt)
            if messageDate != lastDate {
                items.append(ChatRoomItem(type: .date, dateString: messageDate))
                lastDate = messageDate
            }
            items.append(ChatRoomItem(type: .message, message: message))
        }
        
        return items
    }
    
    func loadMessages(conversationId: String) async {
        loading = true
        // TODO: Load messages from Supabase
        loading = false
    }
    
    func sendMessage(conversationId: String, currentUserId: String) async {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let tempMessage = ChatMessage(
            id: UUID().uuidString,
            senderId: currentUserId,
            receiverId: "", // Will be set by backend
            text: inputText,
            createdAt: Date(),
            isRead: false
        )
        
        optimisticMessages.append(tempMessage)
        sending = true
        let messageText = inputText
        inputText = ""
        
        // TODO: Send message to Supabase
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        optimisticMessages.removeAll { $0.id == tempMessage.id }
        // Add real message when received from backend
        sending = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ChatRoomItem: Identifiable {
    let id = UUID()
    let type: ChatRoomItemType
    var dateString: String? = nil
    var message: ChatMessage? = nil
}

enum ChatRoomItemType {
    case date
    case message
}

struct ChatHeader: View {
    let otherUser: User
    let onBack: () -> Void
    let onProfilePress: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                onBack()
            }) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
            
            Button(action: onProfilePress) {
                HStack(spacing: 12) {
                    if let avatar = otherUser.avatar, let url = URL(string: avatar) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    }
                    
                    Text(otherUser.name ?? otherUser.username ?? "User")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            Text(message.text)
                .font(.system(size: 16))
                .foregroundColor(isFromCurrentUser ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isFromCurrentUser ? AppColors.mint : Color(hex: "F5F6FA"))
                .cornerRadius(20)
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}

struct DateSeparator: View {
    let date: String
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            Text(date)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
}

struct MessageInput: View {
    @Binding var text: String
    let sending: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $text)
                .textFieldStyle(.roundedBorder)
                .disabled(sending)
            
            Button(action: onSend) {
                if sending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 44, height: 44)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(AppColors.mint)
                }
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || sending)
        }
        .padding()
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: -1)
    }
}

struct EmptyState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "message")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No messages yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Start the conversation!")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
