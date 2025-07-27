import React, { useEffect } from 'react';
import { View, FlatList, RefreshControl } from 'react-native';
import { styled } from 'nativewind';
import ChatsTopNavBar from './components/NavBar';
import UserSearchItem from './components/UserSearchItem';
import ChatItem from './components/ChatItem';
import EmptyState from './components/EmptyState';
import LoadingState from './components/LoadingState';
import BottomNavBar from '../../components/BottomNavBar';
import { COLORS } from '../../theme/colors';
import { supabase } from '../../../lib/supabase';
import { useUserAuth } from './hooks/useUserAuth';
import { useChatData } from './hooks/useChatData';
import { useChatActions } from './hooks/useChatActions';
import { useSearch } from './hooks/useSearch';

const StyledView = styled(View);

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
  } = useChatData(currentUser);
  const {
    showUserSearch,
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

  // Sync search states between hooks
  useEffect(() => {
    setSearchHookQuery(userSearchQuery);
  }, [userSearchQuery, setSearchHookQuery]);

  // Filter chats when search query changes
  useEffect(() => {
    filterChats(searchQuery);
  }, [searchQuery, filterChats]);

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
      <ChatsTopNavBar 
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
        onNewChat={handleNewChat}
        showUserSearch={showUserSearch}
        userSearchQuery={userSearchQuery}
        setUserSearchQuery={setUserSearchQuery}
        searchingUsers={searchingUsers}
      />
      
      {showUserSearch ? (
        <FlatList
          data={searchResults}
          renderItem={({ item }) => (
            <UserSearchItem item={item} onPress={startNewChat} />
          )}
          keyExtractor={(item) => item.id}
          contentContainerStyle={{ flexGrow: 1 }}
          ListEmptyComponent={() => <EmptyState type="users" />}
          showsVerticalScrollIndicator={false}
        />
      ) : (
        <FlatList
          data={filteredChats}
          renderItem={({ item }) => (
            <ChatItem item={item} onPress={handleChatPress} />
          )}
          keyExtractor={(item) => item.id}
          contentContainerStyle={{ flexGrow: 1 }}
          ListEmptyComponent={() => <EmptyState type="chats" />}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              colors={[COLORS.mint]}
              tintColor={COLORS.mint}
            />
          }
          showsVerticalScrollIndicator={false}
        />
      )}
      
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
