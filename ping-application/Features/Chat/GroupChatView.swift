//
//  GroupChatView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/chat/group-chat/page.tsx
//  Group chat screen
//

import SwiftUI
import Combine

struct GroupChatView: View {
    let groupChat: GroupChat
    let currentUser: User
    @StateObject private var viewModel = GroupChatViewModel()
    @State private var showMembersList: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "FAF6F2").ignoresSafeArea()
            
            if showMembersList {
                GroupMembersListView(
                    groupChat: groupChat,
                    onBack: { showMembersList = false },
                    onAddMember: {
                        // TODO: Implement add member
                    },
                    onEditGroupName: {
                        // TODO: Implement edit group name
                    }
                )
            } else {
                VStack(spacing: 0) {
                    // Header
                    GroupChatHeader(
                        groupChat: groupChat,
                        messageCount: viewModel.allMessages.count,
                        onBack: { dismiss() },
                        onEdit: {
                            // Navigate to group settings
                        },
                        onGroupNamePress: {
                            showMembersList = true
                        }
                    )
                    
                    // Messages
                    if viewModel.loading {
                        VStack {
                            Spacer()
                            ProgressView()
                            Text("Loading messages...")
                                .foregroundColor(AppColors.mint)
                                .padding(.top, 8)
                            Spacer()
                        }
                    } else {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(viewModel.chatItems) { item in
                                        if item.type == .date {
                                            DateSeparator(date: item.dateString ?? "")
                                        } else if let message = item.message {
                                            GroupMessageBubble(
                                                message: message,
                                                sender: groupChat.members.first { $0.id == message.senderId },
                                                isOwnMessage: message.senderId == currentUser.id,
                                                allMessages: viewModel.allMessages
                                            )
                                        }
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: viewModel.chatItems.count) { _ in
                                if let lastId = viewModel.chatItems.last?.id {
                                    withAnimation {
                                        proxy.scrollTo(lastId, anchor: .bottom)
                                    }
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
                                    groupId: groupChat.id,
                                    senderId: currentUser.id
                                )
                            }
                        }
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadMessages(groupId: groupChat.id)
        }
    }
}

@MainActor
class GroupChatViewModel: ObservableObject {
    @Published var messages: [GroupChatMessage] = []
    @Published var optimisticMessages: [GroupChatMessage] = []
    @Published var inputText: String = ""
    @Published var sending: Bool = false
    @Published var loading: Bool = false
    
    var allMessages: [GroupChatMessage] {
        messages + optimisticMessages
    }
    
    var chatItems: [ChatItem] {
        var items: [ChatItem] = []
        var lastDate: String = ""
        
        let sorted = allMessages.sorted { $0.createdAt < $1.createdAt }
        
        for message in sorted {
            let messageDate = formatDate(message.createdAt)
            
            if messageDate != lastDate {
                items.append(ChatItem(type: .date, dateString: messageDate, message: nil))
                lastDate = messageDate
            }
            
            items.append(ChatItem(type: .message, dateString: nil, message: message))
        }
        
        return items
    }
    
    func loadMessages(groupId: String) async {
        loading = true
        
        do {
            // TODO: Load messages from Supabase
            // messages = try await chatService.fetchGroupMessages(groupId: groupId)
        } catch {
            // Handle error
        }
        
        loading = false
    }
    
    func sendMessage(groupId: String, senderId: String) async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let text = inputText
        inputText = ""
        sending = true
        
        // Optimistic update
        let optimisticMessage = GroupChatMessage(
            id: UUID().uuidString,
            groupId: groupId,
            senderId: senderId,
            text: text,
            createdAt: Date(),
            isRead: false
        )
        
        optimisticMessages.append(optimisticMessage)
        
        do {
            // TODO: Send message to Supabase
            // let sentMessage = try await chatService.sendGroupMessage(...)
            // Remove optimistic, add real message
            optimisticMessages.removeAll { $0.id == optimisticMessage.id }
            // messages.append(sentMessage)
        } catch {
            // Remove optimistic on error
            optimisticMessages.removeAll { $0.id == optimisticMessage.id }
            // Show error
        }
        
        sending = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct GroupChat: Identifiable {
    let id: String
    let name: String
    let createdBy: String
    let createdAt: Date
    let updatedAt: Date
    let members: [User]
}

struct GroupChatMessage: Identifiable {
    let id: String
    let groupId: String
    let senderId: String
    let text: String
    let createdAt: Date
    let isRead: Bool
}

struct ChatItem: Identifiable {
    let id = UUID()
    let type: ChatItemType
    let dateString: String?
    let message: GroupChatMessage?
}

enum ChatItemType {
    case date
    case message
}

struct GroupChatHeader: View {
    let groupChat: GroupChat
    let messageCount: Int
    let onBack: () -> Void
    let onEdit: () -> Void
    let onGroupNamePress: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
            
            Button(action: onGroupNamePress) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(groupChat.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(groupChat.members.count) members • \(messageCount) messages")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color.white)
    }
}

struct GroupMessageBubble: View {
    let message: GroupChatMessage
    let sender: User?
    let isOwnMessage: Bool
    let allMessages: [GroupChatMessage]
    
    var showSenderName: Bool {
        guard let sender = sender else { return false }
        let previousMessage = allMessages.last { $0.id != message.id && $0.createdAt < message.createdAt }
        return previousMessage?.senderId != message.senderId || previousMessage == nil
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isOwnMessage {
                // Avatar
                if let avatar = sender?.avatar, let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                }
            } else {
                Spacer().frame(width: 40)
            }
            
            VStack(alignment: isOwnMessage ? .trailing : .leading, spacing: 4) {
                if showSenderName && !isOwnMessage, let sender = sender {
                    Text(sender.name ?? sender.username ?? "User")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                }
                
                Text(message.text)
                    .font(.system(size: 16))
                    .foregroundColor(isOwnMessage ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isOwnMessage ? AppColors.mint : Color(hex: "E5E7EB"))
                    .cornerRadius(16)
            }
            
            if isOwnMessage {
                Spacer().frame(width: 40)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct GroupMembersListView: View {
    let groupChat: GroupChat
    let onBack: () -> Void
    let onAddMember: () -> Void
    let onEditGroupName: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
                
                Text("Group Members")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            
            List {
                ForEach(groupChat.members) { member in
                    HStack {
                        if let avatar = member.avatar, let url = URL(string: avatar) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(member.name ?? member.username ?? "User")
                                .font(.system(size: 16, weight: .semibold))
                            
                            if member.id == groupChat.createdBy {
                                Text("Group Creator")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}
