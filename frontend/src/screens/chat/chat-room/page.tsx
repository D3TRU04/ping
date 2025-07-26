import React, { useEffect, useState, useRef } from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  FlatList,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  Image,
  Alert,
} from 'react-native';
import { styled } from 'nativewind';
import { supabase } from '../../../lib/supabase';
import AppText from '../../components/AppText';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useNavigation, useRoute } from '@react-navigation/native';
import { COLORS } from '../../theme/colors';

const StyledView = styled(View);
const StyledTextInput = styled(TextInput);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

interface Message {
  id: string;
  sender_id: string;
  receiver_id: string;
  message: string;
  created_at: string;
}

interface User {
  id: string;
  name: string;
  avatar: string | null;
}

export default function ChatRoomScreen() {
  const navigation = useNavigation();
  const route = useRoute<any>();
  const { currentUser, otherUser, conversationId: initialConversationId } = route.params;

  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [conversationId, setConversationId] = useState<string | null>(initialConversationId || null);
  const flatListRef = useRef<FlatList>(null);

  // Ensure conversation exists (for 1:1 chat)
  useEffect(() => {
    const ensureConversation = async () => {
      if (conversationId) return;
      // 1. Check if a 1:1 conversation exists between these two users
      const { data: convs, error: convError } = await supabase
        .from('conversation_members')
        .select('conversation_id')
        .in('user_id', [currentUser.id, otherUser.id]);
      if (convError) return;
      // Find a conversation where both users are members and only 2 members
      const convCounts: Record<string, number> = {};
      (convs || []).forEach((row: any) => {
        convCounts[row.conversation_id] = (convCounts[row.conversation_id] || 0) + 1;
      });
      const existingConvId = Object.entries(convCounts).find(([_, count]) => count === 2)?.[0];
      if (existingConvId) {
        setConversationId(existingConvId);
        return;
      }
      // 2. If not, create a new conversation and add both users
      const { data: newConv, error: newConvError } = await supabase
        .from('conversations')
        .insert({ is_group: false })
        .select()
        .maybeSingle();
      if (newConvError || !newConv) return;
      await supabase.from('conversation_members').insert([
        { conversation_id: newConv.id, user_id: currentUser.id },
        { conversation_id: newConv.id, user_id: otherUser.id },
      ]);
      setConversationId(newConv.id);
    };
    ensureConversation();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentUser.id, otherUser.id]);

  // Fetch messages for this conversation
  const fetchMessages = async (convId: string) => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('messages')
        .select('*')
        .eq('conversation_id', convId)
        .order('created_at', { ascending: true });
      if (error) throw error;
      setMessages(data || []);
    } catch (err) {
      Alert.alert('Error', 'Failed to load messages.');
    } finally {
      setLoading(false);
    }
  };

  // Real-time subscription
  useEffect(() => {
    if (!conversationId) return;
    fetchMessages(conversationId);
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
          setMessages((prev) => [...prev, newMsg]);
        }
      )
      .subscribe();
    return () => {
      supabase.removeChannel(channel);
    };
  }, [conversationId]);

  // Scroll to bottom on new message
  useEffect(() => {
    if (messages.length > 0) {
      flatListRef.current?.scrollToEnd({ animated: true });
    }
  }, [messages]);

  // Send message
  const sendMessage = async () => {
    if (!input.trim() || !conversationId) return;
    setSending(true);
    try {
      const { error } = await supabase.from('messages').insert({
        sender_id: currentUser.id,
        receiver_id: otherUser.id,
        message: input.trim(),
        conversation_id: conversationId,
      });
      if (error) throw error;
      setInput('');
    } catch (err) {
      Alert.alert('Error', 'Failed to send message.');
    } finally {
      setSending(false);
    }
  };

  // Render message bubble
  const renderMessage = ({ item }: { item: Message }) => {
    const isMe = item.sender_id === currentUser.id;
    return (
      <StyledView
        className={`flex-row items-end mb-2 ${isMe ? 'justify-end' : 'justify-start'}`}
        style={{ paddingHorizontal: 12 }}
      >
        {!isMe && (
          <StyledImage
            source={{ uri: otherUser.avatar || undefined }}
            className="w-8 h-8 rounded-full mr-2"
            style={{ backgroundColor: '#eee' }}
          />
        )}
        <StyledView
          className={`px-4 py-2 rounded-2xl max-w-[70%] ${isMe ? 'bg-mint ml-8' : 'bg-white mr-8 border border-gray-200'}`}
        >
          <AppText className={`text-base ${isMe ? 'text-white' : 'text-gray-900'}`}>{item.message}</AppText>
          <AppText className="text-xs text-gray-400 mt-1 text-right">
            {new Date(item.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </AppText>
        </StyledView>
        {isMe && (
          <StyledImage
            source={{ uri: currentUser.avatar || undefined }}
            className="w-8 h-8 rounded-full ml-2"
            style={{ backgroundColor: '#eee' }}
          />
        )}
      </StyledView>
    );
  };

  return (
    <KeyboardAvoidingView
      className="flex-1 bg-[#FAF6F2]"
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={80}
    >
      {/* Header */}
      <StyledView className="flex-row items-center px-4 py-3 bg-white border-b border-gray-100">
        <StyledTouchableOpacity onPress={() => navigation.goBack()} className="mr-3">
          <Icon name="arrow-back" size={24} color={COLORS.mint} />
        </StyledTouchableOpacity>
        <StyledImage
          source={{ uri: otherUser.avatar || undefined }}
          className="w-10 h-10 rounded-full mr-3"
          style={{ backgroundColor: '#eee' }}
        />
        <AppText className="text-lg font-semibold text-gray-900 flex-1">{otherUser.name}</AppText>
        {/* TODO: Typing indicator, online status */}
      </StyledView>

      {/* Messages */}
      {loading ? (
        <StyledView className="flex-1 justify-center items-center">
          <ActivityIndicator size="large" color={COLORS.mint} />
        </StyledView>
      ) : (
        <FlatList
          ref={flatListRef}
          data={messages}
          renderItem={renderMessage}
          keyExtractor={(item) => item.id}
          contentContainerStyle={{ paddingVertical: 16 }}
          showsVerticalScrollIndicator={false}
        />
      )}

      {/* Input */}
      <StyledView className="flex-row items-center px-4 py-3 bg-white border-t border-gray-100">
        <StyledTextInput
          className="flex-1 bg-gray-100 rounded-2xl px-4 py-2 text-base text-gray-900"
          placeholder="Type a message..."
          placeholderTextColor="#9CA3AF"
          value={input}
          onChangeText={setInput}
          editable={!sending}
          onSubmitEditing={sendMessage}
          returnKeyType="send"
        />
        <StyledTouchableOpacity
          onPress={sendMessage}
          className="ml-2 bg-mint rounded-2xl p-2"
          disabled={sending || !input.trim()}
        >
          <Icon name="send" size={22} color="white" />
        </StyledTouchableOpacity>
      </StyledView>
    </KeyboardAvoidingView>
  );
}

// TODO: Add typing indicator, read receipts, and error boundary for better UX. 