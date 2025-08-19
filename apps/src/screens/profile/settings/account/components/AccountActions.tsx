import React from 'react';
import { View, Pressable } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../../components/AppText';

const StyledView = styled(View);

export default function AccountActions() {
  return (
    <StyledView className="mb-6">
      <StyledView className="mb-3 px-2">
        <AppText className="text-sm font-medium text-gray-600">Account Actions</AppText>
      </StyledView>
      
      <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden">
        <Pressable className="flex-row items-center px-4 py-3 border-b border-gray-100">
          <StyledView className="w-8 h-8 bg-[#1FC9C3]/10 rounded-lg items-center justify-center mr-3">
            <Icon name="lock" size={18} color="#1FC9C3" />
          </StyledView>
          <AppText className="text-base text-gray-900 flex-1">Change Password</AppText>
          <Icon name="chevron-right" size={18} color="#D1D5DB" />
        </Pressable>
        
        <Pressable className="flex-row items-center px-4 py-3">
          <StyledView className="w-8 h-8 bg-[#1FC9C3]/10 rounded-lg items-center justify-center mr-3">
            <Icon name="email" size={18} color="#1FC9C3" />
          </StyledView>
          <AppText className="text-base text-gray-900 flex-1">Change Email</AppText>
          <Icon name="chevron-right" size={18} color="#D1D5DB" />
        </Pressable>
      </StyledView>
    </StyledView>
  );
} 