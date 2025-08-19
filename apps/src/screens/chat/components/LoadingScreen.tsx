import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import ChatsTopNavBar from './NavBar';
import LoadingState from './LoadingState';
import BottomNavBar from '../../../components/BottomNavBar';

const StyledView = styled(View);

interface LoadingScreenProps {
  currentUser: any;
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  onNewChat: () => void;
  showUserSearch: boolean;
  userSearchQuery: string;
  setUserSearchQuery: (query: string) => void;
  searchingUsers: boolean;
  isSelectionMode: boolean;
  selectedCount: number;
  onToggleSelectionMode: () => void;
  onCancelSelection: () => void;
  onDeleteSelected: () => void;
  onMuteSelected: () => void;
}

export default function LoadingScreen({
  currentUser,
  searchQuery,
  setSearchQuery,
  onNewChat,
  showUserSearch,
  userSearchQuery,
  setUserSearchQuery,
  searchingUsers,
  isSelectionMode,
  selectedCount,
  onToggleSelectionMode,
  onCancelSelection,
  onDeleteSelected,
  onMuteSelected,
}: LoadingScreenProps) {
  return (
    <StyledView className="flex-1 bg-white">
      <ChatsTopNavBar 
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
        onNewChat={onNewChat}
        showUserSearch={showUserSearch}
        userSearchQuery={userSearchQuery}
        setUserSearchQuery={setUserSearchQuery}
        searchingUsers={searchingUsers}
        isSelectionMode={isSelectionMode}
        selectedCount={selectedCount}
        onToggleSelectionMode={onToggleSelectionMode}
        onCancelSelection={onCancelSelection}
        onDeleteSelected={onDeleteSelected}
        onMuteSelected={onMuteSelected}
      />
      <LoadingState />
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
} 