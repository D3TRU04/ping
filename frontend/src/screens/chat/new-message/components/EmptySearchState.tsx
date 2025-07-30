import React, { memo } from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';

const StyledView = styled(View);

const EmptySearchState = memo(() => (
  <StyledView className="flex-1 justify-center items-center px-8 py-12">
    <StyledView className="w-16 h-16 bg-gray-100 rounded-full items-center justify-center mb-4">
      <Icon name="search" size={24} color="#9CA3AF" />
    </StyledView>
    <AppText className="text-lg font-semibold text-gray-900 mb-2 text-center">
      No users found
    </AppText>
    <AppText className="text-gray-600 text-center leading-5 text-sm">
      Try searching with a different name or username
    </AppText>
  </StyledView>
));

EmptySearchState.displayName = 'EmptySearchState';

export default EmptySearchState; 