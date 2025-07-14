import React from 'react';
import { View, Dimensions } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';

const screenWidth = Dimensions.get('window').width;

const StyledView = styled(View);

type Props = {
  subtopic?: string;
  typeOfFood?: string;
};

export default function TagDisplay({ subtopic, typeOfFood }: Props) {
  if (!subtopic && !typeOfFood) return null;

  return (
    <StyledView className="flex-row flex-wrap gap-2 justify-center mt-2">
      {subtopic && (
        <AppText className="text-xs text-gray-500 bg-gray-100 rounded-full px-2 py-1">
          {subtopic}
        </AppText>
      )}
      {typeOfFood && (
        <AppText className="text-xs text-gray-500 bg-gray-100 rounded-full px-2 py-1">
          {typeOfFood}
        </AppText>
      )}
    </StyledView>
  );
}
