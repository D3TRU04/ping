import React from 'react';
import { View, Text } from 'react-native';
import { styled } from 'nativewind';

const StyledView = styled(View);
const StyledText = styled(Text);

type Props = {
  name: string;
};

export default function NameDisplay({ name }: Props) {
  if (!name?.trim()) return null;

  return (
    <StyledView className="mb-1">
      <StyledText className="text-lg font-bold text-gray-900 text-center font-system">
        {name}
      </StyledText>
    </StyledView>
  );
}
