import React from 'react';
import { View, TouchableOpacity, Animated } from 'react-native';
import { styled } from 'nativewind';
import { Ionicons } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface AuthOptionsStepProps {
  onEmailSignup: () => void;
  onGoogleSignup: () => void;
  onAppleSignup: () => void;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const AuthOptionsStep: React.FC<AuthOptionsStepProps> = ({
  onEmailSignup,
  onGoogleSignup,
  onAppleSignup,
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
      className="flex-1 pt-6 px-4 space-y-8"
    >
      <StyledView className="w-full bg-transparent mb-2">
        <AppText className="text-white text-3xl font-medium text-left">
          Create your account
        </AppText>
        <StyledView className="w-full mt-2">
          <AppText className="text-white/80 text-base text-left max-w-[320px]">
            Choose how you'd like to sign up for Ping
          </AppText>
        </StyledView>
      </StyledView>

      <StyledView className="flex-1 justify-center items-center w-full space-y-4">
        {/* Google Sign Up Button */}
        <StyledTouchableOpacity
          className="bg-white rounded-2xl p-4 w-full flex-row items-center justify-center shadow-lg"
          onPress={onGoogleSignup}
          style={{ width: 340 }}
        >
          <Ionicons name="logo-google" size={24} color="#4285F4" />
          <AppText className="text-gray-800 text-lg font-medium ml-3">
            Sign up with Google
          </AppText>
        </StyledTouchableOpacity>

        {/* Apple Sign Up Button */}
        <StyledTouchableOpacity
          className="bg-black rounded-2xl p-4 w-full flex-row items-center justify-center shadow-lg"
          onPress={onAppleSignup}
          style={{ width: 340 }}
        >
          <Ionicons name="logo-apple" size={24} color="#FFFFFF" />
          <AppText className="text-white text-lg font-medium ml-3">
            Sign up with Apple
          </AppText>
        </StyledTouchableOpacity>

        {/* Divider */}
        <StyledView className="flex-row items-center w-full my-4" style={{ width: 340 }}>
          <StyledView className="flex-1 h-px bg-white/30" />
          <AppText className="text-white/60 text-sm mx-4">or</AppText>
          <StyledView className="flex-1 h-px bg-white/30" />
        </StyledView>

        {/* Email Sign Up Button */}
        <StyledTouchableOpacity
          className="bg-white rounded-2xl p-4 w-full flex-row items-center justify-center shadow-lg"
          onPress={onEmailSignup}
          style={{ width: 340 }}
        >
          <Ionicons name="mail" size={24} color="#1FC9C3" />
          <AppText className="text-gray-800 text-lg font-medium ml-3">
            Sign up with Email
          </AppText>
        </StyledTouchableOpacity>
      </StyledView>
    </Animated.View>
  );
};
