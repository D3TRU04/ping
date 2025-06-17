import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  TextInput,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
  Image,
  ActivityIndicator,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { styled } from 'nativewind';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { supabase } from '../../../lib/supabase';
import * as ImagePicker from 'expo-image-picker';
import DateTimePicker from '@react-native-community/datetimepicker';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);
const StyledScrollView = styled(ScrollView);
const StyledImage = styled(Image);

type RootStackParamList = {
  Onboarding: undefined;
  Home: undefined;
  Startup: undefined;
};

type OnboardingScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Onboarding'>;

export default function OnboardingScreen() {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    fullName: '',
    birthday: new Date(),
    username: '',
    phoneNumber: '',
    profilePicture: null as string | null,
  });
  const [loading, setLoading] = useState(false);
  const [usernameAvailable, setUsernameAvailable] = useState<boolean | null>(null);
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const navigation = useNavigation<OnboardingScreenNavigationProp>();
  const hasNavigatedRef = useRef(false);

  const validateStep = () => {
    const newErrors: Record<string, string> = {};
    
    switch (step) {
      case 1:
        if (!formData.fullName.trim()) {
          newErrors.fullName = 'Full name is required';
        }
        break;
      case 2:
        const age = new Date().getFullYear() - formData.birthday.getFullYear();
        if (age < 13) {
          newErrors.birthday = 'You must be at least 13 years old';
        }
        break;
      case 3:
        if (!formData.username.trim()) {
          newErrors.username = 'Username is required';
        } else if (formData.username.length < 3) {
          newErrors.username = 'Username must be at least 3 characters';
        } else if (!/^[a-zA-Z0-9_]+$/.test(formData.username)) {
          newErrors.username = 'Username can only contain letters, numbers, and underscores';
        }
        break;
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const pickImage = async () => {
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.5,
      });

      if (!result.canceled) {
        setFormData(prev => ({ ...prev, profilePicture: result.assets[0].uri }));
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to pick image. Please try again.');
    }
  };

  const checkUsername = async (username: string) => {
    if (username.length < 3) {
      setUsernameAvailable(null);
      return;
    }

    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('username')
        .eq('username', username)
        .single();

      setUsernameAvailable(!data);
    } catch (error) {
      console.error('Error checking username:', error);
    }
  };

  const handleSubmit = async () => {
    if (hasNavigatedRef.current) return;
    console.log('Onboarding handleSubmit called');
    if (!validateStep()) {
      Alert.alert('Error', 'Please fill in all required fields correctly.');
      return;
    }

    setLoading(true);
    try {
      // Get the current session first
      const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      
      if (sessionError) {
        console.error('Session error:', sessionError);
        throw new Error('Failed to get session');
      }

      if (!session?.user) {
        console.error('No active session found');
        throw new Error('No active session found. Please sign in again.');
      }

      const user = session.user;
      console.log('User found:', user.id);

      let profilePictureUrl = null;
      if (formData.profilePicture) {
        const response = await fetch(formData.profilePicture);
        const blob = await response.blob();
        const fileExt = formData.profilePicture.split('.').pop();
        const fileName = `${user.id}-${Date.now()}.${fileExt}`;
        const { error: uploadError } = await supabase.storage
          .from('profile-pictures')
          .upload(fileName, blob);
        if (uploadError) {
          console.error('Profile picture upload error:', uploadError);
          throw uploadError;
        }
        profilePictureUrl = `${supabase.storage.from('profile-pictures').getPublicUrl(fileName).data.publicUrl}`;
      }

      const { error: upsertError } = await supabase
        .from('profiles')
        .upsert({
          id: user.id,
          full_name: formData.fullName,
          display_name: formData.fullName,
          birthday: formData.birthday.toISOString(),
          username: formData.username,
          phone_number: formData.phoneNumber || null,
          avatar_url: profilePictureUrl,
          has_onboarded: true,
        });

      if (upsertError) {
        console.error('Supabase upsert error:', upsertError);
        throw new Error(upsertError.message || 'Failed to update profile');
      }

      console.log('Profile updated successfully');
      hasNavigatedRef.current = true;
      navigation.navigate('Home');
    } catch (error) {
      console.error('Error updating profile:', error);
      Alert.alert(
        'Error',
        error instanceof Error 
          ? error.message 
          : 'Failed to update profile. Please try again.'
      );
      
      // If there's an authentication error, navigate back to startup
      if (error instanceof Error && error.message.includes('session')) {
        navigation.navigate('Startup');
      }
    } finally {
      setLoading(false);
    }
  };

  const renderStep = () => {
    switch (step) {
      case 1:
        return (
          <StyledView className="space-y-6">
            <StyledText className="text-white text-3xl font-bold text-center">What's your name?</StyledText>
            <StyledView className="space-y-2">
              <StyledTextInput
                className="bg-white/90 rounded-xl p-4 text-gray-800 text-lg"
                placeholder="Full Name"
                value={formData.fullName}
                onChangeText={(text) => setFormData(prev => ({ ...prev, fullName: text }))}
              />
              {errors.fullName && (
                <StyledText className="text-red-400 text-sm text-center">{errors.fullName}</StyledText>
              )}
            </StyledView>
          </StyledView>
        );
      case 2:
        return (
          <StyledView className="space-y-6">
            <StyledText className="text-white text-3xl font-bold text-center">When's your birthday?</StyledText>
            <StyledView className="space-y-2">
              <StyledTouchableOpacity
                className="bg-white/90 rounded-xl p-4"
                onPress={() => setShowDatePicker(true)}
              >
                <StyledText className="text-gray-800 text-lg text-center">
                  {formData.birthday.toLocaleDateString()}
                </StyledText>
              </StyledTouchableOpacity>
              {errors.birthday && (
                <StyledText className="text-red-400 text-sm text-center">{errors.birthday}</StyledText>
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
          </StyledView>
        );
      case 3:
        return (
          <StyledView className="space-y-6">
            <StyledText className="text-white text-3xl font-bold text-center">Choose a username</StyledText>
            <StyledView className="space-y-2">
              <StyledView className="flex-row items-center bg-white/90 rounded-xl px-4">
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
                <StyledText className="text-red-400 text-sm text-center">{errors.username}</StyledText>
              )}
              {usernameAvailable !== null && (
                <StyledText className={`text-sm text-center ${usernameAvailable ? 'text-green-400' : 'text-red-400'}`}>
                  {usernameAvailable ? 'Username available!' : 'Username taken'}
                </StyledText>
              )}
            </StyledView>
          </StyledView>
        );
      case 4:
        return (
          <StyledView className="space-y-6">
            <StyledText className="text-white text-3xl font-bold text-center">Optional Information</StyledText>
            <StyledView className="space-y-6">
              <StyledView>
                <StyledText className="text-white/80 text-lg mb-2 text-center">Phone Number (optional)</StyledText>
                <StyledTextInput
                  className="bg-white/90 rounded-xl p-4 text-gray-800 text-lg"
                  placeholder="+1 (555) 555-5555"
                  value={formData.phoneNumber}
                  onChangeText={(text) => setFormData(prev => ({ ...prev, phoneNumber: text }))}
                  keyboardType="phone-pad"
                />
              </StyledView>
              <StyledView>
                <StyledText className="text-white/80 text-lg mb-2 text-center">Profile Picture (optional)</StyledText>
                <StyledTouchableOpacity
                  className="bg-white/90 rounded-xl p-4 items-center"
                  onPress={pickImage}
                >
                  <StyledText className="text-gray-800 text-lg">
                    {formData.profilePicture ? 'Change Profile Picture' : 'Add Profile Picture'}
                  </StyledText>
                </StyledTouchableOpacity>
                {formData.profilePicture && (
                  <StyledImage
                    source={{ uri: formData.profilePicture }}
                    className="w-32 h-32 rounded-full self-center mt-4"
                  />
                )}
              </StyledView>
            </StyledView>
          </StyledView>
        );
      default:
        return null;
    }
  };

  const isStepValid = () => {
    return validateStep();
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1, backgroundColor: '#FFA726' }}
    >
      <StyledView className="flex-1 bg-[#FFA726]">
        <StyledTouchableOpacity 
          className="absolute top-12 left-6 z-10 bg-black/8 rounded-full p-1.5"
          onPress={() => navigation.navigate('Startup')}
        >
          <Icon name="arrow-back" size={28} color="#FFFFFF" />
        </StyledTouchableOpacity>

        <StyledScrollView
          className="flex-1"
          contentContainerStyle={{ 
            flexGrow: 1,
            justifyContent: 'center',
            paddingHorizontal: 20,
            paddingVertical: 20
          }}
        >
          <StyledView className="flex-1 justify-center">
            {renderStep()}

            <StyledView className="flex-row justify-between mt-8">
              {step > 1 && (
                <StyledTouchableOpacity
                  className="bg-white/20 rounded-xl p-4 flex-1 mr-2"
                  onPress={() => setStep(prev => prev - 1)}
                >
                  <StyledText className="text-white text-center font-bold">Back</StyledText>
                </StyledTouchableOpacity>
              )}
              <StyledTouchableOpacity
                className={`${step > 1 ? 'flex-1 ml-2' : 'w-full'} bg-[#E74C3C] rounded-xl p-4`}
                onPress={() => {
                  if (step < 4) {
                    const isValid = validateStep();
                    if (isValid) {
                      setStep(prev => prev + 1);
                    } else {
                      Alert.alert('Error', 'Please fill in all required fields correctly.');
                    }
                  } else {
                    handleSubmit();
                  }
                }}
                disabled={loading || (step === 3 && !usernameAvailable)}
              >
                {loading ? (
                  <ActivityIndicator color="#FFFFFF" />
                ) : (
                  <StyledText className="text-white text-center font-bold">
                    {step === 4 ? 'Complete' : 'Next'}
                  </StyledText>
                )}
              </StyledTouchableOpacity>
            </StyledView>

            {step === 4 && (
              <StyledTouchableOpacity
                className="mt-4 bg-white/20 rounded-xl p-4"
                onPress={handleSubmit}
                disabled={loading}
              >
                <StyledText className="text-white text-center font-bold">Skip Optional Fields</StyledText>
              </StyledTouchableOpacity>
            )}
          </StyledView>
        </StyledScrollView>
      </StyledView>
    </KeyboardAvoidingView>
  );
} 