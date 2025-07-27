import { useState, useEffect } from 'react';
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
  conversationId: string;
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

  // Fetch chats
  const fetchChats = async (isRefresh = false) => {
    if (!currentUser?.id) {
      setLoading(false);
      return;
    }
    
    if (!isRefresh) {
      setLoading(true);
    }
    
    try {
      const { data: messages, error } = await supabase
        .from('messages')
        .select(`
          *,
          sender:sender_id(id, username, full_name, profile_picture),
          receiver:receiver_id(id, username, full_name, profile_picture)
        `)
        .or(`sender_id.eq.${currentUser.id},receiver_id.eq.${currentUser.id}`)
        .order('created_at', { ascending: false });
        
      if (error) throw error;
      
      // Group messages by conversation_id and transform to Chat interface
      const chatMap = new Map<string, Chat>();
      
      messages?.forEach((message) => {
        const conversationId = message.conversation_id;
        const otherUserId = message.sender_id === currentUser.id ? message.receiver_id : message.sender_id;
        const otherUser = message.sender_id === currentUser.id ? message.receiver : message.sender;
        
        if (!chatMap.has(conversationId)) {
          chatMap.set(conversationId, {
            id: conversationId,
            name: otherUser?.full_name || otherUser?.username || 'Unknown User',
            avatar: otherUser?.profile_picture || null,
            lastMessage: message.message?.text || 'No message content',
            lastMessageTime: message.created_at,
            unreadCount: 0, // TODO: Implement unread count
            isOnline: false, // TODO: Implement online status
            isGroup: false,
            conversationId: conversationId,
          });
        }
      });
      
      const chatList = Array.from(chatMap.values());
      setChats(chatList);
      setFilteredChats(chatList);
      
    } catch (error) {
      Alert.alert('Error', 'Failed to load chats.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

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
  }, [currentUser]);

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