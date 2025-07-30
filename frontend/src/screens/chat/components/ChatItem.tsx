import React from 'react';
import { View, TouchableOpacity, Image } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

interface Chat {
  id: string;
  name: string;
  avatar: string | null;
  lastMessage: string;
  lastMessageTime: string;
  unreadCount: number;
  isOnline: boolean;
  isGroup: boolean;
  conversationId: string;
}

interface ChatItemProps {
  item: Chat;
  onPress: (chat: Chat) => void;
  isSelectionMode?: boolean;
  isSelected?: boolean;
  onSelect?: (chat: Chat) => void;
}

export default function ChatItem({ 
  item, 
  onPress, 
  isSelectionMode = false, 
  isSelected = false,
  onSelect 
}: ChatItemProps) {
  const formatTime = (time: string) => {
    return new Date(time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const handlePress = () => {
    if (isSelectionMode) {
      onSelect?.(item);
    } else {
      onPress(item);
    }
  };

  return (
    <StyledTouchableOpacity
      onPress={handlePress}
      className={`flex-row items-center p-4 bg-white border-b border-gray-100 ${
        isSelectionMode && isSelected ? 'bg-mint/10' : ''
      }`}
    >
      {/* Selection checkbox */}
      {isSelectionMode && (
        <StyledView className="mr-3">
          <StyledView 
            className={`w-6 h-6 rounded-full border-2 items-center justify-center ${
              isSelected 
                ? 'bg-mint border-mint' 
                : 'bg-white border-gray-300'
            }`}
          >
            {isSelected && (
              <Icon name="check" size={16} color="white" />
            )}
          </StyledView>
        </StyledView>
      )}

      {/* Avatar */}
      <StyledView className="relative">
        <StyledImage
          source={{ uri: item.avatar || undefined }}
          className="w-12 h-12 rounded-full"
          style={{ backgroundColor: '#F5F6FA' }}
        />
        {item.isOnline && (
          <StyledView 
            className="absolute bottom-0 right-0 w-3 h-3 rounded-full border-2 border-white"
            style={{ backgroundColor: COLORS.success }}
          />
        )}
      </StyledView>
      
      {/* Chat info */}
      <StyledView className="flex-1 ml-4">
        <StyledView className="flex-row items-center justify-between">
          <AppText className="text-base font-semibold text-gray-900">
            {item.name}
          </AppText>
          <AppText className="text-xs text-gray-500">
            {formatTime(item.lastMessageTime)}
          </AppText>
        </StyledView>
        
        <StyledView className="flex-row items-center justify-between mt-1">
          <AppText 
            className="text-sm text-gray-600 flex-1 mr-2"
            numberOfLines={1}
          >
            {item.lastMessage}
          </AppText>
          {item.unreadCount > 0 && (
            <StyledView 
              className="w-5 h-5 rounded-full items-center justify-center"
              style={{ backgroundColor: COLORS.mint }}
            >
              <AppText className="text-xs text-white font-semibold">
                {item.unreadCount > 99 ? '99+' : item.unreadCount}
              </AppText>
            </StyledView>
          )}
        </StyledView>
      </StyledView>
    </StyledTouchableOpacity>
  );
} 