import React from 'react';
import { View, Text, Dimensions } from 'react-native';
import { styled } from 'nativewind';

const screenWidth = Dimensions.get('window').width;

const StyledView = styled(View);
const StyledText = styled(Text);

type Props = {
  subtopic?: string;
  typeOfFood?: string;
};

export default function TagDisplay({ subtopic, typeOfFood }: Props) {
  const hasSubtopic = typeof subtopic === 'string' && subtopic.trim().length > 0;
  const hasType = typeof typeOfFood === 'string' && typeOfFood.trim().length > 0;

  const tagWidth = screenWidth * 0.4;

  if (!hasSubtopic && !hasType) return null;

  // ✅ Both tags present
  if (hasSubtopic && hasType) {
    return (
      <StyledView className="flex-row justify-center items-center gap-2 mb-1">
        {/* Left: Subtopic Pill */}
        <StyledView style={{ width: tagWidth }} className="items-end">
          <StyledView className="bg-[#FFA726]/20 rounded-full px-2 py-0.5 self-end">
            <StyledText className="text-xs text-[#FFA726] font-bold font-system">
              {subtopic}
            </StyledText>
          </StyledView>
        </StyledView>

        {/* Right: Type of Food Pill */}
        <StyledView style={{ width: tagWidth }} className="items-start">
          <StyledView className="bg-[#FFA726]/10 rounded-full px-2 py-0.5 self-start">
            <StyledText className="text-xs text-[#FFA726] font-system">
              {typeOfFood}
            </StyledText>
          </StyledView>
        </StyledView>
      </StyledView>
    );
  }

  // ✅ Only subtopic exists
  if (hasSubtopic) {
    return (
      <StyledView className="flex-row justify-center mb-1">
        <StyledView className="bg-[#FFA726]/20 rounded-full px-2 py-0.5">
          <StyledText className="text-xs text-[#FFA726] font-bold font-system">
            {subtopic}
          </StyledText>
        </StyledView>
      </StyledView>
    );
  }

  // ✅ Only typeOfFood exists
  return (
    <StyledView className="flex-row justify-center mb-1">
      <StyledView className="bg-[#FFA726]/10 rounded-full px-2 py-0.5">
        <StyledText className="text-xs text-[#FFA726] font-system">
          {typeOfFood}
        </StyledText>
      </StyledView>
    </StyledView>
  );
}
