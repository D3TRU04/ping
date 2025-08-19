import React from 'react';
import { View, Animated, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../components/AppText';
import Icon from 'react-native-vector-icons/MaterialIcons';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface FinalStepProps {
  selectedSubcategories: string[];
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
  onSkipToHome?: () => void;
}

export const FinalStep: React.FC<FinalStepProps> = ({
  selectedSubcategories: _selectedSubcategories,
  fadeAnim,
  slideAnim,
  scaleAnim,
  onSkipToHome,
}) => {
  // void _selectedSubcategories; // Unused but required by props interface
  return (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }]
      }}
      className="flex-1 justify-center space-y-8"
    >
      {/* Success message with celebration icon */}
      <StyledView className="items-center space-y-4">
        <StyledView className="w-20 h-20 bg-white/20 rounded-full items-center justify-center">
          <AppText className="text-4xl">🎉</AppText>
        </StyledView>
        <AppText className="text-white text-3xl font-medium text-center">
          You're all set!
        </AppText>
        <AppText className="text-white/90 text-base text-center px-8">
          Welcome to the Ping community! We'll use your interests to personalize your experience.
        </AppText>
      </StyledView>

      {/* Feature preview cards */}
      <StyledView className="space-y-3 px-4">
        <StyledView className="bg-white/10 rounded-2xl p-4 flex-row items-center">
          <StyledView className="w-10 h-10 bg-white rounded-full items-center justify-center mr-3">
            <AppText className="text-[#1FC9C3] text-lg">✓</AppText>
          </StyledView>
          <StyledView className="flex-1">
            <AppText className="text-white font-medium text-base">Ready to Explore</AppText>
            <AppText className="text-white/80 text-sm">Discover amazing places around you</AppText>
          </StyledView>
        </StyledView>

        <StyledView className="bg-white/10 rounded-2xl p-4 flex-row items-center">
          <StyledView className="w-10 h-10 bg-[#4ECDC4] rounded-full items-center justify-center mr-3">
            <Icon name="group" size={20} color="white" />
          </StyledView>
          <StyledView className="flex-1">
            <AppText className="text-white font-medium text-base">Connect & Share</AppText>
            <AppText className="text-white/80 text-sm">Plan activities with friends</AppText>
          </StyledView>
        </StyledView>
      </StyledView>

      {/* Development-only skip button */}
      {onSkipToHome && (
        <StyledTouchableOpacity
          className="bg-yellow-500/80 rounded-2xl p-3 mt-4 mx-4"
          onPress={onSkipToHome}
        >
          <AppText className="text-white text-center font-medium text-base">
            🚀 TEMP: Skip to Home
          </AppText>
        </StyledTouchableOpacity>
      )}
    </Animated.View>
  );
}; 