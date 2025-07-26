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
import ChatsTopNavBar from './components/NavBar';
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

interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

export default function ChatsScreen({ route, navigation }: { route: any; navigation: any }) {
  // Try to get currentUser from route params first, then from Supabase auth
  const routeCurrentUser = route?.params?.currentUser;
  const [currentUser, setCurrentUser] = useState<any>(routeCurrentUser);
  
  // Debug logging
  console.log('ChatsScreen - routeCurrentUser:', routeCurrentUser);
  console.log('ChatsScreen - currentUser state:', currentUser);
  
  const [searchQuery, setSearchQuery] = useState('');
  const [chats, setChats] = useState<Chat[]>([]);
  const [filteredChats, setFilteredChats] = useState<Chat[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showUserSearch, setShowUserSearch] = useState(false);
  const [userSearchQuery, setUserSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<User[]>([]);
  const [searchingUsers, setSearchingUsers] = useState(false);

  // Get currentUser from Supabase auth if not provided via route params
  useEffect(() => {
    const getCurrentUser = async () => {
      if (currentUser?.id) {
        console.log('ChatsScreen - Using currentUser from route params');
        return;
      }

      try {
        console.log('ChatsScreen - Getting currentUser from Supabase auth');
        const { data: { session }, error } = await supabase.auth.getSession();
        
        if (error) {
          console.error('ChatsScreen - Auth error:', error);
          return;
        }

        if (session?.user) {
          // Get user profile from profiles table
          const { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', session.user.id)
            .single();

          if (profileError) {
            console.error('ChatsScreen - Profile error:', profileError);
            return;
          }

          const user = {
            id: session.user.id,
            name: profile.full_name || profile.username || 'User',
            avatar: profile.profile_picture || null,
            hasOnboarded: profile.has_onboarded || false,
          };

          console.log('ChatsScreen - Set currentUser from auth:', user);
          setCurrentUser(user);
        }
      } catch (error) {
        console.error('ChatsScreen - Error getting currentUser:', error);
      }
    };

    getCurrentUser();
  }, []);

  useEffect(() => {
    if (currentUser?.id) {
      console.log('ChatsScreen - Fetching chats for user:', currentUser.id);
      fetchChats();
    } else {
      console.log('ChatsScreen - No currentUser.id found, setting loading to false');
      setLoading(false);
    }
  }, [currentUser]);

  // Fetch all conversations where current user is a member and there is at least one message
  const fetchChats = async (isRefresh = false) => {
    if (!currentUser?.id) {
      console.log('No current user, skipping chat fetch');
      return;
    }

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

  // Search for users to start a new chat
  const searchUsers = async (query: string) => {
    if (!query.trim() || !currentUser?.id) return;
    
    setSearchingUsers(true);
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, username, full_name, profile_picture')
        .neq('id', currentUser.id)
        .or(`username.ilike.%${query}%,full_name.ilike.%${query}%`)
        .limit(10);

      if (error) throw error;
      setSearchResults(data || []);
    } catch (error) {
      console.error('Error searching users:', error);
      Alert.alert('Error', 'Failed to search users. Please try again.');
    } finally {
      setSearchingUsers(false);
    }
  };

  // Create a new conversation with a user
  const startNewChat = async (otherUser: User) => {
    if (!currentUser?.id) {
      console.error('startNewChat: No currentUser.id');
      Alert.alert('Error', 'User not authenticated. Please sign in again.');
      return;
    }

    console.log('startNewChat: Starting new chat with user:', otherUser);
    console.log('startNewChat: currentUser:', currentUser);

    try {
      // Check if conversation already exists
      console.log('startNewChat: Checking for existing conversations...');
      const { data: existingMembers, error: memberError } = await supabase
        .from('conversation_members')
        .select('conversation_id')
        .eq('user_id', currentUser.id);

      if (memberError) {
        console.error('startNewChat: Error fetching existing members:', memberError);
        throw memberError;
      }

      console.log('startNewChat: Found existing members:', existingMembers);

      // Check if there's already a conversation with this user
      for (const member of existingMembers || []) {
        console.log('startNewChat: Checking conversation:', member.conversation_id);
        const { data: otherMembers, error: otherError } = await supabase
          .from('conversation_members')
          .select('user_id')
          .eq('conversation_id', member.conversation_id);

        if (otherError) {
          console.error('startNewChat: Error fetching other members:', otherError);
          continue;
        }

        console.log('startNewChat: Other members in conversation:', otherMembers);

        if (otherMembers?.some(m => m.user_id === otherUser.id)) {
          console.log('startNewChat: Found existing conversation, navigating to it');
          // Conversation already exists, navigate to it
          navigation.navigate('ChatRoomScreen', {
            currentUser,
            otherUser: {
              id: otherUser.id,
              name: otherUser.full_name || otherUser.username,
              avatar: otherUser.profile_picture,
            },
            conversationId: member.conversation_id,
          });
          setShowUserSearch(false);
          setUserSearchQuery('');
          setSearchResults([]);
          return;
        }
      }

      // Create new conversation
      console.log('startNewChat: Creating new conversation...');
      const { data: conversation, error: convError } = await supabase
        .from('conversations')
        .insert([{ created_by: currentUser.id }])
        .select()
        .single();

      if (convError) {
        console.error('startNewChat: Error creating conversation:', convError);
        throw convError;
      }

      console.log('startNewChat: Created conversation:', conversation);

      // Add both users to conversation
      console.log('startNewChat: Adding users to conversation...');
      const { error: memberInsertError } = await supabase
        .from('conversation_members')
        .insert([
          { conversation_id: conversation.id, user_id: currentUser.id },
          { conversation_id: conversation.id, user_id: otherUser.id }
        ]);

      if (memberInsertError) {
        console.error('startNewChat: Error adding members to conversation:', memberInsertError);
        throw memberInsertError;
      }

      console.log('startNewChat: Successfully added members to conversation');

      // Navigate to new chat
      console.log('startNewChat: Navigating to ChatRoomScreen');
      navigation.navigate('ChatRoomScreen', {
        currentUser,
        otherUser: {
          id: otherUser.id,
          name: otherUser.full_name || otherUser.username,
          avatar: otherUser.profile_picture,
        },
        conversationId: conversation.id,
      });

      setShowUserSearch(false);
      setUserSearchQuery('');
      setSearchResults([]);
    } catch (error: any) {
      console.error('startNewChat: Detailed error:', error);
      console.error('startNewChat: Error message:', error.message);
      console.error('startNewChat: Error details:', error.details);
      console.error('startNewChat: Error hint:', error.hint);
      
      let errorMessage = 'Failed to start new chat. Please try again.';
      
      if (error.message) {
        if (error.message.includes('permission denied')) {
          errorMessage = 'Permission denied. Please check your database setup.';
        } else if (error.message.includes('relation') && error.message.includes('does not exist')) {
          errorMessage = 'Database tables not set up. Please run the SQL setup script.';
        } else if (error.message.includes('foreign key')) {
          errorMessage = 'Invalid user reference. Please try again.';
        }
      }
      
      Alert.alert('Error', errorMessage);
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

  // Debounced user search
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      if (userSearchQuery.trim()) {
        searchUsers(userSearchQuery);
      } else {
        setSearchResults([]);
      }
    }, 300);

    return () => clearTimeout(timeoutId);
  }, [userSearchQuery]);

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
    setShowUserSearch(true);
  };

  const formatTime = (time: string) => {
    if (time === 'Yesterday') return time;
    return time;
  };

  const renderUserSearchItem = ({ item }: { item: User }) => (
    <StyledTouchableOpacity
      onPress={() => startNewChat(item)}
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
          {item.profile_picture ? (
            <StyledImage
              source={{ uri: item.profile_picture }}
              className="w-14 h-14 rounded-full"
            />
          ) : (
            <StyledView className="w-14 h-14 rounded-full bg-gray-200 items-center justify-center">
              <Icon name="person" size={24} color="#9CA3AF" />
            </StyledView>
          )}
        </StyledView>

        {/* User Info */}
        <StyledView className="flex-1 ml-4">
          <AppText className="text-lg text-gray-900">
            {item.full_name || item.username}
          </AppText>
          {item.full_name && (
            <AppText className="text-sm text-gray-500">
              @{item.username}
            </AppText>
          )}
        </StyledView>

        <Icon name="chat-bubble-outline" size={20} color={COLORS.mint} />
      </StyledView>
    </StyledTouchableOpacity>
  );

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

  const renderUserSearchEmptyState = () => (
    <StyledView className="flex-1 justify-center items-center px-8">
      <Icon name="search" size={80} color={COLORS.mint} />
      <AppText className="text-xl text-gray-900 mt-4 text-center">
        Search for users
      </AppText>
      <AppText className="text-gray-600 text-center mt-2 leading-6">
        Type a username or full name to find someone to chat with!
      </AppText>
    </StyledView>
  );

  if (!currentUser?.id) {
    return (
      <StyledView className="flex-1 bg-[#FAF6F2] justify-center items-center">
        <AppText className="text-lg text-gray-600 mb-4">Loading user information...</AppText>
        <AppText className="text-sm text-gray-500 text-center px-4 mb-2">
          Debug: routeCurrentUser = {JSON.stringify(routeCurrentUser)}
        </AppText>
        <AppText className="text-sm text-gray-500 text-center px-4">
          Debug: currentUser state = {JSON.stringify(currentUser)}
        </AppText>
      </StyledView>
    );
  }

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <ChatsTopNavBar currentUser={currentUser} />

      {/* Search Header */}
      <StyledView className="px-4 pt-4 pb-2">
        <StyledView className="flex-row items-center space-x-3">
          <StyledView className="flex-1 relative">
            <StyledTextInput
              className="bg-white px-4 py-3 rounded-2xl text-gray-900"
              placeholder={showUserSearch ? "Search users..." : "Search chats..."}
              placeholderTextColor="#9CA3AF"
              value={showUserSearch ? userSearchQuery : searchQuery}
              onChangeText={showUserSearch ? setUserSearchQuery : setSearchQuery}
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
            onPress={showUserSearch ? () => {
              setShowUserSearch(false);
              setUserSearchQuery('');
              setSearchResults([]);
            } : handleNewChat}
            className="w-12 h-12 bg-mint rounded-2xl items-center justify-center"
            style={{
              shadowColor: '#000',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: 0.1,
              shadowRadius: 4,
              elevation: 2,
            }}
          >
            <Icon name={showUserSearch ? "close" : "add"} size={24} color="white" />
          </StyledTouchableOpacity>
        </StyledView>
      </StyledView>

      {/* User Search or Chats List */}
      {showUserSearch ? (
        searchingUsers ? (
          <StyledView className="flex-1 justify-center items-center">
            <ActivityIndicator size="large" color={COLORS.mint} />
            <AppText className="text-mint mt-4 text-lg">
              Searching users...
            </AppText>
          </StyledView>
        ) : (
          <FlatList
            data={searchResults}
            renderItem={renderUserSearchItem}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
            ListEmptyComponent={renderUserSearchEmptyState}
            contentContainerStyle={{ 
              paddingTop: 8,
              paddingBottom: 120,
            }}
          />
        )
      ) : (
        <>
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
        </>
      )}

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
