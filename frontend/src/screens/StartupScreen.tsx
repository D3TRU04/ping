import React from 'react';
import {
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  Image,
  Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { styled } from 'nativewind';
import { View, Text } from 'react-native';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledImage = styled(Image);
const StyledTouchableOpacity = styled(TouchableOpacity);

const logo = require('../assets/logo.png');

type RootStackParamList = {
  Startup: undefined;
  SignupScreen: undefined;
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
            <StyledTouchableOpacity
              className="bg-[#E74C3C] rounded-2xl py-4 px-16 items-center shadow-lg mb-8"
              onPress={() => navigation.navigate('SignupScreen')}
            >
              <StyledText className="text-[#FFF6E3] font-bold text-xl tracking-wider">
                Get Started
              </StyledText>
            </StyledTouchableOpacity>
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
