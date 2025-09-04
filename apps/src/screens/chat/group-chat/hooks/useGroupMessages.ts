import { useState, useEffect } from 'react';
import { supabase } from '../../../../../lib/supabase';

interface Message {
  id: string;
  sender_id: string;
  message: { text: string };
  created_at: string;
  is_read: boolean;
  group_id?: string;
}

interface User {
  id: string;
  name: string;
  avatar: string | null;
}

export function useGroupMessages(groupChatId: string, currentUser: User) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [optimisticMessages, setOptimisticMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchMessages = async () => {
    if (!groupChatId) return;

    try {
      const { data, error } = await supabase
        .from('messages')
        .select('*')
        .eq('group_id', groupChatId)
        .order('created_at', { ascending: true });

      if (error) {
        // Handle error silently or show user-friendly message
      }

      setMessages(data || []);
    } catch (error) {
      // console.error('Error fetching group messages:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMessages();

    // Subscribe to real-time updates
    const channel = supabase
      .channel(`group_messages_${groupChatId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `group_id=eq.${groupChatId}`,
        },
        (payload) => {
          const newMessage = payload.new as Message;
          setMessages((prev) => {
            // Check if message already exists to prevent duplicates
            const messageExists = prev.some(msg => msg.id === newMessage.id);
            if (messageExists) {
              return prev;
            }
            return [...prev, newMessage];
          });
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
      // Clear optimistic messages when unmounting
      setOptimisticMessages([]);
    };
  }, [groupChatId]);

  return {
    messages,
    setMessages,
    optimisticMessages,
    setOptimisticMessages,
    loading,
  };
} 