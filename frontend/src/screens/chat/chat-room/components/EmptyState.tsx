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
      <StyledView 
        className="w-24 h-24 rounded-full items-center justify-center mb-8"
        style={{
          backgroundColor: '#F8F9FA',
          borderWidth: 2,
          borderColor: '#F0F0F0',
        }}
      >
        <Icon name="chat-bubble-outline" size={36} color="#6B7280" />
      </StyledView>
      <AppText className="text-xl font-semibold text-gray-900 mb-3 text-center">
        Start a conversation
      </AppText>
      <AppText className="text-gray-500 text-center leading-6 text-base">
        Send a message to begin chatting with {otherUserName}!
      </AppText>
    </StyledView>
  );
} 