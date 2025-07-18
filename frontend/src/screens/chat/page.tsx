import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  RefreshControl,
  Alert,
  Image,
} from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import ChatsTopNavBar from './components/Chats';
import BottomNavBar from '../../components/BottomNavBar';
import AppText from '../../components/AppText';
import { COLORS } from '../../theme/colors';
import { supabase } from '../../../lib/supabase';

const StyledView = styled(View);
const StyledTextInput = styled(TextInput);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

interface Chat {
  id: string;
  name: string;
  avatar: string | null;
  lastMessage: string;
  lastMessageTime: string;
  unreadCount: number;
  isOnline: boolean;
  isGroup: boolean;
  conversationId: string;
}

interface Message {
  id: string;
  text: string;
  senderId: string;
  senderName: string;
  timestamp: string;
  isRead: boolean;
}

export default function ChatsScreen({ route, navigation }: { route: any; navigation: any }) {
  const currentUser = route?.params?.currentUser;
  const [searchQuery, setSearchQuery] = useState('');
  const [chats, setChats] = useState<Chat[]>([]);
  const [filteredChats, setFilteredChats] = useState<Chat[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    fetchChats();
  }, []);

  // Fetch all conversations where current user is a member and there is at least one message
  const fetchChats = async (isRefresh = false) => {
    if (isRefresh) {
      setRefreshing(true);
    } else {
      setLoading(true);
    }
    try {
      // 1. Get all conversation_ids where currentUser is a member
      const { data: memberRows, error: memberError } = await supabase
        .from('conversation_members')
        .select('conversation_id')
        .eq('user_id', currentUser.id);
      if (memberError) throw memberError;
      const conversationIds = (memberRows || []).map((row: any) => row.conversation_id);
      if (!conversationIds.length) {
        setChats([]);
        setFilteredChats([]);
        setLoading(false);
        setRefreshing(false);
        return;
      }
      // 2. For each conversation, get the last message and the other user
      const chatData = await Promise.all(conversationIds.map(async (cid: string) => {
        // Get last message
        const { data: lastMsg, error: lastMsgError } = await supabase
          .from('messages')
          .select('*')
          .eq('conversation_id', cid)
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle();
        if (!lastMsg) return null;
        // Get all members for this conversation
        const { data: members, error: membersError } = await supabase
          .from('conversation_members')
          .select('user_id')
          .eq('conversation_id', cid);
        if (membersError) throw membersError;
        // Find the other user (not currentUser)
        const otherUserId = (members || []).find((m: any) => m.user_id !== currentUser.id)?.user_id;
        if (!otherUserId) return null;
        // Get other user's info
        const { data: user, error: userError } = await supabase
          .from('profiles')
          .select('id, username, full_name, profile_picture')
          .eq('id', otherUserId)
          .maybeSingle();
        if (userError || !user) return null;
        return {
          id: user.id,
          name: user.full_name || user.username,
          avatar: user.profile_picture || null,
          lastMessage: lastMsg.message,
          lastMessageTime: lastMsg.created_at ? new Date(lastMsg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '',
          unreadCount: 0, // TODO: implement unread count
          isOnline: false, // TODO: implement online status
          isGroup: false,
          conversationId: cid,
        };
      }));
      setChats(chatData.filter((c): c is Chat => c !== null));
    } catch (error) {
      console.error('Error fetching chats:', error);
      Alert.alert('Error', 'Failed to load chats. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    if (!searchQuery.trim()) {
      setFilteredChats(chats);
      return;
    }
    const filtered = chats.filter(chat =>
      chat.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      chat.lastMessage.toLowerCase().includes(searchQuery.toLowerCase())
    );
    setFilteredChats(filtered);
  }, [searchQuery, chats]);

  const onRefresh = () => {
    fetchChats(true);
  };

  const handleChatPress = (chat: Chat) => {
    navigation.navigate('ChatRoomScreen', {
      currentUser,
      otherUser: {
        id: chat.id,
        name: chat.name,
        avatar: chat.avatar,
      },
      conversationId: chat.conversationId,
    });
  };

  const handleNewChat = () => {
    Alert.alert(
      'New Chat',
      'Start a new conversation?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Start', onPress: () => console.log('Starting new chat') }
      ]
    );
  };

  const formatTime = (time: string) => {
    if (time === 'Yesterday') return time;
    return time;
  };

  const renderChatItem = ({ item }: { item: Chat }) => (
    <StyledTouchableOpacity
      onPress={() => handleChatPress(item)}
      className="bg-white mx-4 mb-2 rounded-2xl overflow-hidden"
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 2,
      }}
    >
      <StyledView className="flex-row items-center p-4">
        {/* Avatar */}
        <StyledView className="relative">
          {item.avatar ? (
            <StyledImage
              source={{ uri: item.avatar }}
              className="w-14 h-14 rounded-full"
            />
          ) : (
            <StyledView className="w-14 h-14 rounded-full bg-gray-200 items-center justify-center">
              <Icon name="person" size={24} color="#9CA3AF" />
            </StyledView>
          )}
          
          {/* Online indicator */}
          {item.isOnline && (
            <StyledView className="absolute bottom-0 right-0 w-4 h-4 bg-green-500 rounded-full border-2 border-white" />
          )}
          
          {/* Group indicator */}
          {item.isGroup && (
            <StyledView className="absolute top-0 right-0 w-4 h-4 bg-mint rounded-full border-2 border-white items-center justify-center">
              <AppText className="text-white text-xs">G</AppText>
            </StyledView>
          )}
        </StyledView>

        {/* Chat Info */}
        <StyledView className="flex-1 ml-4">
          <StyledView className="flex-row justify-between items-start mb-1">
            <AppText className="text-lg text-gray-900 flex-1">
              {item.name}
            </AppText>
            <AppText className="text-sm text-gray-500 ml-2">
              {formatTime(item.lastMessageTime)}
            </AppText>
          </StyledView>

          <StyledView className="flex-row justify-between items-center">
            <AppText 
              className="text-gray-600 flex-1 mr-2" 
              numberOfLines={1}
            >
              {item.lastMessage}
            </AppText>
            
            {item.unreadCount > 0 && (
              <StyledView className="bg-mint rounded-full min-w-[20px] h-5 items-center justify-center px-1">
                <AppText className="text-white text-xs">
                  {item.unreadCount > 99 ? '99+' : item.unreadCount}
                </AppText>
              </StyledView>
            )}
          </StyledView>
        </StyledView>
      </StyledView>
    </StyledTouchableOpacity>
  );

  const renderEmptyState = () => (
    <StyledView className="flex-1 justify-center items-center px-8">
      <Icon name="chat-bubble-outline" size={80} color={COLORS.mint} />
      <AppText className="text-xl text-gray-900 mt-4 text-center">
        No chats yet
      </AppText>
      <AppText className="text-gray-600 text-center mt-2 leading-6">
        Start a conversation with friends to discover places together!
      </AppText>
      <StyledTouchableOpacity
        className="bg-mint px-6 py-3 rounded-2xl mt-6"
        onPress={handleNewChat}
      >
        <AppText className="text-white">Start New Chat</AppText>
      </StyledTouchableOpacity>
    </StyledView>
  );

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <ChatsTopNavBar currentUser={currentUser} />

      {/* Search Header */}
      <StyledView className="px-4 pt-4 pb-2">
        <StyledView className="flex-row items-center space-x-3">
          <StyledView className="flex-1 relative">
            <StyledTextInput
              className="bg-white px-4 py-3 rounded-2xl text-gray-900"
              placeholder="Search chats..."
              placeholderTextColor="#9CA3AF"
              value={searchQuery}
              onChangeText={setSearchQuery}
              style={{
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.1,
                shadowRadius: 4,
                elevation: 2,
              }}
            />
            <StyledView className="absolute right-3 top-3">
              <Icon name="search" size={20} color={COLORS.mint} />
            </StyledView>
          </StyledView>

          <StyledTouchableOpacity
            onPress={handleNewChat}
            className="w-12 h-12 bg-mint rounded-2xl items-center justify-center"
            style={{
              shadowColor: '#000',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: 0.1,
              shadowRadius: 4,
              elevation: 2,
            }}
          >
            <Icon name="add" size={24} color="white" />
          </StyledTouchableOpacity>
        </StyledView>
      </StyledView>

      {/* Chats List */}
      {loading ? (
        <StyledView className="flex-1 justify-center items-center">
          <ActivityIndicator size="large" color={COLORS.mint} />
          <AppText className="text-mint mt-4 text-lg">
            Loading conversations...
          </AppText>
        </StyledView>
      ) : (
        <FlatList
          data={filteredChats}
          renderItem={renderChatItem}
          keyExtractor={(item) => item.id}
          showsVerticalScrollIndicator={false}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              tintColor={COLORS.mint}
              colors={[COLORS.mint]}
            />
          }
          ListEmptyComponent={renderEmptyState}
          contentContainerStyle={{ 
            paddingTop: 8,
            paddingBottom: 120,
          }}
        />
      )}

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
