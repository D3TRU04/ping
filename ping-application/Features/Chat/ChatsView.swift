//
//  ChatsView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/chat/page.tsx
//  Complete Chats list screen with search, selection mode, and new message
//

import SwiftUI
import Combine

struct ChatsView: View {
    @StateObject private var viewModel = ChatsViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var showNewMessage: Bool = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if showNewMessage {
                NewMessageView(
                    onBack: { showNewMessage = false },
                    onUserPress: { user in
                        showNewMessage = false
                        // Navigate to chat room
                    },
                    onGroupChatPress: {
                        // Navigate to create group
                    },
                    onStartChat: { users, isGroup in
                        showNewMessage = false
                        if isGroup {
                            // Navigate to create group
                        } else {
                            // Start individual chat
                        }
                    }
                )
            } else {
                VStack(spacing: 0) {
                    // Top Nav Bar
                    ChatsTopNavBar(
                        searchQuery: $viewModel.searchQuery,
                        onNewChat: { showNewMessage = true },
                        isSelectionMode: viewModel.isSelectionMode,
                        selectedCount: viewModel.selectedChats.count,
                        onToggleSelectionMode: { viewModel.toggleSelectionMode() },
                        onCancelSelection: { viewModel.cancelSelection() },
                        onDeleteSelected: {
                            Task {
                                await viewModel.deleteSelected()
                            }
                        },
                        onMuteSelected: {
                            Task {
                                await viewModel.muteSelected()
                            }
                        }
                    )
                    
                    // Chat List
                    if viewModel.loading {
                        VStack {
                            Spacer()
                            ProgressView()
                            Text("Loading chats...")
                                .foregroundColor(AppColors.mint)
                                .padding(.top, 8)
                            Spacer()
                        }
                    } else if viewModel.filteredChats.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "message")
                                .font(.system(size: 64))
                                .foregroundColor(AppColors.mint)
                            
                            Text("No chats yet")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text("Start a conversation by tapping the + button")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(viewModel.filteredChats) { chat in
                                ChatRow(
                                    chat: chat,
                                    isSelected: viewModel.selectedChats.contains(chat.id),
                                    isSelectionMode: viewModel.isSelectionMode,
                                    onTap: {
                                        if viewModel.isSelectionMode {
                                            viewModel.toggleChatSelection(chat.id)
                                        } else {
                                            // Navigate to chat room
                                        }
                                    },
                                    onSelect: {
                                        viewModel.toggleChatSelection(chat.id)
                                    }
                                )
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            await viewModel.refresh(appEnvironment: appEnvironment)
                        }
                    }

                    // Bottom Nav Bar
                    VStack {
                        Spacer()
                        BottomNavBar(
                            selectedTab: .constant(.chats),
                            currentUser: appEnvironment.currentUser
                        )
                    }
                }
            }
        }
        .task {
            await viewModel.load(
                userId: appEnvironment.currentUser?.id ?? "",
                appEnvironment: appEnvironment
            )
        }
    }
}

struct ChatsTopNavBar: View {
    @Binding var searchQuery: String
    let onNewChat: () -> Void
    let isSelectionMode: Bool
    let selectedCount: Int
    let onToggleSelectionMode: () -> Void
    let onCancelSelection: () -> Void
    let onDeleteSelected: () -> Void
    let onMuteSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if isSelectionMode {
                    Button(action: onCancelSelection) {
                        Text("Cancel")
                            .foregroundColor(AppColors.mint)
                    }
                    
                    Text("\(selectedCount) selected")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    Button(action: onMuteSelected) {
                        Image(systemName: "bell.slash")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: onDeleteSelected) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                } else {
                    Text("Chats")
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    
                    Button(action: onToggleSelectionMode) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: onNewChat) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(AppColors.mint)
                    }
                }
            }
            .padding()
            
            if !isSelectionMode {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search chats", text: $searchQuery)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(hex: "F5F6FA"))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .background(Color.white)
    }
}

