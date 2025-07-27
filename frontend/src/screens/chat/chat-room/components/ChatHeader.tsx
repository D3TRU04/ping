import React from 'react';
import { View, TouchableOpacity, Image } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

interface User {
  id: string;
  name: string;
  avatar: string | null;
}

interface ChatHeaderProps {
  otherUser: User;
  messageCount: number;
  onBackPress: () => void;
  onProfilePress: () => void;
}

export default function ChatHeader({ 
  otherUser, 
  messageCount, 
  onBackPress, 
  onProfilePress 
}: ChatHeaderProps) {
  return (
    <StyledView 
      className="flex-row items-center px-4 py-3 bg-white"
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
        elevation: 10,
        borderBottomColor: 'rgba(31,201,195,0.12)',
        borderBottomWidth: 1,
      }}
    >
      <StyledTouchableOpacity 
        onPress={onBackPress} 
        className="mr-3 p-2"
      >
        <Icon name="arrow-back" size={24} color={COLORS.mint} />
      </StyledTouchableOpacity>
      
      <StyledTouchableOpacity 
        onPress={onProfilePress}
        className="flex-row items-center flex-1"
      >
        <StyledImage
          source={{ uri: otherUser.avatar || undefined }}
          className="w-10 h-10 rounded-full mr-3"
          style={{ 
            backgroundColor: '#F5F6FA',
            borderWidth: 2,
            borderColor: '#FFFFFF'
          }}
        />
        
        <StyledView className="flex-1">
          <AppText className="text-lg font-semibold text-gray-900">
            {otherUser.name}
          </AppText>
          {/* <AppText className="text-sm text-gray-500">
            {messageCount > 0 ? `${messageCount} messages` : 'No messages yet'}
          </AppText> */}
        </StyledView>
        
        <Icon name="chevron-right" size={20} color="#9CA3AF" />
      </StyledTouchableOpacity>
    </StyledView>
  );
} 