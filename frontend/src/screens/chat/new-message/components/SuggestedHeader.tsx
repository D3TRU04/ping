import React, { memo } from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../components/AppText';

const StyledView = styled(View);

const SuggestedHeader = memo(() => (
  <StyledView className="px-4 py-3 bg-gray-50">
    <AppText className="text-sm font-semibold text-gray-700">Suggested</AppText>
  </StyledView>
));

SuggestedHeader.displayName = 'SuggestedHeader';

export default SuggestedHeader; 