import { useState, useEffect, useRef } from 'react';
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

export function useMessages(conversationId: string, currentUser: any) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);
  const [optimisticMessages, setOptimisticMessages] = useState<Message[]>([]);

  // Fetch messages for this conversation
  const fetchMessages = async () => {
    if (!conversationId) return;
    
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('messages')
        .select('*')
        .eq('conversation_id', conversationId)
        .order('created_at', { ascending: true });
        
      if (error) throw error;
      
      setMessages(data || []);
      setOptimisticMessages([]);
    } catch (err) {
      Alert.alert('Error', 'Failed to load messages.');
    } finally {
      setLoading(false);
    }
  };

  // Real-time subscription
  useEffect(() => {
    if (!conversationId) return;
    
    fetchMessages();
    
    const channel = supabase
      .channel('messages_' + conversationId)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `conversation_id=eq.${conversationId}`,
        },
        (payload) => {
          const newMsg = payload.new as Message;
          if (newMsg.sender_id !== currentUser.id) {
            setMessages((prev) => [...prev, newMsg]);
          }
        }
      )
      .subscribe();
      
    return () => {
      supabase.removeChannel(channel);
    };
  }, [conversationId]);

  return {
    messages,
    setMessages,
    loading,
    optimisticMessages,
    setOptimisticMessages,
    fetchMessages,
  };
} 