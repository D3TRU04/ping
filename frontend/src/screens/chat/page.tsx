import React, { useEffect } from 'react';
import { useUserAuth } from './hooks/useUserAuth';
import { useChatData } from './hooks/useChatData';
import { useChatActionsOriginal } from './hooks/useChatActionsOriginal';
import { useSearch } from './hooks/useSearch';
import { useSelectionMode } from './hooks/useSelectionMode';
import { useSearchState } from './hooks/useSearchState';
import { useChatHandlers } from './hooks/useChatHandlers';
import { useDatabaseTest } from './hooks/useDatabaseTest';
import { useFocusRefresh } from './hooks/useFocusRefresh';
import LoadingScreen from './components/LoadingScreen';
import MainContent from './components/MainContent';

export default function ChatsScreen({ route, navigation }: { route: any; navigation: any }) {
  // Core data hooks
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
  } = useChatActionsOriginal(currentUser, navigation);
  const {
    searchQuery,
    setSearchQuery,
    userSearchQuery: searchHookQuery,
    setUserSearchQuery: setSearchHookQuery,
  } = useSearch(searchUsers);

  // Selection mode hook
  const {
    isSelectionMode,
    selectedChats,
    mutedChats,
    handleToggleSelectionMode,
    handleCancelSelection,
    handleChatSelect,
    handleDeleteSelected,
    handleMuteSelected,
  } = useSelectionMode({ fetchChats, visibleChats: filteredChats });

  // Filter out muted chats from the display
  const visibleChats = filteredChats.filter(chat => !mutedChats.has(chat.id));

  // Search state hook
  const { suggestedUsers, handleUserSearch } = useSearchState({
    searchResults,
    userSearchQuery,
    setUserSearchQuery,
    searchUsers,
    setSearchHookQuery,
  });

  // Chat handlers hook
  const {
    handleStartNewChat,
    handleStartChat,
    handleChatItemPress,
    handleBackFromNewMessage,
    handleGroupChatPress,
  } = useChatHandlers({
    startNewChat,
    handleChatPress,
    setShowUserSearch,
    setUserSearchQuery,
    navigation,
    currentUser,
  });

  // Database test hook
  useDatabaseTest({ currentUser });

  // Focus refresh hook
  useFocusRefresh({ currentUser, fetchChats });

  // Filter chats when search query changes
  useEffect(() => {
    filterChats(searchQuery);
  }, [searchQuery, filterChats]);

  // Loading state
  if (!currentUser?.id) {
    return (
      <LoadingScreen
        currentUser={currentUser}
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
        onNewChat={handleNewChat}
        showUserSearch={showUserSearch}
        userSearchQuery={userSearchQuery}
        setUserSearchQuery={setUserSearchQuery}
        searchingUsers={searchingUsers}
        isSelectionMode={isSelectionMode}
        selectedCount={selectedChats.size}
        onToggleSelectionMode={handleToggleSelectionMode}
        onCancelSelection={handleCancelSelection}
        onDeleteSelected={handleDeleteSelected}
        onMuteSelected={handleMuteSelected}
      />
    );
  }

  return (
    <MainContent
      currentUser={currentUser}
      showUserSearch={showUserSearch}
      searchQuery={searchQuery}
      setSearchQuery={setSearchQuery}
      onNewChat={handleNewChat}
      userSearchQuery={userSearchQuery}
      setUserSearchQuery={setUserSearchQuery}
      searchingUsers={searchingUsers}
      isSelectionMode={isSelectionMode}
      selectedChats={selectedChats}
      onToggleSelectionMode={handleToggleSelectionMode}
      onCancelSelection={handleCancelSelection}
      onDeleteSelected={handleDeleteSelected}
      onMuteSelected={handleMuteSelected}
      onBackFromNewMessage={handleBackFromNewMessage}
      onUserPress={handleStartNewChat}
      onGroupChatPress={handleGroupChatPress}
      onStartChat={handleStartChat}
      onSearch={handleUserSearch}
      suggestedUsers={suggestedUsers}
      allUsers={searchResults}
      visibleChats={visibleChats}
      onChatPress={handleChatItemPress}
      onChatSelect={handleChatSelect}
      refreshing={refreshing}
      onRefresh={onRefresh}
    />
  );
}
