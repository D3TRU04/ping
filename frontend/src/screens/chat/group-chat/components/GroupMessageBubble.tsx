import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);

interface Message {
  id: string;
  sender_id: string;
  message: { text: string };
  created_at: string;
  is_read: boolean;
}

interface User {
  id: string;
  name: string;
  avatar: string | null;
}

interface GroupMessageBubbleProps {
  message: Message;
  sender: User | undefined;
  isOwnMessage: boolean;
  allMessages: Message[];
}

export default function GroupMessageBubble({ 
  message, 
  sender, 
  isOwnMessage, 
  allMessages 
}: GroupMessageBubbleProps) {
  const messageText = message.message?.text || 'No message content';

  // Format timestamp - only time
  const formatTime = (timestamp: string) => {
    const date = new Date(timestamp);
    return date.toLocaleTimeString('en-US', { 
      hour: 'numeric', 
      minute: '2-digit',
      hour12: true 
    });
  };

  return (
    <StyledView
      className={`flex-row items-end mb-2 px-4 ${isOwnMessage ? 'justify-end' : 'justify-start'}`}
    >
      <StyledView
        className={`px-3 py-2 max-w-[75%] rounded-3xl shadow-sm ${
          isOwnMessage 
            ? '' 
            : 'bg-gray-100'
        } ${message.id.startsWith('temp_') ? 'opacity-70' : 'opacity-100'}`}
        style={{
          backgroundColor: isOwnMessage ? COLORS.mint : undefined,
        }}
      >
        {!isOwnMessage && sender && (
          <AppText className="text-xs text-gray-500 mb-1 font-medium">
            {sender.name}
          </AppText>
        )}
        
        <AppText 
          className={`text-base leading-5 ${
            isOwnMessage ? 'text-white' : 'text-gray-600'
          }`}
        >
          {messageText}
        </AppText>
        
        <StyledView className="flex-row items-center justify-end mt-1">
          <AppText className={`text-xs mr-1 ${
            isOwnMessage ? 'text-white/70' : 'text-gray-400'
          }`}>
            {formatTime(message.created_at)}
          </AppText>
          {isOwnMessage && (
            <StyledView className="flex-row items-center">
              <Icon name="done-all" size={12} color="rgba(255,255,255,0.7)" />
            </StyledView>
          )}
        </StyledView>
      </StyledView>
    </StyledView>
  );
} 