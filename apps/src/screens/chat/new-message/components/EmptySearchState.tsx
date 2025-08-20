import React, { memo } from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);

const EmptySearchState = memo(() => (
  <StyledView className="flex-1 justify-center items-center px-8 mt-40">
    <Icon name="search" size={80} color={COLORS.mint} />
    <AppText className="text-xl text-gray-900 mt-4 text-center">
      No users found
    </AppText>
    <AppText className="text-gray-600 text-center mt-2 leading-6">
      Try searching with a different name or username
    </AppText>
  </StyledView>
));

EmptySearchState.displayName = 'EmptySearchState';

export default EmptySearchState; 