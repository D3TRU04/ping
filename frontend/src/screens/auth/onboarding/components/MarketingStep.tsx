import React from 'react';
import { View, Text, Animated } from 'react-native';
import { styled } from 'nativewind';

const StyledView = styled(View);
const StyledText = styled(Text);

interface MarketingStepProps {
  titlePart1: string;
  highlightedText: string;
  titlePart2: string;
  subtitle: string;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const MarketingStep: React.FC<MarketingStepProps> = ({
  titlePart1,
  highlightedText,
  titlePart2,
  subtitle,
  fadeAnim,
  slideAnim,
  scaleAnim,
}) => {
  return (
    <Animated.View
      style={{
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }],
      }}
      className="flex-1 justify-center items-center space-y-8 px-4"
    >
      <StyledText className="text-white text-4xl font-medium text-center">
        {titlePart1}
        <StyledText style={{ color: '#FCD34D' }}>{highlightedText}</StyledText>
        {titlePart2}
      </StyledText>
      <StyledText className="text-white/80 text-lg text-center max-w-sm">
        {subtitle}
      </StyledText>
    </Animated.View>
  );
}; 