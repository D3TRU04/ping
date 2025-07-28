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
      className="flex-row items-center px-4 py-3 bg-white shadow-sm border-b border-gray-100"
    >
      <StyledTouchableOpacity 
        onPress={onBackPress} 
        className="mr-3 p-1"
      >
        <Icon name="arrow-back" size={24} color="#1FC9C3" />
      </StyledTouchableOpacity>
      
      <StyledTouchableOpacity 
        onPress={onProfilePress}
        className="flex-row items-center flex-1"
      >
        <StyledImage
          source={{ uri: otherUser.avatar || undefined }}
          className="w-10 h-10 rounded-full mr-3 bg-gray-100 border-2 border-white"
        />
        
        <StyledView className="flex-1">
          <AppText className="text-base font-semibold text-gray-900">
            {otherUser.name}
          </AppText>
          {/* <AppText className="text-xs text-gray-500">
            last seen yesterday at 9:17 PM
          </AppText> */}
        </StyledView>
        
        <StyledTouchableOpacity 
          className="p-2"
        >
          <Icon name="more-vert" size={20} color="#6B7280" />
        </StyledTouchableOpacity>
      </StyledTouchableOpacity>
    </StyledView>
  );
} 