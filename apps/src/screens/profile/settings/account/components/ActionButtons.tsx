import React from 'react';
import { View, Pressable } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../../components/AppText';

const StyledView = styled(View);

interface ActionButtonsProps {
  isEditing: boolean;
  onEdit: () => void;
  onSave: () => void;
  onCancel: () => void;
}

export default function ActionButtons({ 
  isEditing, 
  onEdit, 
  onSave, 
  onCancel 
}: ActionButtonsProps) {
  if (isEditing) {
    return (
      <StyledView className="flex-row space-x-3 mb-6">
        <Pressable 
          onPress={onCancel}
          className="flex-1 py-3 bg-gray-100 rounded-xl items-center"
          style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}
        >
          <AppText className="text-gray-700 font-medium">Cancel</AppText>
        </Pressable>
        <Pressable 
          onPress={onSave}
          className="flex-1 py-3 bg-[#1FC9C3] rounded-xl items-center"
          style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}
        >
          <AppText className="text-white font-medium">Save Changes</AppText>
        </Pressable>
      </StyledView>
    );
  }

  return (
    <StyledView className="mb-6">
      <Pressable 
        onPress={onEdit}
        className="w-full py-3 bg-[#1FC9C3] rounded-xl items-center"
        style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}
      >
        <AppText className="text-white font-medium">Edit Profile</AppText>
      </Pressable>
    </StyledView>
  );
} 