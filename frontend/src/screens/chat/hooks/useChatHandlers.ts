import { useCallback } from 'react';

interface UseChatHandlersProps {
  startNewChat: (user: any) => void;
  handleChatPress: (chat: any) => void;
  setShowUserSearch: (show: boolean) => void;
  setUserSearchQuery: (query: string) => void;
  navigation: any;
  currentUser: any;
}

export function useChatHandlers({
  startNewChat,
  handleChatPress,
  setShowUserSearch,
  setUserSearchQuery,
  navigation,
  currentUser,
}: UseChatHandlersProps) {
  const handleStartNewChat = useCallback((user: any) => {
    startNewChat(user);
  }, [startNewChat]);

  const handleStartChat = useCallback((users: any[], isGroup: boolean) => {
    if (isGroup) {
      // Normalize user data structure
      const normalizedUsers = users.map(user => ({
        id: user.id,
        name: user.full_name || user.username || 'Unknown User',
        avatar: user.profile_picture || null,
        full_name: user.full_name,
        username: user.username,
      }));
      
      // Create group chat
      navigation.navigate('CreateGroup', {
        currentUser,
        selectedUsers: normalizedUsers,
      });
    } else {
      // Create individual chat
      startNewChat(users[0]);
    }
  }, [startNewChat, navigation, currentUser]);

  const handleChatItemPress = useCallback((chat: any) => {
    handleChatPress(chat);
  }, [handleChatPress]);

  const handleBackFromNewMessage = useCallback(() => {
    // Close the new message screen and return to messages list
    setShowUserSearch(false);
    setUserSearchQuery('');
  }, [setShowUserSearch, setUserSearchQuery]);

  const handleGroupChatPress = useCallback(() => {
    // Handle group chat creation
  }, []);

  return {
    handleStartNewChat,
    handleStartChat,
    handleChatItemPress,
    handleBackFromNewMessage,
    handleGroupChatPress,
  };
} 