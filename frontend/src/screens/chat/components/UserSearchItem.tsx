import React from 'react';
import { View, TouchableOpacity, Image } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

interface UserSearchItemProps {
  item: User;
  onPress: (user: User) => void;
}

export default function UserSearchItem({ item, onPress }: UserSearchItemProps) {
  return (
    <StyledTouchableOpacity
      onPress={() => onPress(item)}
      className="flex-row items-center p-4 bg-white border-b border-gray-100"
    >
      <StyledImage
        source={{ uri: item.profile_picture || undefined }}
        className="w-12 h-12 rounded-full mr-4"
        style={{ backgroundColor: '#F5F6FA' }}
      />
      <StyledView className="flex-1">
        <AppText className="text-base font-semibold text-gray-900">
          {item.full_name || item.username || 'Unknown User'}
        </AppText>
        <AppText className="text-sm text-gray-500">
          @{item.username}
        </AppText>
      </StyledView>
      <Icon name="add" size={24} color={COLORS.mint} />
    </StyledTouchableOpacity>
  );
} 