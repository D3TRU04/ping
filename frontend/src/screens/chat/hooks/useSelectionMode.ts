import { useState, useCallback } from 'react';
import { Alert } from 'react-native';
import { supabase } from '../../../../lib/supabase';

interface UseSelectionModeProps {
  fetchChats: () => Promise<void>;
  visibleChats: any[];
}

export function useSelectionMode({ fetchChats, visibleChats }: UseSelectionModeProps) {
  const [isSelectionMode, setIsSelectionMode] = useState(false);
  const [selectedChats, setSelectedChats] = useState<Set<string>>(new Set());
  const [mutedChats, setMutedChats] = useState<Set<string>>(new Set());

  const handleToggleSelectionMode = useCallback(() => {
    setIsSelectionMode(true);
    setSelectedChats(new Set());
  }, []);

  const handleCancelSelection = useCallback(() => {
    setIsSelectionMode(false);
    setSelectedChats(new Set());
  }, []);

  const handleChatSelect = useCallback((chat: any) => {
    setSelectedChats(prev => {
      const newSet = new Set(prev);
      if (newSet.has(chat.id)) {
        newSet.delete(chat.id);
      } else {
        newSet.add(chat.id);
      }
      return newSet;
    });
  }, []);

  const handleDeleteSelected = useCallback(() => {
    Alert.alert(
      'Delete Conversations',
      `Are you sure you want to delete ${selectedChats.size} conversation${selectedChats.size === 1 ? '' : 's'}?`,
      [
        {
          text: 'Cancel',
          style: 'cancel',
        },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              // Get the selected chat objects to determine if they're individual or group chats
              const selectedChatObjects = visibleChats.filter(chat => selectedChats.has(chat.id));
              
              // Separate individual and group chats
              const individualChats = selectedChatObjects.filter(chat => !chat.isGroup);
              const groupChats = selectedChatObjects.filter(chat => chat.isGroup);
              
              // Delete messages for individual conversations
              for (const chat of individualChats) {
                if (chat.conversationId) {
                  const { error: deleteError } = await supabase
                    .from('messages')
                    .delete()
                    .eq('conversation_id', chat.conversationId);
                  
                  if (deleteError) {
                    throw new Error(`Failed to delete conversation: ${chat.name}`);
                  }
                }
              }
              
              // Delete messages for group chats
              for (const chat of groupChats) {
                if (chat.groupChatId) {
                  const { error: deleteError } = await supabase
                    .from('messages')
                    .delete()
                    .eq('group_chat_id', chat.groupChatId);
                  
                  if (deleteError) {
                    throw new Error(`Failed to delete group chat: ${chat.name}`);
                  }
                }
              }
              
              // Clear selection and exit selection mode
              setIsSelectionMode(false);
              setSelectedChats(new Set());
              
              // Add a small delay to ensure database operations complete
              await new Promise(resolve => setTimeout(resolve, 200));
              
              // Force refresh chats to update the UI immediately
              await fetchChats();
              
              // Show success message
              Alert.alert(
                'Success', 
                `Successfully deleted ${selectedChats.size} conversation${selectedChats.size === 1 ? '' : 's'}.`
              );
              
            } catch (error: unknown) {
              const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
              Alert.alert('Error', `Failed to delete conversations: ${errorMessage}`);
            }
          },
        },
      ]
    );
  }, [selectedChats, visibleChats, fetchChats]);

  const handleMuteSelected = useCallback(() => {
    Alert.alert(
      'Mute Conversations',
      `Are you sure you want to mute ${selectedChats.size} conversation${selectedChats.size === 1 ? '' : 's'}?`,
      [
        {
          text: 'Cancel',
          style: 'cancel',
        },
        {
          text: 'Mute',
          onPress: async () => {
            try {
              // Add selected chats to muted set
              setMutedChats(prev => {
                const newSet = new Set(prev);
                selectedChats.forEach(chatId => newSet.add(chatId));
                return newSet;
              });
              
              // Clear selection and exit selection mode
              setIsSelectionMode(false);
              setSelectedChats(new Set());
              
              // Show success message
              Alert.alert(
                'Success', 
                `Successfully muted ${selectedChats.size} conversation${selectedChats.size === 1 ? '' : 's'}.`
              );
              
            } catch (error: unknown) {
              Alert.alert('Error', 'Failed to mute conversations.');
            }
          },
        },
      ]
    );
  }, [selectedChats]);

  return {
    isSelectionMode,
    selectedChats,
    mutedChats,
    handleToggleSelectionMode,
    handleCancelSelection,
    handleChatSelect,
    handleDeleteSelected,
    handleMuteSelected,
  };
} 