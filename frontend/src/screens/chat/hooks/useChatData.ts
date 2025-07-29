import { useState, useEffect, useCallback } from 'react';
import { Alert } from 'react-native';
import { supabase } from '../../../../lib/supabase';

interface Chat {
  id: string;
  name: string;
  avatar: string | null;
  lastMessage: string;
  lastMessageTime: string;
  unreadCount: number;
  isOnline: boolean;
  isGroup: boolean;
  conversationId?: string;
  groupChatId?: string;
}

interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

export function useChatData(currentUser: any) {
  const [chats, setChats] = useState<Chat[]>([]);
  const [filteredChats, setFilteredChats] = useState<Chat[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchResults, setSearchResults] = useState<User[]>([]);
  const [searchingUsers, setSearchingUsers] = useState(false);

  // Fetch chats with useCallback to prevent infinite loops
  const fetchChats = useCallback(async (isRefresh = false) => {
    if (!currentUser?.id) {
      setLoading(false);
      return;
    }
    
    if (!isRefresh) {
      setLoading(true);
    }
    
    try {
      // Get the latest message for each conversation where the current user is involved
      const { data: latestMessages, error } = await supabase
        .from('messages')
        .select(`
          *,
          sender:sender_id(id, username, full_name, profile_picture),
          receiver:receiver_id(id, username, full_name, profile_picture)
        `)
        .or(`sender_id.eq.${currentUser.id},receiver_id.eq.${currentUser.id}`)
        .order('created_at', { ascending: false });
        
      if (error) throw error;
      
      // Get group chats where the current user is a member
      const { data: groupChats, error: groupError } = await supabase
        .from('group_chats')
        .select(`
          *,
          group_members!inner(user_id)
        `)
        .eq('group_members.user_id', currentUser.id);
        
      if (groupError) throw groupError;
      
      // Get latest messages for each group chat
      const groupChatIds = groupChats?.map(gc => gc.id) || [];
      const { data: groupMessages, error: groupMessagesError } = await supabase
        .from('messages')
        .select(`
          *,
          sender:sender_id(id, username, full_name, profile_picture)
        `)
        .in('group_chat_id', groupChatIds)
        .order('created_at', { ascending: false });
        
      if (groupMessagesError) throw groupMessagesError;
      
      // Group messages by conversation_id and get the latest one for each
      const chatMap = new Map<string, any>();
      
      latestMessages?.forEach((message) => {
        const conversationId = message.conversation_id;
        
        // If we haven't seen this conversation yet, or if this message is newer
        if (!chatMap.has(conversationId) || 
            new Date(message.created_at) > new Date(chatMap.get(conversationId).created_at)) {
          chatMap.set(conversationId, message);
        }
      });
      
      // Group group messages by group_chat_id and get the latest one for each
      const groupChatMap = new Map<string, any>();
      
      groupMessages?.forEach((message) => {
        const groupChatId = message.group_chat_id;
        
        // If we haven't seen this group chat yet, or if this message is newer
        if (!groupChatMap.has(groupChatId) || 
            new Date(message.created_at) > new Date(groupChatMap.get(groupChatId).created_at)) {
          groupChatMap.set(groupChatId, message);
        }
      });
      
      // Transform individual chats to Chat interface
      const individualChats: Chat[] = Array.from(chatMap.values()).map((message) => {
        const otherUserId = message.sender_id === currentUser.id ? message.receiver_id : message.sender_id;
        const otherUser = message.sender_id === currentUser.id ? message.receiver : message.sender;
        
        const chat = {
          id: message.conversation_id,
          name: otherUser?.full_name || otherUser?.username || 'Unknown User',
          avatar: otherUser?.profile_picture || null,
          lastMessage: message.message?.text || 'No message content',
          lastMessageTime: message.created_at,
          unreadCount: 0, // TODO: Implement unread count
          isOnline: false, // TODO: Implement online status
          isGroup: false,
          conversationId: message.conversation_id,
        };
        
        return chat;
      });
      
      // Transform group chats to Chat interface
      const groupChatsList: Chat[] = Array.from(groupChatMap.values()).map((message) => {
        const groupChat = groupChats?.find(gc => gc.id === message.group_chat_id);
        
        const chat = {
          id: message.group_chat_id,
          name: groupChat?.name || 'Group Chat',
          avatar: null, // Group chats don't have avatars
          lastMessage: message.message?.text || 'No message content',
          lastMessageTime: message.created_at,
          unreadCount: 0, // TODO: Implement unread count
          isOnline: false, // TODO: Implement online status
          isGroup: true,
          groupChatId: message.group_chat_id,
        };
        
        return chat;
      });
      
      // Combine individual and group chats
      const allChats = [...individualChats, ...groupChatsList];
      
      // Sort by latest message time
      allChats.sort((a, b) => new Date(b.lastMessageTime).getTime() - new Date(a.lastMessageTime).getTime());
      
      setChats(allChats);
      setFilteredChats(allChats);
      
    } catch (error) {
      Alert.alert('Error', 'Failed to load chats.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, [currentUser?.id]);

  // Real-time subscription for new messages
  useEffect(() => {
    if (!currentUser?.id) return;

    const channel = supabase
      .channel('chat_list_updates')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `receiver_id=eq.${currentUser.id}`,
        },
        (payload) => {
          // Only refresh when receiving messages, not when sending
          // Add a small delay to prevent rapid re-fetching
          setTimeout(() => {
            fetchChats();
          }, 100);
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `sender_id=eq.${currentUser.id}`,
        },
        (payload) => {
          // Also refresh when sending messages to update the chat list
          // Add a small delay to prevent rapid re-fetching
          setTimeout(() => {
            fetchChats();
          }, 100);
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `group_chat_id=not.is.null`,
        },
        (payload) => {
          // Refresh when group messages are sent
          // Add a small delay to prevent rapid re-fetching
          setTimeout(() => {
            fetchChats();
          }, 100);
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [currentUser?.id]); // Remove fetchChats from dependencies to prevent infinite loop

  // Search users
  const searchUsers = async (query: string) => {
    if (!query.trim()) {
      setSearchResults([]);
      return;
    }
    
    setSearchingUsers(true);
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, username, full_name, profile_picture')
        .or(`username.ilike.%${query}%,full_name.ilike.%${query}%`)
        .neq('id', currentUser.id)
        .limit(10);
        
      if (error) throw error;
      
      setSearchResults(data || []);
    } catch (error) {
      Alert.alert('Error', 'Failed to search users.');
    } finally {
      setSearchingUsers(false);
    }
  };

  // Filter chats based on search
  const filterChats = (searchQuery: string) => {
    if (!searchQuery.trim()) {
      setFilteredChats(chats);
    } else {
      const filtered = chats.filter(chat =>
        chat.name.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredChats(filtered);
    }
  };

  // Refresh chats
  const onRefresh = () => {
    setRefreshing(true);
    fetchChats(true);
  };

  // Initial load
  useEffect(() => {
    fetchChats();
  }, [fetchChats]);

  return {
    chats,
    filteredChats,
    loading,
    refreshing,
    searchResults,
    searchingUsers,
    fetchChats,
    searchUsers,
    filterChats,
    onRefresh,
  };
} 