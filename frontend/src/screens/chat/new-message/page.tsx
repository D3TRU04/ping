import React, { memo, useState } from 'react';
import { View, ScrollView, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import NewMessageNavBar from './components/NavBar';
import SearchInput from './components/SearchInput';
import UserItem from './components/UserItem';
import SuggestedHeader from './components/SuggestedHeader';
import EmptySearchState from './components/EmptySearchState';
import { useUserFiltering } from './hooks/useUserFiltering';
import AppText from '../../../components/AppText';

const StyledView = styled(View);
const StyledScrollView = styled(ScrollView);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

interface NewMessageProps {
  onBack: () => void;
  onUserPress?: (user: User) => void;
  onGroupChatPress?: () => void;
  onStartChat?: (users: User[], isGroup: boolean) => void;
  searchQuery?: string;
  setSearchQuery?: (query: string) => void;
  onSearch?: () => void;
  suggestedUsers?: User[];
  allUsers?: User[];
}

// Main NewMessage component
const NewMessage = memo(({ 
  onBack,
  onUserPress, 
  onGroupChatPress,
  onStartChat,
  searchQuery = '', 
  setSearchQuery,
  onSearch,
  suggestedUsers = [],
  allUsers = []
}: NewMessageProps) => {
  const { filteredUsers, uniqueSuggestedUsers } = useUserFiltering(
    searchQuery,
    suggestedUsers,
    allUsers
  );

  const [selectedUsers, setSelectedUsers] = useState<User[]>([]);

  const handleUserSelect = (user: User) => {
    const isSelected = selectedUsers.some(u => u.id === user.id);
    if (isSelected) {
      setSelectedUsers(prev => prev.filter(u => u.id !== user.id));
    } else {
      setSelectedUsers(prev => [...prev, user]);
    }
  };

  const handleStartChat = () => {
    if (selectedUsers.length === 0) return;
    
    const isGroup = selectedUsers.length > 1;
    onStartChat?.(selectedUsers, isGroup);
  };

  const displayUsers = searchQuery.trim() ? filteredUsers : uniqueSuggestedUsers;

  return (
    <StyledView className="flex-1 bg-white">
      <NewMessageNavBar onBack={onBack} />
      <SearchInput 
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
        onSearch={onSearch}
      />
      
      <StyledScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* Selected Users Summary */}
        {selectedUsers.length > 0 && (
          <StyledView className="px-4 py-3 bg-mint/10 border-b border-gray-100">
            <StyledView className="flex-row items-center justify-between">
              <StyledView className="flex-1">
                <AppText className="text-sm text-gray-600">
                  {selectedUsers.length} {selectedUsers.length === 1 ? 'person' : 'people'} selected
                </AppText>
                <AppText className="text-xs text-gray-500 mt-1">
                  {selectedUsers.length === 1 ? 'Individual chat' : 'Group chat'}
                </AppText>
              </StyledView>
              <StyledTouchableOpacity
                onPress={handleStartChat}
                className="px-4 py-2 bg-mint rounded-lg"
              >
                <AppText className="text-white font-medium">
                  Start Chat
                </AppText>
              </StyledTouchableOpacity>
            </StyledView>
          </StyledView>
        )}
        
        {/* Users List */}
        {displayUsers.length > 0 && onUserPress && (
          <>
            <SuggestedHeader />
            {displayUsers.map((user) => {
              const isSelected = selectedUsers.some(u => u.id === user.id);
              return (
                <TouchableOpacity
                  key={user.id}
                  onPress={() => handleUserSelect(user)}
                  className={`px-4 py-3 border-b border-gray-100 ${
                    isSelected ? 'bg-mint/10' : 'bg-white'
                  }`}
                >
                  <UserItem
                    user={user}
                    isSelected={isSelected}
                  />
                </TouchableOpacity>
              );
            })}
          </>
        )}
        
        {/* Empty state when searching */}
        {searchQuery.trim() && filteredUsers.length === 0 && (
          <EmptySearchState />
        )}
        
        {/* Empty state when not searching */}
        {!searchQuery.trim() && uniqueSuggestedUsers.length === 0 && (
          <EmptySearchState />
        )}
      </StyledScrollView>
    </StyledView>
  );
});

NewMessage.displayName = 'NewMessage';

export default NewMessage; 