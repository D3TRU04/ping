import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../components/AppText';
import { COLORS, SHADOWS } from '../../../../theme/colors';

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

  return (
    <StyledView
      className={`flex-row items-end mb-4 ${isMe ? 'justify-end' : 'justify-start'}`}
      style={{ paddingHorizontal: 20 }}
    >
      <StyledView
        className={`px-4 py-3 rounded-2xl max-w-[75%]`}
        style={{
          backgroundColor: isMe ? COLORS.mint : '#F0FDFA',
          ...SHADOWS.card,
          opacity: message.id.startsWith('temp_') ? 0.7 : 1,
        }}
      >
        <AppText 
          className="text-base leading-5"
          style={{ color: isMe ? 'white' : 'black' }}
        >
          {messageText}
        </AppText>
      </StyledView>
    </StyledView>
  );
} 