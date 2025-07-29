import React, { useEffect, useCallback, memo } from 'react';
import { View, FlatList, RefreshControl } from 'react-native';
import { styled } from 'nativewind';
import { useFocusEffect } from '@react-navigation/native';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import ChatsTopNavBar from './components/NavBar';
import ChatItem from './components/ChatItem';
import NewMessage from './new-message/page';
import LoadingState from './components/LoadingState';
import BottomNavBar from '../../components/BottomNavBar';
import { COLORS } from '../../theme/colors';
import { supabase } from '../../../lib/supabase';
import { useUserAuth } from './hooks/useUserAuth';
import { useChatData } from './hooks/useChatData';
import { useChatActions } from './hooks/useChatActions';
import { useSearch } from './hooks/useSearch';
import AppText from '../../components/AppText';

const StyledView = styled(View);

// Memoized ChatItem renderer to prevent unnecessary re-renders
const MemoizedChatItem = memo(({ item, onPress }: { item: any; onPress: (chat: any) => void }) => (
  <ChatItem item={item} onPress={onPress} />
));

MemoizedChatItem.displayName = 'MemoizedChatItem';

export default function ChatsScreen({ route, navigation }: { route: any; navigation: any }) {
  // Custom hooks for different concerns
  const { currentUser } = useUserAuth(route?.params?.currentUser);
  const {
    filteredChats,
    loading,
    refreshing,
    searchResults,
    searchingUsers,
    searchUsers,
    filterChats,
    onRefresh,
    fetchChats,
  } = useChatData(currentUser);
  const {
    showUserSearch,
    setShowUserSearch,
    userSearchQuery,
    setUserSearchQuery,
    startNewChat,
    handleChatPress,
    handleNewChat,
  } = useChatActions(currentUser, navigation);
  const {
    searchQuery,
    setSearchQuery,
    userSearchQuery: searchHookQuery,
    setUserSearchQuery: setSearchHookQuery,
  } = useSearch(searchUsers);

  // Create suggested users list (different from search results)
  const suggestedUsers = searchResults.slice(0, 5); // Only show first 5 as suggestions

  // Sync search states between hooks
  useEffect(() => {
    setSearchHookQuery(userSearchQuery);
  }, [userSearchQuery, setSearchHookQuery]);

  // Filter chats when search query changes
  useEffect(() => {
    filterChats(searchQuery);
  }, [searchQuery, filterChats]);

  // Refresh chats when screen comes into focus - with proper dependency management
  const handleFocusRefresh = useCallback(() => {
    if (currentUser?.id) {
      fetchChats();
    }
  }, [currentUser?.id]); // Remove fetchChats from dependencies

  useFocusEffect(
    React.useCallback(() => {
      handleFocusRefresh();
    }, [handleFocusRefresh])
  );

  // Memoized search handlers
  const handleUserSearch = useCallback(() => {
    searchUsers(userSearchQuery);
  }, [searchUsers, userSearchQuery]);

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

  // Test database setup on component mount
  useEffect(() => {
    const testDatabaseSetup = async () => {
      try {
        const { data: test1 } = await supabase.from('messages').select('id').limit(1);
        const testMessage = {
          sender_id: currentUser?.id || 'test',
          receiver_id: 'test',
          conversation_id: 'test',
          message: { text: 'test' },
          created_at: new Date().toISOString(),
          is_read: false,
        };
        const { data: insertResult } = await supabase.from('messages').insert(testMessage).select();
        if (insertResult && insertResult.length > 0) {
          await supabase.from('messages').delete().eq('id', insertResult[0].id);
        }
        const { data: policyTest } = await supabase.from('messages').select('id').limit(1);
      } catch (error) {
        // Handle error silently
      }
    };
    testDatabaseSetup();
  }, []);

  // Loading state
  if (!currentUser?.id) {
    return (
      <StyledView className="flex-1 bg-white">
        <ChatsTopNavBar 
          searchQuery={searchQuery}
          setSearchQuery={setSearchQuery}
          onNewChat={handleNewChat}
          showUserSearch={showUserSearch}
          userSearchQuery={userSearchQuery}
          setUserSearchQuery={setUserSearchQuery}
          searchingUsers={searchingUsers}
        />
        <LoadingState />
        <BottomNavBar currentUser={currentUser} />
      </StyledView>
    );
  }

  return (
    <StyledView className="flex-1 bg-white">
      {!showUserSearch && (
        <ChatsTopNavBar 
          searchQuery={searchQuery}
          setSearchQuery={setSearchQuery}
          onNewChat={handleNewChat}
          showUserSearch={showUserSearch}
          userSearchQuery={userSearchQuery}
          setUserSearchQuery={setUserSearchQuery}
          searchingUsers={searchingUsers}
        />
      )}
      
      {showUserSearch ? (
        <NewMessage
          onBack={handleBackFromNewMessage}
          onUserPress={handleStartNewChat}
          onGroupChatPress={handleGroupChatPress}
          onStartChat={handleStartChat}
          searchQuery={userSearchQuery}
          setSearchQuery={setUserSearchQuery}
          onSearch={handleUserSearch}
          suggestedUsers={suggestedUsers}
          allUsers={searchResults}
        />
      ) : (
        <FlatList
          data={filteredChats}
          renderItem={({ item }) => (
            <MemoizedChatItem item={item} onPress={handleChatItemPress} />
          )}
          keyExtractor={(item) => item.id}
          contentContainerStyle={{ flexGrow: 1 }}
          ListEmptyComponent={() => (
            <StyledView className="flex-1 justify-center items-center px-8 py-12">
              <StyledView className="w-16 h-16 bg-mint/10 rounded-full items-center justify-center mb-4">
                <Icon name="chat-bubble-outline" size={24} color={COLORS.mint} />
              </StyledView>
              <AppText className="text-lg font-semibold text-gray-900 mb-2 text-center">
                No conversations yet
              </AppText>
              <AppText className="text-gray-600 text-center leading-5 text-sm">
                Start a new chat to begin messaging!
              </AppText>
            </StyledView>
          )}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              colors={[COLORS.mint]}
              tintColor={COLORS.mint}
            />
          }
          showsVerticalScrollIndicator={false}
          removeClippedSubviews={true}
          maxToRenderPerBatch={10}
          windowSize={10}
        />
      )}
      
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
