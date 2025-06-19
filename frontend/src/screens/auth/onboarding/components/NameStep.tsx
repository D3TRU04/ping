import React from 'react';
import { View, Text, TextInput, Animated } from 'react-native';
import { styled } from 'nativewind';
import { FormData } from '../types';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTextInput = styled(TextInput);

interface NameStepProps {
  formData: FormData;
  setFormData: (data: FormData | ((prev: FormData) => FormData)) => void;
  errors: Record<string, string>;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const NameStep: React.FC<NameStepProps> = ({
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
      className="flex-1 justify-center space-y-8"
    >
      <StyledView className="items-center space-y-4">
        <StyledView className="w-20 h-20 bg-white/20 rounded-full items-center justify-center">
          <StyledText className="text-3xl">👋</StyledText>
        </StyledView>
        <StyledText className="text-white text-3xl font-bold text-center">
          What's your name?
        </StyledText>
        <StyledText className="text-white/80 text-lg text-center px-8">
          We'd love to know what to call you
        </StyledText>
      </StyledView>

      <StyledView className="space-y-4">
        <StyledTextInput
          className="bg-white/95 rounded-2xl p-6 text-gray-800 text-xl text-center font-medium"
          placeholder="Enter your full name"
          placeholderTextColor="#9CA3AF"
          value={formData.fullName}
          onChangeText={(text) => setFormData(prev => ({ ...prev, fullName: text }))}
          autoFocus
          autoCapitalize="words"
        />
        {errors.fullName && (
          <StyledText className="text-red-400 text-center text-sm">{errors.fullName}</StyledText>
        )}
      </StyledView>
    </Animated.View>
  );
}; 