import { useCallback } from 'react';

interface UseChatActionsProps {
  startNewChat: (user: any) => void;
  navigation: any;
  currentUser: any;
}

export function useChatActions({
  startNewChat,
  navigation,
  currentUser,
}: UseChatActionsProps) {
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
    // This will be handled by the chat actions hook
    // We'll pass this through from the main component
  }, []);

  const handleBackFromNewMessage = useCallback(() => {
    // This will be handled by the main component
    // We'll pass this through from the main component
  }, []);

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