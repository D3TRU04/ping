import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';

const StyledView = styled(View);

type Props = {
  description: string;
};

export default function DescriptionDisplay({ description }: Props) {
  if (!description?.trim()) return null;

  return (
    <StyledView className="mt-2">
      <AppText className="text-sm text-gray-500 text-center font-system">
        {description}
      </AppText>
    </StyledView>
  );
}
