import React, { memo } from 'react';
import { View, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface GroupChatOptionProps {
  onPress: () => void;
}

const GroupChatOption = memo(({ onPress }: GroupChatOptionProps) => (
  <StyledTouchableOpacity
    onPress={onPress}
    className="flex-row items-center px-4 py-4 bg-white border-b border-gray-100"
  >
    <StyledView className="w-12 h-12 bg-mint/10 rounded-full items-center justify-center mr-4">
      <Icon name="group" size={24} color={COLORS.mint} />
    </StyledView>
    <StyledView className="flex-1">
      <AppText className="text-base font-semibold text-gray-900 mb-1">
        Group chat
      </AppText>
      <AppText className="text-sm text-gray-500">
        Message people privately
      </AppText>
    </StyledView>
    <Icon name="chevron-right" size={24} color="#9CA3AF" />
  </StyledTouchableOpacity>
));

GroupChatOption.displayName = 'GroupChatOption';

export default GroupChatOption; 