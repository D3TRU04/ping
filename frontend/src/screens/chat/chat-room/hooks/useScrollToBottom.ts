import { useEffect, useRef } from 'react';
import { FlatList } from 'react-native';

interface Message {
  id: string;
  sender_id: string;
  receiver_id: string;
  message: { text: string };
  created_at: string;
  is_read: boolean;
}

export function useScrollToBottom(messages: Message[], optimisticMessages: Message[]) {
  const flatListRef = useRef<FlatList>(null);

  // Scroll to bottom on new message
  useEffect(() => {
    const allMessages = [...messages, ...optimisticMessages];
    if (allMessages.length > 0) {
      setTimeout(() => {
        flatListRef.current?.scrollToEnd({ animated: true });
      }, 100);
    }
  }, [messages, optimisticMessages]);

  return flatListRef;
} 