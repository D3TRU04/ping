import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';

const StyledView = styled(View);

type Props = {
  name: string;
};

export default function NameDisplay({ name }: Props) {
  if (!name?.trim()) return null;

  return (
    <StyledView className="mb-1">
      <AppText className="text-lg font-bold text-gray-900 text-center font-system">
        {name}
      </AppText>
    </StyledView>
  );
}
