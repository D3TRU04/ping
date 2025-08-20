import React from 'react';
import { View, TouchableOpacity, Image, TextInput } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);
const StyledTextInput = styled(TextInput);

interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

interface EmptyStateProps {
  type: 'chats' | 'users';
  users?: User[];
  onUserPress?: (user: User) => void;
  searchQuery?: string;
  setSearchQuery?: (query: string) => void;
  onSearch?: () => void;
}

export default function EmptyState({ 
  type, 
  users, 
  onUserPress, 
  searchQuery = '', 
  setSearchQuery,
  onSearch 
}: EmptyStateProps) {
  // Search bar component - always visible
  const SearchBar = () => (
    <StyledView className="w-full mb-4">
      <StyledView
        style={{
          backgroundColor: 'white',
          borderRadius: 25,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: 0.1,
          shadowRadius: 8,
          elevation: 4,
          borderWidth: 1,
          borderColor: '#E5E7EB',
        }}
      >
        <StyledView className="flex-row items-center px-4 py-3">
          <Icon name="search" size={20} color="#6B7280" />
          <StyledTextInput
            className="flex-1 ml-3 text-base text-gray-900"
            placeholder="Search for people..."
            placeholderTextColor="#9CA3AF"
            value={searchQuery}
            onChangeText={setSearchQuery}
            onSubmitEditing={onSearch}
            returnKeyType="search"
            style={{
              fontSize: 16,
            }}
          />
          {searchQuery.length > 0 && (
            <StyledTouchableOpacity
              onPress={() => setSearchQuery?.('')}
              className="ml-2"
            >
              <Icon name="close" size={20} color="#6B7280" />
            </StyledTouchableOpacity>
          )}
        </StyledView>
      </StyledView>
    </StyledView>
  );


  // If we have users to display, render them with search bar at top
  if (users && users.length > 0) {
    return (
      <StyledView className="flex-1 px-8">
        {/* Search Bar always at the top */}
        <StyledView className="pt-8 pb-6">
          <SearchBar />
        </StyledView>
        
        {/* User list */}
        <StyledView className="flex-1">
          {users.map((user) => (
            <StyledTouchableOpacity
              key={user.id}
              onPress={() => onUserPress?.(user)}
              className="flex-row items-center p-4 bg-white border-b border-gray-100"
            >
              <StyledImage
                source={{ uri: user.profile_picture || undefined }}
                className="w-12 h-12 rounded-full mr-4 bg-gray-100"
              />
              <StyledView className="flex-1">
                <AppText className="text-base font-semibold text-gray-900">
                  {user.full_name || user.username || 'Unknown User'}
                </AppText>
                <AppText className="text-sm text-gray-500">
                  @{user.username}
                </AppText>
              </StyledView>
              <Icon name="chat-bubble-outline" size={24} color={COLORS.mint} />
            </StyledTouchableOpacity>
          ))}
        </StyledView>
      </StyledView>
    );
  }

  // Otherwise, render empty state
  if (type === 'chats') {
    return (
      <StyledView className="flex-1 px-8">
        {/* Search Bar at the top */}
        <StyledView className="pt-8 pb-6">
          <SearchBar />
        </StyledView>
        
        {/* Empty state content */}
        <StyledView className="flex-1 justify-center items-center">
          <StyledView className="w-20 h-20 bg-mint/10 rounded-full items-center justify-center mb-6">
            <Icon name="chat-bubble-outline" size={32} color={COLORS.mint} />
          </StyledView>
          <AppText className="text-xl font-semibold text-gray-900 mb-2 text-center">
            No conversations yet
          </AppText>
          <AppText className="text-gray-600 text-center leading-6">
            Start a new chat to begin messaging!
          </AppText>
        </StyledView>
      </StyledView>
    );
  }

  return (
    <StyledView className="flex-1 px-8">
      {/* Search Bar at the top */}
      <StyledView className="pt-8 pb-6">
        <SearchBar />
      </StyledView>
      
      {/* Empty state content */}
      <StyledView className="flex-1 justify-center items-center">
        <StyledView className="w-20 h-20 bg-mint/10 rounded-full items-center justify-center mb-6">
          <Icon name="search" size={32} color={COLORS.mint} />
        </StyledView>
        <AppText className="text-xl font-semibold text-gray-900 mb-2 text-center">
          No users found
        </AppText>
        <AppText className="text-gray-600 text-center leading-6">
          Try searching with a different name or username
        </AppText>
      </StyledView>
    </StyledView>
  );
} 