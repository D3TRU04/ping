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
  const handleChatPress = async (chat: any) => {
    if (chat.isGroup) {
      try {
        // Fetch the group chat data from the database
        const { data: groupChat, error: groupError } = await supabase
          .from('group_chats')
          .select('*')
          .eq('id', chat.groupChatId)
          .single();

        if (groupError) {
          console.error('Error fetching group chat:', groupError);
          Alert.alert('Error', 'Failed to load group chat.');
          return;
        }

        if (!groupChat) {
          Alert.alert('Error', 'Group chat not found.');
          return;
        }

        // Fetch group members
        const { data: memberIds, error: memberIdsError } = await supabase
          .from('group_members')
          .select('user_id')
          .eq('group_chat_id', chat.groupChatId);

        if (memberIdsError) {
          console.error('Error fetching group members:', memberIdsError);
          Alert.alert('Error', 'Failed to load group members.');
          return;
        }

        // Fetch profiles separately
        const userIds = memberIds?.map(m => m.user_id) || [];
        const { data: profiles, error: profilesError } = await supabase
          .from('profiles')
          .select('id, username, full_name, profile_picture')
          .in('id', userIds);

        if (profilesError) {
          console.error('Error fetching profiles:', profilesError);
          Alert.alert('Error', 'Failed to load group members.');
          return;
        }

        // Transform members data
        const transformedMembers = profiles?.map(profile => ({
          id: profile.id,
          name: profile.full_name || profile.username || 'Unknown User',
          avatar: profile.profile_picture,
        })) || [];

        // Navigate to group chat with proper data
        navigation.navigate('GroupChatScreen', {
          currentUser: currentUser,
          groupChat: {
            id: groupChat.id,
            name: groupChat.name,
            created_by: groupChat.created_by,
            created_at: groupChat.created_at,
            updated_at: groupChat.updated_at,
            members: transformedMembers,
          },
        });
      } catch (error) {
        console.error('Error in handleChatPress for group:', error);
        Alert.alert('Error', 'Failed to load group chat.');
      }
    } else {
      // Navigate to individual chat
      navigation.navigate('ChatRoomScreen', {
        currentUser: currentUser,
        otherUser: {
          id: chat.id.split('_').find((id: string) => id !== currentUser.id) || '',
          name: chat.name,
          avatar: chat.avatar,
        },
        conversationId: chat.conversationId,
      });
    }
  };

  // Handle new chat toggle
  const handleNewChat = () => {
    setShowUserSearch(!showUserSearch);
  };

  // Handle group chat creation
  const handleGroupChatPress = () => {
    // Navigate to group chat creation screen
    navigation.navigate('CreateGroup', {
      currentUser,
      selectedUsers: [], // Will be populated by the create group screen
    });
  };

  return {
    showUserSearch,
    setShowUserSearch,
    userSearchQuery,
    setUserSearchQuery,
    startNewChat,
    handleChatPress,
    handleNewChat,
    handleGroupChatPress,
  };
} 