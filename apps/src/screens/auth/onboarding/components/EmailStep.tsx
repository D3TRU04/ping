import React from 'react';
import { View, TextInput, Animated } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../components/AppText';
import { FormData } from '../types/types';

const StyledView = styled(View);
const StyledTextInput = styled(TextInput);

interface EmailStepProps {
  formData: FormData;
  setFormData: (data: FormData | ((prev: FormData) => FormData)) => void;
  errors: Record<string, string>;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const EmailStep: React.FC<EmailStepProps> = ({
  formData,
  setFormData,
  errors,
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
          What's your email?
        </AppText>
        <StyledView className="w-full mt-2">
          <AppText className="text-white/80 text-base text-left max-w-[320px]">
            We'll use this to create your account and keep you signed in.
          </AppText>
        </StyledView>
      </StyledView>

      <StyledView className="flex-1 justify-center items-center w-full mb-16">
        <StyledTextInput
          style={{ width: 340, fontFamily: 'Satoshi-Medium' }}
          className="bg-white/95 rounded-full p-4 text-gray-800 text-xl text-center font-medium"
          placeholder="Enter your email address"
          placeholderTextColor="#9CA3AF"
          value={formData.email}
          onChangeText={(text) => setFormData(prev => ({ ...prev, email: text }))}
          keyboardType="email-address"
          autoFocus
          autoCapitalize="none"
        />
        {errors.email && (
          <AppText className="text-red-400 text-center text-sm mt-2">{errors.email}</AppText>
        )}
      </StyledView>
    </Animated.View>
  );
}; 