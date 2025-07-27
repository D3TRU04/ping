import { useState, useEffect } from 'react';
import { Alert } from 'react-native';
import { supabase } from '../../../../lib/supabase';

interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

export function useChatActions(currentUser: any, navigation: any) {
  const [showUserSearch, setShowUserSearch] = useState(false);
  const [userSearchQuery, setUserSearchQuery] = useState('');

  // Start new chat
  const startNewChat = async (otherUser: User) => {
    if (!currentUser?.id || !otherUser?.id) {
      Alert.alert('Error', 'User information not available.');
      return;
    }

    try {
      // Check session
      const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      
      if (sessionError) {
        Alert.alert('Error', 'Authentication error. Please sign in again.');
        return;
      }

      if (!session?.user) {
        Alert.alert('Error', 'No active session. Please sign in.');
        return;
      }

      if (session.user.id !== currentUser.id) {
        Alert.alert('Error', 'Session mismatch. Please sign in again.');
        return;
      }

      // Create conversation ID
      const userIds = [currentUser.id, otherUser.id].sort();
      const conversationId = `${userIds[0]}_${userIds[1]}`;

      // Test database connection
      const { data: testQuery, error: testError } = await supabase
        .from('messages')
        .select('id')
        .limit(1);
      
      if (testError) {
        Alert.alert('Error', 'Database connection failed. Please try again.');
        return;
      }

      // Check for existing messages
      const { data: existingMessages, error: messagesError } = await supabase
        .from('messages')
        .select('*')
        .eq('conversation_id', conversationId)
        .limit(1);
      
      if (messagesError) {
        Alert.alert('Error', 'Failed to check existing messages.');
        return;
      }

      // Navigate to chat room
      navigation.navigate('ChatRoomScreen', {
        currentUser: currentUser,
        otherUser: {
          id: otherUser.id,
          name: otherUser.full_name || otherUser.username || 'Unknown User',
          avatar: otherUser.profile_picture || null,
        },
        conversationId: conversationId,
      });
      
    } catch (error) {
      Alert.alert('Error', 'Failed to start new chat. Please try again.');
    }
  };

  // Handle chat press
  const handleChatPress = (chat: any) => {
    navigation.navigate('ChatRoomScreen', {
      currentUser: currentUser,
      otherUser: {
        id: chat.id.split('_').find((id: string) => id !== currentUser.id) || '',
        name: chat.name,
        avatar: chat.avatar,
      },
      conversationId: chat.conversationId,
    });
  };

  // Handle new chat toggle
  const handleNewChat = () => {
    setShowUserSearch(!showUserSearch);
    setUserSearchQuery('');
  };

  return {
    showUserSearch,
    userSearchQuery,
    setUserSearchQuery,
    startNewChat,
    handleChatPress,
    handleNewChat,
  };
} 