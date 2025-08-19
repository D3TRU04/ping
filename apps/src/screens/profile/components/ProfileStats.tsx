import React from 'react';
import { View, Pressable } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';

const StyledView = styled(View);
const StyledPressable = styled(Pressable);

export default function ProfileStats({ following, followers, onPressFollowing, onPressFollowers }: {
  following: number;
  followers: number;
  onPressFollowing?: () => void;
  onPressFollowers?: () => void;
}) {
  return (
    <StyledView className="w-full flex-row items-center justify-center space-x-12 mt-4 mb-3">
      <StyledPressable 
        className="items-center" 
        onPress={onPressFollowing}
        style={({ pressed }) => [
          {
            opacity: pressed ? 0.7 : 1,
            transform: [{ scale: pressed ? 0.95 : 1 }],
          },
        ]}
      >
        <AppText className="text-xl font-bold text-gray-900 mb-1">{following}</AppText>
        <AppText className="text-sm text-gray-600 font-medium">Following</AppText>
      </StyledPressable>
      
      <StyledView className="w-px h-8 bg-gray-200" />
      
      <StyledPressable 
        className="items-center" 
        onPress={onPressFollowers}
        style={({ pressed }) => [
          {
            opacity: pressed ? 0.7 : 1,
            transform: [{ scale: pressed ? 0.95 : 1 }],
          },
        ]}
      >
        <AppText className="text-xl font-bold text-gray-900 mb-1">{followers}</AppText>
        <AppText className="text-sm text-gray-600 font-medium">Followers</AppText>
      </StyledPressable>
    </StyledView>
  );
} 