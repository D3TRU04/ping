import React from 'react';
import { View, Text, TextInput, Animated } from 'react-native';
import { styled } from 'nativewind';
import { FormData } from '../types';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTextInput = styled(TextInput);

interface UsernameStepProps {
  formData: FormData;
  setFormData: (data: FormData | ((prev: FormData) => FormData)) => void;
  errors: Record<string, string>;
  usernameAvailable: boolean | null;
  checkUsername: (username: string) => void;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const UsernameStep: React.FC<UsernameStepProps> = ({
  formData,
  setFormData,
  errors,
  usernameAvailable,
  checkUsername,
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
          <StyledText className="text-3xl">👤</StyledText>
        </StyledView>
        <StyledText className="text-white text-3xl font-bold text-center">
          Choose your username
        </StyledText>
        <StyledText className="text-white/80 text-lg text-center px-8">
          This will be your unique identifier on Ping
        </StyledText>
      </StyledView>

      <StyledView className="space-y-4">
        <StyledView className="flex-row items-center bg-white/95 rounded-2xl px-6 py-4">
          <StyledText className="text-gray-500 mr-3 text-xl">@</StyledText>
          <StyledTextInput
            className="flex-1 text-gray-800 text-xl font-medium"
            placeholder="username"
            placeholderTextColor="#9CA3AF"
            value={formData.username}
            onChangeText={(text) => {
              setFormData(prev => ({ ...prev, username: text }));
              checkUsername(text);
            }}
            autoFocus
            autoCapitalize="none"
            autoCorrect={false}
          />
        </StyledView>
        {errors.username && (
          <StyledText className="text-red-400 text-center text-sm">{errors.username}</StyledText>
        )}
        {usernameAvailable !== null && (
          <StyledView className="items-center">
            <StyledText className={`text-sm ${usernameAvailable ? 'text-green-400' : 'text-red-400'}`}>
              {usernameAvailable ? '✓ Username available!' : '✗ Username taken'}
            </StyledText>
          </StyledView>
        )}
      </StyledView>
    </Animated.View>
  );
}; 