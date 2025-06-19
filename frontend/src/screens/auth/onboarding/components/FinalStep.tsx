import React from 'react';
import { View, Text, Animated, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import Icon from 'react-native-vector-icons/MaterialIcons';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface FinalStepProps {
  selectedSubcategories: string[];
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
  onSkipToHome?: () => void;
}

export const FinalStep: React.FC<FinalStepProps> = ({
  selectedSubcategories,
  fadeAnim,
  slideAnim,
  scaleAnim,
  onSkipToHome,
}) => {
  return (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }]
      }}
      className="space-y-8"
    >
      <StyledView className="items-center space-y-4">
        <StyledView className="w-24 h-24 bg-white/20 rounded-full items-center justify-center">
          <StyledText className="text-4xl">🎉</StyledText>
        </StyledView>
        <StyledText className="text-white text-4xl font-bold text-center">
          You're all set!
        </StyledText>
        <StyledText className="text-white/90 text-lg text-center leading-6">
          Welcome to the Ping community! We'll use your interests to personalize your experience and help you discover amazing places.
        </StyledText>
      </StyledView>

      <StyledView className="bg-white/20 rounded-2xl p-6">
        <StyledText className="text-white text-center font-bold mb-4 text-lg">
          Your Selected Interests
        </StyledText>
        <StyledView className="flex-row flex-wrap justify-center">
          {selectedSubcategories.map((subcategory) => (
            <StyledView
              key={subcategory}
              className="bg-white/90 rounded-full px-3 py-2 m-1"
            >
              <StyledText className="text-gray-800 text-sm">{subcategory}</StyledText>
            </StyledView>
          ))}
        </StyledView>
      </StyledView>

      <StyledView className="space-y-4">
        <StyledView className="bg-white/10 rounded-2xl p-4 flex-row items-center">
          <StyledView className="w-12 h-12 bg-[#E74C3C] rounded-full items-center justify-center mr-4">
            <Icon name="explore" size={24} color="white" />
          </StyledView>
          <StyledView className="flex-1">
            <StyledText className="text-white font-bold text-lg">Ready to Explore</StyledText>
            <StyledText className="text-white/80">Discover amazing places around you</StyledText>
          </StyledView>
        </StyledView>

        <StyledView className="bg-white/10 rounded-2xl p-4 flex-row items-center">
          <StyledView className="w-12 h-12 bg-[#4ECDC4] rounded-full items-center justify-center mr-4">
            <Icon name="group" size={24} color="white" />
          </StyledView>
          <StyledView className="flex-1">
            <StyledText className="text-white font-bold text-lg">Connect & Share</StyledText>
            <StyledText className="text-white/80">Plan activities with friends</StyledText>
          </StyledView>
        </StyledView>
      </StyledView>

      {/* Temporary Skip to Home Button */}
      {onSkipToHome && (
        <StyledTouchableOpacity
          className="bg-yellow-500/80 rounded-2xl p-4 mt-4"
          onPress={onSkipToHome}
        >
          <StyledText className="text-white text-center font-bold text-lg">
            🚀 TEMP: Skip to Home
          </StyledText>
          <StyledText className="text-white/80 text-center text-sm mt-1">
            (Development only - bypasses profile setup)
          </StyledText>
        </StyledTouchableOpacity>
      )}
    </Animated.View>
  );
}; 