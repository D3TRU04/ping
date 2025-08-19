import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import ChatsTopNavBar from './NavBar';
import ChatList from './ChatList';
import NewMessageScreen from './NewMessageScreen';
import BottomNavBar from '../../../components/BottomNavBar';

const StyledView = styled(View);

interface MainContentProps {
  currentUser: any;
  showUserSearch: boolean;
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  onNewChat: () => void;
  userSearchQuery: string;
  setUserSearchQuery: (query: string) => void;
  searchingUsers: boolean;
  isSelectionMode: boolean;
  selectedChats: Set<string>;
  onToggleSelectionMode: () => void;
  onCancelSelection: () => void;
  onDeleteSelected: () => void;
  onMuteSelected: () => void;
  onBackFromNewMessage: () => void;
  onUserPress: (user: any) => void;
  onGroupChatPress: () => void;
  onStartChat: (users: any[], isGroup: boolean) => void;
  onSearch: () => void;
  suggestedUsers: any[];
  allUsers: any[];
  visibleChats: any[];
  onChatPress: (chat: any) => void;
  onChatSelect: (chat: any) => void;
  refreshing: boolean;
  onRefresh: () => void;
}

export default function MainContent({
  currentUser,
  showUserSearch,
  searchQuery,
  setSearchQuery,
  onNewChat,
  userSearchQuery,
  setUserSearchQuery,
  searchingUsers,
  isSelectionMode,
  selectedChats,
  onToggleSelectionMode,
  onCancelSelection,
  onDeleteSelected,
  onMuteSelected,
  onBackFromNewMessage,
  onUserPress,
  onGroupChatPress,
  onStartChat,
  onSearch,
  suggestedUsers,
  allUsers,
  visibleChats,
  onChatPress,
  onChatSelect,
  refreshing,
  onRefresh,
}: MainContentProps) {
  return (
    <StyledView className="flex-1 bg-white">
      {!showUserSearch && (
        <ChatsTopNavBar 
          searchQuery={searchQuery}
          setSearchQuery={setSearchQuery}
          onNewChat={onNewChat}
          showUserSearch={showUserSearch}
          userSearchQuery={userSearchQuery}
          setUserSearchQuery={setUserSearchQuery}
          searchingUsers={searchingUsers}
          isSelectionMode={isSelectionMode}
          selectedCount={selectedChats.size}
          onToggleSelectionMode={onToggleSelectionMode}
          onCancelSelection={onCancelSelection}
          onDeleteSelected={onDeleteSelected}
          onMuteSelected={onMuteSelected}
        />
      )}
      
      {showUserSearch ? (
        <NewMessageScreen
          onBack={onBackFromNewMessage}
          onUserPress={onUserPress}
          onGroupChatPress={onGroupChatPress}
          onStartChat={onStartChat}
          searchQuery={userSearchQuery}
          setSearchQuery={setUserSearchQuery}
          onSearch={onSearch}
          suggestedUsers={suggestedUsers}
          allUsers={allUsers}
        />
      ) : (
        <ChatList
          data={visibleChats}
          onChatPress={onChatPress}
          isSelectionMode={isSelectionMode}
          selectedChats={selectedChats}
          onChatSelect={onChatSelect}
          refreshing={refreshing}
          onRefresh={onRefresh}
        />
      )}
      
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
} 