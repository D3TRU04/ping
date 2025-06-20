import React from 'react';
import { View, Text, TouchableOpacity, Animated } from 'react-native';
import { styled } from 'nativewind';
import DateTimePicker from '@react-native-community/datetimepicker';
import { FormData } from '../types';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface BirthdayStepProps {
  formData: FormData;
  setFormData: (data: FormData | ((prev: FormData) => FormData)) => void;
  errors: Record<string, string>;
  showDatePicker: boolean;
  setShowDatePicker: (show: boolean) => void;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const BirthdayStep: React.FC<BirthdayStepProps> = ({
  formData,
  setFormData,
  errors,
  showDatePicker,
  setShowDatePicker,
  fadeAnim,
  slideAnim,
  scaleAnim,
}) => {
  const formatDate = (date: Date) => {
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

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
          <StyledText className="text-3xl">🎂</StyledText>
        </StyledView>
        <StyledText className="text-white text-3xl font-medium text-center">
          When's your birthday?
        </StyledText>
      </StyledView>

      <StyledView className="space-y-4">
        <StyledTouchableOpacity
          className="bg-white/95 rounded-2xl p-6"
          onPress={() => setShowDatePicker(true)}
        >
          <StyledText className="text-gray-800 text-xl text-center font-medium">
            {formatDate(formData.birthday)}
          </StyledText>
        </StyledTouchableOpacity>
        {errors.birthday && (
          <StyledText className="text-red-400 text-center text-sm">{errors.birthday}</StyledText>
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
    </Animated.View>
  );
}; 