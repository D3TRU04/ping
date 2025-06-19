import React, { useState } from 'react';
import { View, Text, TextInput, Animated, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { LinearGradient } from 'expo-linear-gradient';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { FormData } from '../types';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTextInput = styled(TextInput);
const StyledTouchableOpacity = styled(TouchableOpacity);

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
  const [isFocused, setIsFocused] = useState(false);

  return (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }]
      }}
      className="flex-1 justify-center space-y-8"
    >
      <StyledView className="items-center space-y-6">
        <StyledView className="w-24 h-24 bg-white/20 rounded-full items-center justify-center">
          <StyledText className="text-4xl">👤</StyledText>
        </StyledView>
        <StyledText className="text-white text-4xl font-medium text-center">
          Choose your username
        </StyledText>
      </StyledView>

      <StyledView className="space-y-6 px-4">
        <StyledView className="space-y-3">
          <StyledView 
            className={`flex-row items-center rounded-2xl px-6 py-5 border-2 transition-all duration-200 ${
              isFocused 
                ? 'bg-white/95 border-blue-500 shadow-lg' 
                : 'bg-white/90 border-transparent'
            }`}
          >
            <StyledView className="w-8 h-8 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full items-center justify-center mr-4">
              <StyledText className="text-white font-bold text-lg">@</StyledText>
            </StyledView>
            <StyledTextInput
              className="flex-1 text-gray-800 text-xl font-semibold"
              placeholder="Enter username"
              placeholderTextColor="#9CA3AF"
              value={formData.username}
              onChangeText={(text) => {
                setFormData(prev => ({ ...prev, username: text }));
                checkUsername(text);
              }}
              onFocus={() => setIsFocused(true)}
              onBlur={() => setIsFocused(false)}
              autoFocus
              autoCapitalize="none"
              autoCorrect={false}
            />
            {formData.username.length > 0 && (
              <StyledView className="ml-3">
                {usernameAvailable === true && (
                  <Icon name="check-circle" size={24} color="#10B981" />
                )}
                {usernameAvailable === false && (
                  <Icon name="error" size={24} color="#EF4444" />
                )}
                {usernameAvailable === null && (
                  <Icon name="schedule" size={24} color="#6B7280" />
                )}
              </StyledView>
            )}
          </StyledView>
          
          {errors.username && (
            <StyledView className="flex-row items-center bg-red-500/10 rounded-xl px-4 py-3">
              <Icon name="error-outline" size={20} color="#EF4444" />
              <StyledText className="text-red-400 text-sm ml-2 flex-1">{errors.username}</StyledText>
            </StyledView>
          )}
          
          {usernameAvailable !== null && (
            <StyledView className={`flex-row items-center rounded-xl px-4 py-3 border-2 ${
              usernameAvailable ? 'bg-green-500 border-green-300' : 'bg-red-500 border-red-300'
            }`}>
              <Icon 
                name={usernameAvailable ? 'check-circle-outline' : 'error-outline'} 
                size={20} 
                color="white"
              />
              <StyledText className="text-white text-sm ml-2 font-medium">
                {usernameAvailable ? 'Username is available!' : 'Username is already taken'}
              </StyledText>
            </StyledView>
          )}
        </StyledView>
      </StyledView>
    </Animated.View>
  );
}; 