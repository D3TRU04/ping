import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';

const StyledView = styled(View);

interface EmptyStateProps {
  type: 'chats' | 'users';
}

export default function EmptyState({ type }: EmptyStateProps) {
  if (type === 'chats') {
    return (
      <StyledView className="flex-1 justify-center items-center px-8">
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
    );
  }

  return (
    <StyledView className="flex-1 justify-center items-center px-8">
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
  );
} 