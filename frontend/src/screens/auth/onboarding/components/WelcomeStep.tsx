import React from 'react';
import { View, Text, Animated } from 'react-native';
import { styled } from 'nativewind';
import Icon from 'react-native-vector-icons/MaterialIcons';

const StyledView = styled(View);
const StyledText = styled(Text);

interface WelcomeStepProps {
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const WelcomeStep: React.FC<WelcomeStepProps> = ({
  fadeAnim,
  slideAnim,
  scaleAnim,
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
          <StyledText className="text-4xl">🚀</StyledText>
        </StyledView>
        <StyledText className="text-white text-4xl font-bold text-center">
          Welcome to Ping!
        </StyledText>
        <StyledText className="text-white/90 text-lg text-center leading-6">
          Discover amazing places, connect with friends, and create unforgettable memories together
        </StyledText>
      </StyledView>

      <StyledView className="space-y-4">
        <StyledView className="bg-white/10 rounded-2xl p-4 flex-row items-center">
          <StyledView className="w-12 h-12 bg-[#E74C3C] rounded-full items-center justify-center mr-4">
            <Icon name="location-on" size={24} color="white" />
          </StyledView>
          <StyledView className="flex-1">
            <StyledText className="text-white font-bold text-lg">Discover Places</StyledText>
            <StyledText className="text-white/80">Find the best spots in your area</StyledText>
          </StyledView>
        </StyledView>

        <StyledView className="bg-white/10 rounded-2xl p-4 flex-row items-center">
          <StyledView className="w-12 h-12 bg-[#4ECDC4] rounded-full items-center justify-center mr-4">
            <Icon name="people" size={24} color="white" />
          </StyledView>
          <StyledView className="flex-1">
            <StyledText className="text-white font-bold text-lg">Connect with Friends</StyledText>
            <StyledText className="text-white/80">Plan activities together</StyledText>
          </StyledView>
        </StyledView>

        <StyledView className="bg-white/10 rounded-2xl p-4 flex-row items-center">
          <StyledView className="w-12 h-12 bg-[#45B7D1] rounded-full items-center justify-center mr-4">
            <Icon name="favorite" size={24} color="white" />
          </StyledView>
          <StyledView className="flex-1">
            <StyledText className="text-white font-bold text-lg">Personalized Experience</StyledText>
            <StyledText className="text-white/80">Get recommendations based on your interests</StyledText>
          </StyledView>
        </StyledView>
      </StyledView>
    </Animated.View>
  );
}; 