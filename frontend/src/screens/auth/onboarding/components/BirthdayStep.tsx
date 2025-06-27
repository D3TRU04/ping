import React from 'react';
import { View, TouchableOpacity, Animated, Platform, Modal, TouchableWithoutFeedback } from 'react-native';
import { styled } from 'nativewind';
import DateTimePicker from '@react-native-community/datetimepicker';
import { FormData } from '../types';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
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
      className="flex-1 pt-6 px-4 space-y-8"
    >
      <StyledView className="w-full bg-transparent mb-2">
        <AppText className="text-white text-3xl font-medium text-left">
          When's your birthday?
        </AppText>
        <StyledView className="w-full mt-2">
          <AppText className="text-white/80 text-base text-left max-w-[320px]">
            Your birthday helps us verify your age and provide age-appropriate content.
          </AppText>
        </StyledView>
      </StyledView>

      <StyledView className="flex-1 justify-center items-center w-full mb-16">
        <StyledTouchableOpacity
          style={{ width: 340 }}
          className="bg-white/95 rounded-2xl p-6 flex-row items-center border-2 border-transparent shadow-md"
          onPress={() => setShowDatePicker(true)}
          activeOpacity={0.8}
        >
          <AppText className="text-gray-800 text-xl text-center font-medium flex-1">
            {formatDate(formData.birthday)}
          </AppText>
          <Icon name="calendar-today" size={24} color={COLORS.mint} style={{ marginLeft: 12 }} />
        </StyledTouchableOpacity>
        {errors.birthday && (
          <AppText className="text-red-400 text-center text-sm mt-4">{errors.birthday}</AppText>
        )}
        {/* Custom Modal for Date Picker */}
        {Platform.OS === 'ios' ? (
          <Modal
            visible={showDatePicker}
            transparent
            animationType="fade"
            onRequestClose={() => setShowDatePicker(false)}
          >
            <TouchableWithoutFeedback onPress={() => setShowDatePicker(false)}>
              <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.3)', justifyContent: 'center', alignItems: 'center' }}>
                <TouchableWithoutFeedback>
                  <View style={{ backgroundColor: 'white', borderRadius: 24, padding: 24, minWidth: 340, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.18, shadowRadius: 12, elevation: 8 }}>
                    <AppText style={{ fontSize: 20, fontWeight: '600', color: '#222', textAlign: 'center', marginBottom: 12 }}>Select Birthday</AppText>
                    <View style={{ height: 1, backgroundColor: COLORS.mint + '20', marginBottom: 16 }} />
                    <DateTimePicker
                      value={formData.birthday}
                      mode="date"
                      display="spinner"
                      onChange={(_event, selectedDate) => {
                        if (_event.type === 'set' && selectedDate) {
                          setFormData(prev => ({ ...prev, birthday: selectedDate }));
                        }
                      }}
                      maximumDate={new Date()}
                      style={{ marginBottom: 12 }}
                    />
                    <TouchableOpacity
                      style={{ backgroundColor: COLORS.mint, borderRadius: 12, paddingVertical: 12, marginTop: 8 }}
                      onPress={() => setShowDatePicker(false)}
                      activeOpacity={0.85}
                    >
                      <AppText style={{ color: 'white', fontWeight: 'bold', fontSize: 16, textAlign: 'center' }}>Done</AppText>
                    </TouchableOpacity>
                  </View>
                </TouchableWithoutFeedback>
              </View>
            </TouchableWithoutFeedback>
          </Modal>
        ) : (
          showDatePicker && (
            <DateTimePicker
              value={formData.birthday}
              mode="date"
              display="default"
              onChange={(_event, selectedDate) => {
                setShowDatePicker(false);
                if (selectedDate) {
                  setFormData(prev => ({ ...prev, birthday: selectedDate }));
                }
              }}
              maximumDate={new Date()}
            />
          )
        )}
      </StyledView>
    </Animated.View>
  );
}; 