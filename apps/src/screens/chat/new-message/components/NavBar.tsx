import React, { memo } from 'react';
import { View, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { SafeAreaView } from 'react-native-safe-area-context';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledSafeAreaView = styled(SafeAreaView);

interface NewMessageNavBarProps {
  onBack: () => void;
}

const NewMessageNavBar = memo(({ onBack }: NewMessageNavBarProps) => (
  <StyledSafeAreaView className="bg-white">
    <StyledView className="flex-row items-center justify-between px-4 py-2 bg-white border-b border-gray-100">
      <StyledTouchableOpacity onPress={onBack} className="p-2">
        <Icon name="arrow-back" size={24} color={COLORS.mint} />
      </StyledTouchableOpacity>
      <AppText className="text-lg font-semibold text-gray-900">New Message</AppText>
      <StyledView className="w-10" />
    </StyledView>
  </StyledSafeAreaView>
));

NewMessageNavBar.displayName = 'NewMessageNavBar';

export default NewMessageNavBar; 