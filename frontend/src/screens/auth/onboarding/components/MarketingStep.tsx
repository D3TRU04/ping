import React from 'react';
import { Animated } from 'react-native';
// import { styled } from 'nativewind';
import AppText from '../../../../components/AppText';

// const StyledView = styled(View);

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
      <AppText className="text-white text-4xl font-medium text-center leading-tight">
        {titlePart1}
        <AppText style={{ color: '#FCD34D' }}>{highlightedText}</AppText>
        {titlePart2}
      </AppText>
      <AppText className="text-white/80 text-xl text-center max-w-sm leading-relaxed">
        {subtitle}
      </AppText>
    </Animated.View>
  );
}; 