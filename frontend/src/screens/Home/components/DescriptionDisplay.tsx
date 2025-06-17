import React from 'react';
import { View, Text } from 'react-native';
import { styled } from 'nativewind';

const StyledView = styled(View);
const StyledText = styled(Text);

type Props = {
  description: string;
};

export default function DescriptionDisplay({ description }: Props) {
  if (!description?.trim()) return null;

  return (
    <StyledView className="mt-2">
      <StyledText className="text-sm text-gray-500 text-center font-system">
        {description}
      </StyledText>
    </StyledView>
  );
}
