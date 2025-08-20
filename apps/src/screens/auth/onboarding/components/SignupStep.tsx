import React, { useState } from 'react';
import {
  View,
  TouchableOpacity,
  TextInput,
  Alert,
  ActivityIndicator,
  Animated,
} from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import AppText from '../../../../components/AppText';
import { supabase } from '../../../../../lib/supabase';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);

interface SignupStepProps {
  onSignupSuccess: () => void;
  onBackToStartup: () => void;
  fadeAnim: any;
  slideAnim: any;
  scaleAnim: any;
}

export const SignupStep: React.FC<SignupStepProps> = ({
  onSignupSuccess,
  onBackToStartup,
  fadeAnim,
  slideAnim,
  scaleAnim,
}) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [currentQuestion, setCurrentQuestion] = useState<'email' | 'password'>('email');
  const [loading, setLoading] = useState(false);

  const handleEmailSubmit = () => {
    if (!email.trim()) {
      Alert.alert('Error', 'Please enter your email address');
      return;
    }
    if (!email.includes('@')) {
      Alert.alert('Error', 'Please enter a valid email address');
      return;
    }
    setCurrentQuestion('password');
  };

  const handlePasswordSubmit = async () => {
    if (!password.trim()) {
      Alert.alert('Error', 'Please enter a password');
      return;
    }
    if (password.length < 8) {
      Alert.alert('Error', 'Password must be at least 8 characters long');
      return;
    }

    setLoading(true);
    try {
      const { data, error } = await supabase.auth.signUp({
        email: email.trim(),
        password,
        options: {
          emailRedirectTo: 'ping://onboarding',
        },
      });

      if (error) {
        Alert.alert('Error signing up', error.message);
      } else {
        // Success - move to next step
        onSignupSuccess();
      }
    } catch (error) {
      Alert.alert('Error', 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  };

  const renderEmailQuestion = () => (
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
        <StyledView className="space-y-6 w-full max-w-[340px]">
          <StyledView className="flex-row items-center bg-white/95 rounded-2xl px-6 py-4">
            <Icon name="email" size={24} color="#666" style={{ marginRight: 12 }} />
            <StyledTextInput
              className="flex-1 text-gray-800 text-xl font-medium"
              placeholder="Enter your email address"
              placeholderTextColor="#9CA3AF"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              autoFocus
            />
          </StyledView>

          <StyledTouchableOpacity
            className="bg-white rounded-2xl p-6 items-center shadow-lg"
            onPress={handleEmailSubmit}
          >
            <AppText className="text-[#1FC9C3] text-xl font-bold">
              Continue
            </AppText>
          </StyledTouchableOpacity>
        </StyledView>
      </StyledView>
    </Animated.View>
  );

  const renderPasswordQuestion = () => (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }]
      }}
      className="flex-1 pt-6 px-4 space-y-8"
    >
      <StyledView className="w-full bg-transparent mb-2">
        <AppText className="text-white text-3xl font-medium text-left">
          Create a password
        </AppText>
        <StyledView className="w-full mt-2">
          <AppText className="text-white/80 text-base text-left max-w-[320px]">
            Choose a strong password to keep your account secure.
          </AppText>
        </StyledView>
      </StyledView>

      <StyledView className="flex-1 justify-center items-center w-full mb-16">
        <StyledView className="space-y-6 w-full max-w-[340px]">
          <StyledView className="flex-row items-center bg-white/95 rounded-2xl px-6 py-4">
            <Icon name="lock" size={24} color="#666" style={{ marginRight: 12 }} />
            <StyledTextInput
              className="flex-1 text-gray-800 text-xl font-medium"
              placeholder="Enter your password"
              placeholderTextColor="#9CA3AF"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
              autoCapitalize="none"
              autoFocus
            />
          </StyledView>

          <StyledTouchableOpacity
            className="bg-white rounded-2xl p-6 items-center shadow-lg"
            onPress={handlePasswordSubmit}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="#1FC9C3" />
            ) : (
              <AppText className="text-[#1FC9C3] text-xl font-bold">
                Create Account
              </AppText>
            )}
          </StyledTouchableOpacity>
        </StyledView>
      </StyledView>
    </Animated.View>
  );

  return (
    <LinearGradient
      colors={["#1FC9C3", "#1FC9C3", "#1FC9C3"]}
      className="flex-1"
    >
      {/* Back Button - positioned like other onboarding steps */}
      <StyledTouchableOpacity 
        className="absolute top-12 left-6 z-10 bg-black/20 rounded-full p-2"
        onPress={currentQuestion === 'email' ? onBackToStartup : () => setCurrentQuestion('email')}
      >
        <Icon name="arrow-back" size={24} color="#FFFFFF" />
      </StyledTouchableOpacity>

      {currentQuestion === 'email' ? renderEmailQuestion() : renderPasswordQuestion()}
    </LinearGradient>
  );
}; 