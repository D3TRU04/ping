import { useState, useEffect } from 'react';
import { Alert } from 'react-native';
import { supabase } from '../../../../../lib/supabase';

interface Message {
  id: string;
  sender_id: string;
  receiver_id: string;
  message: { text: string };
  created_at: string;
  is_read: boolean;
}

interface User {
  id: string;
  name: string;
  avatar: string | null;
}

export function useMessageActions(
  conversationId: string,
  currentUser: User,
  otherUser: User,
  setMessages: (messages: any) => void,
  setOptimisticMessages: (messages: any) => void
) {
  const [input, setInput] = useState('');
  const [sending, setSending] = useState(false);

  // Send message
  const sendMessage = async () => {
    if (!input.trim() || !conversationId || sending) return;
    
    const messageText = input.trim();
    setInput('');
    setSending(true);
    
    // Create optimistic message
    const optimisticMessage: Message = {
      id: `temp_${Date.now()}`,
      sender_id: currentUser.id,
      receiver_id: otherUser.id,
      message: { text: messageText },
      created_at: new Date().toISOString(),
      is_read: false,
    };
    
    setOptimisticMessages((prev: Message[]) => [...prev, optimisticMessage]);
    
    try {
      const { data, error } = await supabase.from('messages').insert({
        sender_id: currentUser.id,
        receiver_id: otherUser.id,
        message: { text: messageText },
        conversation_id: conversationId,
        created_at: new Date().toISOString(),
        is_read: false,
      }).select();
      
      if (error) throw error;
      
      setOptimisticMessages((prev: Message[]) => prev.filter((msg: Message) => msg.id !== optimisticMessage.id));
      if (data && data.length > 0) {
        setMessages((prev: Message[]) => [...prev, data[0]]);
      }
      
    } catch (err) {
      setOptimisticMessages((prev: Message[]) => prev.filter((msg: Message) => msg.id !== optimisticMessage.id));
      Alert.alert('Error', 'Failed to send message. Please try again.');
      setInput(messageText);
    } finally {
      setSending(false);
    }
  };

  return {
    input,
    setInput,
    sending,
    sendMessage,
  };
} 