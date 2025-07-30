import React, { useCallback, memo } from 'react';
import { View, TouchableOpacity, Image } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

interface UserItemProps {
  user: User;
  onPress?: (user: User) => void;
  isSelected?: boolean;
}

const UserItem = memo(({ 
  user, 
  onPress,
  isSelected = false
}: UserItemProps) => {
  const handlePress = useCallback(() => {
    // Only call onPress if it's provided and we're not in selection mode
    if (onPress) {
      onPress(user);
    }
  }, [user, onPress]);

  return (
    <StyledView className="flex-row items-center px-4 py-3 bg-white border-b border-gray-100">
      <StyledImage
        source={{ uri: user.profile_picture || undefined }}
        className="w-12 h-12 rounded-full mr-4 bg-gray-100"
      />
      <StyledView className="flex-1">
        <AppText className="text-base font-semibold text-gray-900 mb-0.5">
          {user.full_name || user.username || 'Unknown User'}
        </AppText>
        <AppText className="text-sm text-gray-500">
          @{user.username}
        </AppText>
      </StyledView>
      {isSelected ? (
        <Icon name="check-circle" size={24} color="#10B981" />
      ) : (
        <Icon name="radio-button-unchecked" size={24} color="#9CA3AF" />
      )}
    </StyledView>
  );
});

UserItem.displayName = 'UserItem';

export default UserItem; 