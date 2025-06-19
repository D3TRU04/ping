import React from 'react';
import { View, Text, TextInput, TouchableOpacity, Animated } from 'react-native';
import { styled } from 'nativewind';
import DateTimePicker from '@react-native-community/datetimepicker';
import { FormData } from '../types';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTextInput = styled(TextInput);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface PersonalInfoStepProps {
  formData: FormData;
  setFormData: (data: FormData | ((prev: FormData) => FormData)) => void;
  errors: Record<string, string>;
  usernameAvailable: boolean | null;
  showDatePicker: boolean;
  setShowDatePicker: (show: boolean) => void;
  checkUsername: (username: string) => void;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const PersonalInfoStep: React.FC<PersonalInfoStepProps> = ({
  formData,
  setFormData,
  errors,
  usernameAvailable,
  showDatePicker,
  setShowDatePicker,
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
      className="space-y-6"
    >
      <StyledView className="items-center space-y-4">
        <StyledText className="text-white text-3xl font-bold text-center">
          Tell us about yourself
        </StyledText>
        <StyledText className="text-white/80 text-lg text-center">
          Let's personalize your experience
        </StyledText>
      </StyledView>

      <StyledView className="space-y-4">
        <StyledView>
          <StyledText className="text-white/90 text-lg mb-2">Full Name</StyledText>
          <StyledTextInput
            className="bg-white/95 rounded-2xl p-4 text-gray-800 text-lg"
            placeholder="Enter your full name"
            value={formData.fullName}
            onChangeText={(text) => setFormData(prev => ({ ...prev, fullName: text }))}
          />
          {errors.fullName && (
            <StyledText className="text-red-400 text-sm mt-2">{errors.fullName}</StyledText>
          )}
        </StyledView>

        <StyledView>
          <StyledText className="text-white/90 text-lg mb-2">Birthday</StyledText>
          <StyledTouchableOpacity
            className="bg-white/95 rounded-2xl p-4"
            onPress={() => setShowDatePicker(true)}
          >
            <StyledText className="text-gray-800 text-lg text-center">
              {formData.birthday.toLocaleDateString()}
            </StyledText>
          </StyledTouchableOpacity>
          {errors.birthday && (
            <StyledText className="text-red-400 text-sm mt-2">{errors.birthday}</StyledText>
          )}
          {showDatePicker && (
            <DateTimePicker
              value={formData.birthday}
              mode="date"
              display="default"
              onChange={(event, selectedDate) => {
                setShowDatePicker(false);
                if (selectedDate) {
                  setFormData(prev => ({ ...prev, birthday: selectedDate }));
                }
              }}
              maximumDate={new Date()}
            />
          )}
        </StyledView>

        <StyledView>
          <StyledText className="text-white/90 text-lg mb-2">Username</StyledText>
          <StyledView className="flex-row items-center bg-white/95 rounded-2xl px-4">
            <StyledText className="text-gray-500 mr-2 text-lg">@</StyledText>
            <StyledTextInput
              className="flex-1 h-[50px] text-gray-800 text-lg"
              placeholder="username"
              value={formData.username}
              onChangeText={(text) => {
                setFormData(prev => ({ ...prev, username: text }));
                checkUsername(text);
              }}
              autoCapitalize="none"
            />
          </StyledView>
          {errors.username && (
            <StyledText className="text-red-400 text-sm mt-2">{errors.username}</StyledText>
          )}
          {usernameAvailable !== null && (
            <StyledText className={`text-sm mt-2 ${usernameAvailable ? 'text-green-400' : 'text-red-400'}`}>
              {usernameAvailable ? '✓ Username available!' : '✗ Username taken'}
            </StyledText>
          )}
        </StyledView>
      </StyledView>
    </Animated.View>
  );
}; 