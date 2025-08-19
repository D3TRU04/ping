// home/feeds/item-card/components/FooterButtons.tsx
import React from 'react';
import { View, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../../components/AppText';
import { COLORS } from '../../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface FooterButtonsProps {
  placeName: string;
  onDirections: () => void;
  onCall: () => void;
}

export default function FooterButtons({
  placeName,
  onDirections,
  onCall
}: FooterButtonsProps) {
  return (
    <StyledView className="flex-row space-x-3 mt-2 mb-4">
      <StyledTouchableOpacity
        className="flex-1 bg-gray-100 py-3 rounded-2xl items-center"
        onPress={onDirections}
      >
        <StyledView className="flex-row items-center">
          <Icon name="directions" size={16} color={COLORS.mint} />
          <AppText className="text-sm text-gray-700 ml-2">Directions</AppText>
        </StyledView>
      </StyledTouchableOpacity>

      <StyledTouchableOpacity
        className="flex-1 bg-mint py-3 rounded-2xl items-center"
        onPress={onCall}
      >
        <StyledView className="flex-row items-center">
          <Icon name="phone" size={16} color="white" />
          <AppText className="text-sm text-white ml-2">Call</AppText>
        </StyledView>
      </StyledTouchableOpacity>
    </StyledView>
  );
}
