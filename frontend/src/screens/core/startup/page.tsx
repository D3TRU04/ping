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
import { View } from 'react-native';
import AppText from '../../../components/AppText';

const StyledView = styled(View);
const StyledImage = styled(Image);
const StyledTouchableOpacity = styled(TouchableOpacity);

const logo = require('../../../assets/logo/logo.png');

type RootStackParamList = {
  Startup: undefined;
  SignupScreen: undefined;
  SignIn: undefined;
  Home: undefined;
  Loading: undefined;
};

type StartupScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Startup'>;

const StartupScreen = () => {
  const navigation = useNavigation<StartupScreenNavigationProp>();

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1, backgroundColor: '#1FC9C3' }}
    >
      <StyledView className="flex-1 bg-[#1FC9C3]">
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
              className="bg-white rounded-2xl py-4 px-16 items-center shadow-lg mb-8"
              onPress={() => navigation.navigate('SignupScreen')}
            >
              <AppText className="text-[#1FC9C3] font-bold text-xl tracking-wider">
                Get Started
              </AppText>
            </StyledTouchableOpacity>
            
            {/* Temporary Test Button */}
            <StyledTouchableOpacity
              className="bg-yellow-400 rounded-2xl py-3 px-8 items-center shadow-lg mb-4"
              onPress={() => navigation.navigate('Loading')}
            >
              <AppText className="text-black font-bold text-lg">
                🧪 TEMP: Test Loading Screen
              </AppText>
            </StyledTouchableOpacity>
            
            <AppText className="text-white text-xs text-center mt-3 opacity-100">
              By tapping 'Get Started', you agree to our Privacy Policy and Terms of Service.
            </AppText>
          </StyledView>
        </StyledView>
      </StyledView>
    </KeyboardAvoidingView>
  );
};

export default StartupScreen;
