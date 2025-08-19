import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';

const StyledView = styled(View);

interface LoadingStateProps {
  message?: string;
}

export default function LoadingState({ message = "Loading user information..." }: LoadingStateProps) {
  return (
    <StyledView className="flex-1 justify-center items-center px-8">
      <AppText className="text-lg text-gray-600 text-center">
        {message}
      </AppText>
    </StyledView>
  );
} 