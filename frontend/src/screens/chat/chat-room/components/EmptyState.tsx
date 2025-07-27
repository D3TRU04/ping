import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);

interface EmptyStateProps {
  otherUserName: string;
}

export default function EmptyState({ otherUserName }: EmptyStateProps) {
  return (
    <StyledView className="flex-1 justify-center items-center px-8">
      <StyledView className="w-20 h-20 bg-mint/10 rounded-full items-center justify-center mb-6">
        <Icon name="chat-bubble-outline" size={32} color={COLORS.mint} />
      </StyledView>
      <AppText className="text-xl font-semibold text-gray-900 mb-2 text-center">
        Start a conversation
      </AppText>
      <AppText className="text-gray-600 text-center leading-6">
        Send a message to begin chatting with {otherUserName}!
      </AppText>
    </StyledView>
  );
} 