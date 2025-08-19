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
  receiver_id: string;
  message: { text: string };
  created_at: string;
  is_read: boolean;
}

interface User {
  id: string;
  name: string;
  avatar: string | null;
}

interface MessageBubbleProps {
  message: Message;
  index: number;
  currentUser: User;
  otherUser: User;
  allMessages: Message[];
}

export default function MessageBubble({ 
  message, 
  index, 
  currentUser, 
  otherUser, 
  allMessages 
}: MessageBubbleProps) {
  const isMe = message.sender_id === currentUser.id;
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
      className={`flex-row items-end mb-2 px-4 ${isMe ? 'justify-end' : 'justify-start'}`}
    >
      <StyledView
        className={`px-3 py-2 max-w-[75%] rounded-3xl shadow-sm ${
          isMe 
            ? '' 
            : 'bg-gray-100'
        } ${message.id.startsWith('temp_') ? 'opacity-70' : 'opacity-100'}`}
        style={{
          backgroundColor: isMe ? COLORS.mint : undefined,
        }}
      >
        <AppText 
          className={`text-base leading-5 ${
            isMe ? 'text-white' : 'text-gray-600'
          }`}
        >
          {messageText}
        </AppText>
        
        <StyledView className="flex-row items-center justify-end mt-1">
          <AppText className={`text-xs mr-1 ${
            isMe ? 'text-white/70' : 'text-gray-400'
          }`}>
            {formatTime(message.created_at)}
          </AppText>
          {isMe && (
            <StyledView className="flex-row items-center">
              <Icon name="done-all" size={12} color="rgba(255,255,255,0.7)" />
            </StyledView>
          )}
        </StyledView>
      </StyledView>
    </StyledView>
  );
} 