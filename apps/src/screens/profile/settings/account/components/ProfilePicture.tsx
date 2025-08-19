import React from 'react';
import { View, Pressable } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../../components/AppText';

const StyledView = styled(View);

interface ProfilePictureProps {
  fullName?: string;
}

export default function ProfilePicture({ fullName }: ProfilePictureProps) {
  return (
    <StyledView className="mb-6">
      <StyledView className="mb-3 px-2">
        <AppText className="text-sm font-medium text-gray-600">Profile Picture</AppText>
      </StyledView>
      
      <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden p-4 items-center">
        <StyledView className="w-20 h-20 bg-[#1FC9C3] rounded-full items-center justify-center mb-3">
          <AppText className="text-white font-bold text-2xl">
            {fullName ? fullName.charAt(0).toUpperCase() : 'U'}
          </AppText>
        </StyledView>
        <Pressable className="px-4 py-2 bg-[#1FC9C3] rounded-lg">
          <AppText className="text-white font-medium">Change Photo</AppText>
        </Pressable>
      </StyledView>
    </StyledView>
  );
} 