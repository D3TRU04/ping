// SignupScreen.tsx
import React, { useState } from 'react';
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
} from 'react-native';
import { supabase } from '../../../lib/supabase';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { styled } from 'nativewind';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);
const StyledScrollView = styled(ScrollView);
const StyledImage = styled(Image);

type RootStackParamList = {
  SignUp: undefined;
  Home: undefined;
  SignIn: undefined;
  Startup: undefined;
  Onboarding: undefined;
};

type SignUpScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'SignUp'>;

export default function SignUpScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigation = useNavigation<SignUpScreenNavigationProp>();

  async function signUpWithEmail() {
    setLoading(true);
    try {
      const { data: { session }, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: 'ping://onboarding',
        },
      });

      if (error) {
        Alert.alert('Error signing up', error.message);
      } else if (!session) {
        Alert.alert(
          'Verification Email Sent',
          'Please check your email to verify your account. After verification, you will be redirected to complete your profile.',
          [
            {
              text: 'OK',
              onPress: () => navigation.navigate('Startup'),
            },
          ]
        );
      }
    } catch (error) {
      console.error('Error:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  }

  async function signInWithOAuth(provider: 'google' | 'facebook' | 'azure') {
    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider,
        options: {
          redirectTo: 'ping://onboarding',
        },
      });
      if (error) {
        console.error(`Error with ${provider} sign in:`, error);
        Alert.alert(`Error with ${provider} sign in`, error.message);
      }
    } catch (error) {
      console.error('Error:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    }
  }

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

        {/* Temporary Onboarding Test Button - top right corner for testing */}
        <StyledTouchableOpacity
          className="absolute top-12 right-6 z-10 bg-[#E74C3C] rounded-full p-2 shadow-lg"
          onPress={() => navigation.navigate('Onboarding')}
        >
          <StyledText className="text-white text-xs font-bold">Test Onboarding</StyledText>
        </StyledTouchableOpacity>

        <StyledScrollView
          className=""
          contentContainerStyle={{ flex: 1, justifyContent: 'center', paddingHorizontal: 20 }}
        >
          <StyledView className="items-center mb-10">
            <StyledImage 
              source={require('../../assets/logo.png')} 
              className="w-[250px] h-[250px] mb-1"
              resizeMode="contain"
            />
          </StyledView>

          <StyledView className="mb-8">
            <StyledView className="flex-row items-center bg-white/90 rounded-xl mb-4 px-4">
              <Icon name="email" size={20} color="#666" style={{ marginRight: 10 }} />
              <StyledTextInput
                className="flex-1 h-[50px] text-gray-800 text-base"
                placeholder="Email"
                placeholderTextColor="#666"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
              />
            </StyledView>

            <StyledView className="flex-row items-center bg-white/90 rounded-xl mb-4 px-4">
              <Icon name="lock" size={20} color="#666" style={{ marginRight: 10 }} />
              <StyledTextInput
                className="flex-1 h-[50px] text-gray-800 text-base"
                placeholder="Password"
                placeholderTextColor="#666"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
                autoCapitalize="none"
              />
            </StyledView>

            <StyledTouchableOpacity
              className="bg-[#E74C3C] rounded-xl p-4 items-center shadow-lg"
              onPress={signUpWithEmail}
              disabled={loading}
            >
              <StyledText className="text-[#FFF6E3] text-base font-bold">
                {loading ? 'Creating Account...' : 'Create Account'}
              </StyledText>
            </StyledTouchableOpacity>
          </StyledView>

          <StyledView className="flex-row items-center my-5">
            <StyledView className="flex-1 h-[1px] bg-white/30" />
            <StyledText className="text-white mx-2.5 opacity-80">OR</StyledText>
            <StyledView className="flex-1 h-[1px] bg-white/30" />
          </StyledView>

          <StyledView className="space-y-4">
            <StyledTouchableOpacity
              className="flex-row items-center justify-center bg-[#4285F4] rounded-xl p-4 shadow-lg"
              onPress={() => signInWithOAuth('google')}
            >
              <Icon name="g-translate" size={24} color="#FFFFFF" />
              <StyledText className="text-white text-base font-bold ml-2.5">Continue with Google</StyledText>
            </StyledTouchableOpacity>

            <StyledTouchableOpacity
              className="flex-row items-center justify-center bg-[#1877F2] rounded-xl p-4 shadow-lg"
              onPress={() => signInWithOAuth('facebook')}
            >
              <Icon name="facebook" size={24} color="#FFFFFF" />
              <StyledText className="text-white text-base font-bold ml-2.5">Continue with Facebook</StyledText>
            </StyledTouchableOpacity>
          </StyledView>

          <StyledView className="flex-row justify-center mt-8">
            <StyledText className="text-white text-sm">Already have an account? </StyledText>
            <StyledTouchableOpacity onPress={() => navigation.navigate('SignIn')}>
              <StyledText className="text-white text-sm font-bold underline">Sign in</StyledText>
            </StyledTouchableOpacity>
          </StyledView>
        </StyledScrollView>
      </StyledView>
    </KeyboardAvoidingView>
  );
}
