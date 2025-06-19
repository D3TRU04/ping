import React from 'react';
import { View, Text, Animated } from 'react-native';
import { styled } from 'nativewind';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { LinearGradient } from 'expo-linear-gradient';

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
      className="flex-1 justify-center space-y-12"
    >
      {/* Hero section with app icon and welcome message */}
      <StyledView className="items-center space-y-6">
        <StyledView className="w-24 h-24 bg-white/20 rounded-full items-center justify-center">
          <StyledText className="text-4xl">🚀</StyledText>
        </StyledView>
        <StyledText className="text-white text-4xl font-medium text-center">
          Welcome to Ping
        </StyledText>
        <StyledText className="text-white/90 text-lg text-center px-8 leading-6">
          Your adventure starts here
        </StyledText>
      </StyledView>

      {/* Feature highlights - 2 cards side by side + 1 full width */}
      <StyledView className="px-6 space-y-4">
        <StyledView className="flex-row space-x-4">
          <StyledView className="flex-1 bg-white/10 backdrop-blur-lg rounded-2xl p-5">
            <StyledView className="w-12 h-12 bg-gradient-to-r from-blue-500 to-purple-600 rounded-xl items-center justify-center mb-3">
              <Icon name="explore" size={24} color="white" />
            </StyledView>
            <StyledText className="text-white font-medium text-base mb-1">
              Discover
            </StyledText>
            <StyledText className="text-white/70 text-sm">
              Find amazing places
            </StyledText>
          </StyledView>

          <StyledView className="flex-1 bg-white/10 backdrop-blur-lg rounded-2xl p-5">
            <StyledView className="w-12 h-12 bg-gradient-to-r from-green-500 to-teal-600 rounded-xl items-center justify-center mb-3">
              <Icon name="group" size={24} color="white" />
            </StyledView>
            <StyledText className="text-white font-medium text-base mb-1">
              Connect
            </StyledText>
            <StyledText className="text-white/70 text-sm">
              Plan with friends
            </StyledText>
          </StyledView>
        </StyledView>

        <StyledView className="bg-white/10 backdrop-blur-lg rounded-2xl p-5">
          <StyledView className="flex-row items-center">
            <StyledView className="w-12 h-12 bg-gradient-to-r from-pink-500 to-rose-600 rounded-xl items-center justify-center mr-4">
              <Icon name="auto-awesome" size={24} color="white" />
            </StyledView>
            <StyledView className="flex-1">
              <StyledText className="text-white font-medium text-base">
                Personalized
              </StyledText>
              <StyledText className="text-white/70 text-sm">
                Tailored just for you
              </StyledText>
            </StyledView>
          </StyledView>
        </StyledView>
      </StyledView>
    </Animated.View>
  );
}; 