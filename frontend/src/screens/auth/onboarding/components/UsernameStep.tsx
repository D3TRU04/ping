import React, { useState, useRef, useEffect } from 'react';
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
  const availabilityAnim = useRef(new Animated.Value(0)).current;
  const prevAvailability = useRef<null | boolean>(null);

  useEffect(() => {
    if (usernameAvailable !== null && usernameAvailable !== prevAvailability.current) {
      availabilityAnim.setValue(0);
      Animated.timing(availabilityAnim, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }).start();
    }
    prevAvailability.current = usernameAvailable;
  }, [usernameAvailable]);

  return (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }]
      }}
      className="flex-1 pt-6 px-4 space-y-8"
    >
      {/* Question Container */}
      <StyledView className="w-full bg-transparent mb-2">
        <StyledText className="text-white text-3xl font-medium text-left">
          Choose your username
        </StyledText>
        <StyledView className="w-full mt-2">
          <StyledText className="text-white/80 text-base text-left max-w-[320px]">
            Your username is your unique identity on Ping.
          </StyledText>
        </StyledView>
      </StyledView>

      {/* Input Container - vertically centered */}
      <StyledView className="flex-1 justify-center items-center w-full mb-16">
        <StyledView className="w-full">
          <StyledTextInput
            className="w-full text-gray-800 text-xl font-semibold text-center bg-white/95 rounded-2xl px-6 py-5 border-2 border-transparent focus:border-blue-500 shadow-lg"
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
        </StyledView>
        {errors.username && (
          <StyledView className="flex-row items-center bg-red-500/10 rounded-xl px-4 py-3 mt-2 w-full">
            <Icon name="error-outline" size={20} color="#EF4444" />
            <StyledText className="text-red-400 text-sm ml-2 flex-1">{errors.username}</StyledText>
          </StyledView>
        )}
        {usernameAvailable !== null && (
          <Animated.View
            style={{
              opacity: availabilityAnim,
              transform: [{ translateY: availabilityAnim.interpolate({ inputRange: [0, 1], outputRange: [16, 0] }) }],
            }}
          >
            <StyledView className={`flex-row items-center rounded-xl px-4 py-3 border-2 mt-6 w-full ${
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
          </Animated.View>
        )}
      </StyledView>
    </Animated.View>
  );
}; 