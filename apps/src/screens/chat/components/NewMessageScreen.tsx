import React from 'react';
import NewMessage from '../new-message/page';

interface NewMessageScreenProps {
  onBack: () => void;
  onUserPress: (user: any) => void;
  onGroupChatPress: () => void;
  onStartChat: (users: any[], isGroup: boolean) => void;
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  onSearch: () => void;
  suggestedUsers: any[];
  allUsers: any[];
}

export default function NewMessageScreen({
  onBack,
  onUserPress,
  onGroupChatPress,
  onStartChat,
  searchQuery,
  setSearchQuery,
  onSearch,
  suggestedUsers,
  allUsers,
}: NewMessageScreenProps) {
  return (
    <NewMessage
      onBack={onBack}
      onUserPress={onUserPress}
      onGroupChatPress={onGroupChatPress}
      onStartChat={onStartChat}
      searchQuery={searchQuery}
      setSearchQuery={setSearchQuery}
      onSearch={onSearch}
      suggestedUsers={suggestedUsers}
      allUsers={allUsers}
    />
  );
} 