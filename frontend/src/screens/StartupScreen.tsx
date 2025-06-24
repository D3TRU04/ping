import React from 'react';
import {
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  Image,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { styled } from 'nativewind';
import { View, Text } from 'react-native';
import SignUpScreen from './auth/SignupScreen';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledImage = styled(Image);

const logo = require('../assets/logo.png');

type RootStackParamList = {
  Startup: undefined;
  SignUp: undefined;
  SignIn: undefined;
  Home: undefined;
};

type StartupScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Startup'>;

const StartupScreen = () => {
  const navigation = useNavigation<StartupScreenNavigationProp>();

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1, backgroundColor: '#FFA726' }}
    >
      <StyledView className="flex-1 bg-[#FFA726]">
        <StyledView className="flex-1 items-center">
          <StyledView className="flex-1 justify-center">
            <StyledImage 
              source={logo}
              className="w-96 h-96"
              resizeMode="contain"
            />
          </StyledView>
          <StyledView className="w-full items-center px-8 pb-12">
          <TouchableOpacity
              style={{
                backgroundColor: '#E74C3C',
                borderRadius: 16,
                paddingVertical: 18,
                paddingHorizontal: 64,
                alignItems: 'center',
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.08,
                shadowRadius: 8,
                elevation: 2,
                marginBottom: 32,
              }}
              onPress={() => navigation.navigate('SignUp')}
            >
              <StyledText className="text-[#FFF6E3] font-bold text-xl tracking-wider">
                Get Started
              </StyledText>
            </TouchableOpacity>
            <StyledText className="text-white text-xs text-center mt-3 opacity-100">
              By tapping 'Get Started', you agree to our Privacy Policy and Terms of Service.
            </StyledText>
          </StyledView>
        </StyledView>
      </StyledView>
    </KeyboardAvoidingView>
  );
};

export default StartupScreen;
