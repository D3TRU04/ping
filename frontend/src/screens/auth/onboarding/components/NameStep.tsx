import React from 'react';
import { View, TextInput, Animated } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../components/AppText';
import { FormData } from '../types';

const StyledView = styled(View);
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
      className="flex-1 pt-6 px-4 space-y-8"
    >
      <StyledView className="w-full bg-transparent mb-2">
        <AppText className="text-white text-3xl font-medium text-left">
          What's your name?
        </AppText>
        <StyledView className="w-full mt-2">
          <AppText className="text-white/80 text-base text-left max-w-[320px]">
            We use your name so friends can recognize and connect with you easily.
          </AppText>
        </StyledView>
      </StyledView>

      <StyledView className="flex-1 justify-center items-center w-full mb-16">
        <StyledTextInput
          style={{ width: 340, fontFamily: 'Satoshi-Medium' }}
          className="bg-white/95 rounded-2xl p-6 text-gray-800 text-xl text-center font-medium"
          placeholder="Enter your full name"
          placeholderTextColor="#9CA3AF"
          value={formData.fullName}
          onChangeText={(text) => setFormData(prev => ({ ...prev, fullName: text }))}
          autoFocus
          autoCapitalize="words"
        />
        {errors.fullName && (
          <AppText className="text-red-400 text-center text-sm">{errors.fullName}</AppText>
        )}
      </StyledView>
    </Animated.View>
  );
}; 