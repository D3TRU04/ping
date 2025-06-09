// SignInScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  ImageBackground,
  Dimensions,
  Image,
  Alert,
} from 'react-native';
import { supabase } from '../../../lib/supabase';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { LinearGradient } from 'expo-linear-gradient';
import { styled } from 'nativewind';

const { width, height } = Dimensions.get('window');

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledScrollView = styled(ScrollView);
const StyledTextInput = styled(TextInput);

type RootStackParamList = {
  SignIn: undefined;
  Home: undefined;
  SignUp: undefined;
  Startup: undefined;
};

type SignInScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'SignIn'>;

const ORANGE = '#FFA726';
const WHITE = '#FFFFFF';

export default function SignInScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigation = useNavigation<SignInScreenNavigationProp>();

  async function signInWithEmail() {
    setLoading(true);
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) {
      Alert.alert('Error signing in', error.message);
    } else if (data.session) {
      navigation.navigate('Home');
    }
    setLoading(false);
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
        <StyledScrollView
          className="flex-1 px-5"
          contentContainerStyle={{ flexGrow: 1, justifyContent: 'center' }}
        >
          <StyledView className="items-center mb-8">
            <Image 
              source={require('../../assets/logo.png')} 
              style={{ width: 250, height: 250, marginBottom: 12 }}
              resizeMode="contain"
            />
          </StyledView>

          <StyledView className="mb-[30px]">
            <StyledView className="flex-row items-center bg-white/90 rounded-xl px-4 mb-4">
              <Icon name="email" size={20} color="#666" style={{ marginRight: 10 }} />
              <StyledTextInput
                className="flex-1 h-[50px] text-gray-800 text-base font-system"
                placeholder="Email"
                placeholderTextColor="#666"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
              />
            </StyledView>

            <StyledView className="flex-row items-center bg-white/90 rounded-xl px-4 mb-4">
              <Icon name="lock" size={20} color="#666" style={{ marginRight: 10 }} />
              <StyledTextInput
                className="flex-1 h-[50px] text-gray-800 text-base font-system"
                placeholder="Password"
                placeholderTextColor="#666"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
                autoCapitalize="none"
              />
            </StyledView>

            <StyledTouchableOpacity
              className="self-end mb-5"
              onPress={() => console.log('Forgot password')}
            >
              <StyledText className="text-white text-sm font-medium font-system">
                Forgot Password?
              </StyledText>
            </StyledTouchableOpacity>

            <StyledTouchableOpacity
              className="bg-[#E74C3C] rounded-xl items-center py-2.5"
              style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.25, shadowRadius: 3.84, elevation: 5 }}
              onPress={signInWithEmail}
              disabled={loading}
            >
              <StyledText className="text-[#FFF6E3] text-base font-bold font-system">
                {loading ? 'Signing in...' : 'Sign In'}
              </StyledText>
            </StyledTouchableOpacity>
          </StyledView>

          <StyledView className="flex-row items-center my-[20px]">
            <StyledView className="flex-1 h-[1px] bg-white/20" />
            <StyledText className="mx-2.5 text-white opacity-80 font-system">
              OR
            </StyledText>
            <StyledView className="flex-1 h-[1px] bg-white/20" />
          </StyledView>

          <StyledView className="gap-[15px]">
            <StyledTouchableOpacity
              className="flex-row items-center justify-center bg-[#4285F4] rounded-xl py-2.5 gap-2.5"
              style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.25, shadowRadius: 3.84, elevation: 5 }}
              onPress={() => console.log('Google sign in')}
            >
              <Icon name="g-translate" size={24} color="#FFFFFF" style={{ alignSelf: 'center' }} />
              <StyledText className="text-white text-base font-bold font-system leading-none self-center" style={{ lineHeight: 16 }}>
                Continue with Google
              </StyledText>
            </StyledTouchableOpacity>

            <StyledTouchableOpacity
              className="flex-row items-center justify-center bg-[#1877F2] rounded-xl py-2.5 gap-2.5"
              style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.25, shadowRadius: 3.84, elevation: 5 }}
              onPress={() => console.log('Facebook sign in')}
            >
              <Icon name="facebook" size={24} color="#FFFFFF" style={{ alignSelf: 'center' }} />
              <StyledText className="text-white text-base font-bold font-system leading-none self-center" style={{ lineHeight: 16 }}>
                Continue with Facebook
              </StyledText>
            </StyledTouchableOpacity>
          </StyledView>

          <StyledView className="flex-row justify-center mt-[30px] mb-4">
            <StyledText className="text-white text-sm font-system">
              Don't have an account?{' '}
            </StyledText>
            <StyledTouchableOpacity onPress={() => navigation.navigate('SignUp')}>
              <StyledText className="text-white text-sm font-bold underline font-system">
                Sign up
              </StyledText>
            </StyledTouchableOpacity>
          </StyledView>
        </StyledScrollView>
      </StyledView>
    </KeyboardAvoidingView>
  );
}