struct ChatRow: View {
    let chat: ChatListItem
    let isSelected: Bool
    let isSelectionMode: Bool
    let onTap: () -> Void
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if isSelectionMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? AppColors.mint : .gray)
                }
                
                // Avatar
                if let avatarUrl = chat.avatarUrl, let url = URL(string: avatarUrl) {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chat.name ?? "Chat")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if let lastMessage = chat.lastMessage {
                        Text(lastMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let timestamp = chat.lastMessageTime {
                        Text(formatTime(timestamp))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.mint)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "E6F7F5") : Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

@MainActor
class ChatsViewModel: ObservableObject {
    @Published var chats: [ChatListItem] = []
    @Published var filteredChats: [ChatListItem] = []
    @Published var searchQuery: String = ""
    @Published var loading: Bool = false
    @Published var isSelectionMode: Bool = false
    @Published var selectedChats: Set<String> = []
    @Published var mutedChats: Set<String> = []
    
    func load(userId: String, appEnvironment: AppEnvironment) async {
        loading = true

        do {
            // Load DM conversations
            let dmChats = try await appEnvironment.chatService.fetchChats(userId: userId)

            // Load groups
            let groups = try await appEnvironment.chatService.fetchUserGroups(userId: userId)

            // Convert to ChatListItem format
            let dmChatItems = dmChats.map { chat in
                ChatListItem(
                    id: chat.id,
                    name: chat.name,
                    avatarUrl: nil, // TODO: Get avatar from otherUser
                    lastMessage: chat.latestMessage,
                    lastMessageTime: chat.updatedAt,
                    unreadCount: chat.unreadCount,
                    isGroup: false
                )
            }

            let groupChatItems = groups.map { group in
                ChatListItem(
                    id: group.id,
                    name: group.name,
                    avatarUrl: nil,
                    lastMessage: group.latestMessage,
                    lastMessageTime: group.updatedAt,
                    unreadCount: group.unreadCount,
                    isGroup: true
                )
            }

            // Combine and sort by most recent
            chats = (dmChatItems + groupChatItems).sorted { (a, b) in
                guard let aTime = a.lastMessageTime, let bTime = b.lastMessageTime else {
                    return a.lastMessageTime != nil
                }
                return aTime > bTime
            }

            filterChats()
        } catch {
            // Handle error
            print("Error loading chats: \(error)")
        }

        loading = false
    }

    func refresh(appEnvironment: AppEnvironment) async {
        guard let userId = appEnvironment.currentUser?.id else { return }
        await load(userId: userId, appEnvironment: appEnvironment)
    }
    
    func toggleSelectionMode() {
        isSelectionMode.toggle()
        if !isSelectionMode {
            selectedChats.removeAll()
        }
    }
    
    func cancelSelection() {
        isSelectionMode = false
        selectedChats.removeAll()
    }
    
    func toggleChatSelection(_ chatId: String) {
        if selectedChats.contains(chatId) {
            selectedChats.remove(chatId)
        } else {
            selectedChats.insert(chatId)
        }
    }
    
    func deleteSelected() async {
        // TODO: Delete selected chats from Supabase
        for chatId in selectedChats {
            chats.removeAll { $0.id == chatId }
        }
        selectedChats.removeAll()
        isSelectionMode = false
        filterChats()
    }
    
    func muteSelected() async {
        // TODO: Mute selected chats in Supabase
        for chatId in selectedChats {
            mutedChats.insert(chatId)
        }
        selectedChats.removeAll()
        isSelectionMode = false
    }
    
    private func filterChats() {
        if searchQuery.isEmpty {
            filteredChats = chats.filter { !mutedChats.contains($0.id) }
        } else {
            filteredChats = chats.filter { chat in
                !mutedChats.contains(chat.id) &&
                (chat.name?.localizedCaseInsensitiveContains(searchQuery) ?? false)
            }
        }
    }
    
    init() {
        // Observe search query changes
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterChats()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

struct ChatListItem: Identifiable {
    let id: String
    let name: String?
    let avatarUrl: String?
    let lastMessage: String?
    let lastMessageTime: Date?
    let unreadCount: Int
    let isGroup: Bool
}
