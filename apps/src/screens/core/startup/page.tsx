import React, { useState } from 'react';
import {
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  Image,
  Alert,
  Modal,
  View,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { RootStackParamList } from '../../../types/navigation';

const StyledView = styled(View);
const StyledImage = styled(Image);
const StyledTouchableOpacity = styled(TouchableOpacity);

const logo = require('../../../assets/logo/logo.png');

type StartupScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Startup'>;

const StartupScreen = () => {
  const navigation = useNavigation<StartupScreenNavigationProp>();
  const [showLoginModal, setShowLoginModal] = useState(false);

  const handleLoginOption = (option: 'apple' | 'google' | 'email') => {
    setShowLoginModal(false);
    switch (option) {
      case 'apple':
        // Handle Apple sign in
        break;
      case 'google':
        // Handle Google sign in
        break;
      case 'email':
        navigation.navigate('SignIn');
        break;
    }
  };

  return (
    <>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={{ flex: 1, backgroundColor: '#1FC9C3' }}
      >
        <StyledView className="flex-1 bg-[#1FC9C3]">
          <StyledView className="flex-1 items-center">
            <StyledView className="flex-[0.8] justify-end">
              <StyledImage 
                source={logo}
                className="w-96 h-96"
                resizeMode="contain"
              />
            </StyledView>
            
            {/* Main Buttons Container - Better spaced in bottom area */}
            <StyledView className="flex-[0.4] w-full items-center px-8 justify-end pb-8">
              {/* Get Started Button Container */}
              <StyledView className="w-full items-center mb-4">
                <StyledTouchableOpacity
                  className="bg-white rounded-2xl py-4 px-16 items-center shadow-lg"
                  onPress={() => navigation.navigate('Onboarding')}
                >
                  <AppText className="text-[#1FC9C3] font-bold text-xl tracking-wider">
                    Get Started
                  </AppText>
                </StyledTouchableOpacity>
              </StyledView>
              
              {/* Login Text Container */}
              <StyledView className="w-full items-center mb-8">
                <StyledTouchableOpacity
                  onPress={() => setShowLoginModal(true)}
                >
                  <AppText className="text-white text-base text-center">
                    Already have an account? Log in
                  </AppText>
                </StyledTouchableOpacity>
              </StyledView>
            </StyledView>
            
            {/* Privacy Policy Container - At the very bottom */}
            <StyledView className="w-full items-center px-8 pb-8">
              <AppText className="text-white text-xs text-center opacity-100">
                By tapping 'Get Started', you agree to our Privacy Policy and Terms of Service.
              </AppText>
            </StyledView>
          </StyledView>
        </StyledView>
      </KeyboardAvoidingView>

      {/* Login Modal */}
      <Modal
        visible={showLoginModal}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setShowLoginModal(false)}
      >
        <StyledView className="flex-1 bg-black/50 justify-end">
          <StyledView className="bg-white rounded-t-3xl p-6">
            {/* Header */}
            <StyledView className="relative items-center mb-6">
              <AppText className="text-2xl font-bold text-black">
                Sign In
              </AppText>
              <StyledTouchableOpacity
                onPress={() => setShowLoginModal(false)}
                className="absolute right-0 -top-1 p-2"
              >
                <Icon name="close" size={24} color="#000" />
              </StyledTouchableOpacity>
            </StyledView>

            {/* Login Options */}
            <StyledView className="space-y-4 mb-4">
              <StyledTouchableOpacity
                className="bg-black rounded-3xl py-4 px-5 flex-row items-center justify-center"
                onPress={() => handleLoginOption('apple')}
              >
                <StyledView className="w-8 h-8 items-center justify-center mr-4">
                  <Icon name="apple" size={24} color="#FFFFFF" />
                </StyledView>
                <AppText className="text-white text-lg font-semibold">
                  Sign in with Apple
                </AppText>
              </StyledTouchableOpacity>

              <StyledTouchableOpacity
                className="bg-white border border-[#1FC9C3] rounded-3xl py-4 px-5 flex-row items-center justify-center"
                onPress={() => handleLoginOption('google')}
              >
                <StyledView className="w-8 h-8 items-center justify-center mr-4">
                  <AppText className="text-[#4285F4] text-2xl font-bold leading-none">
                    G
                  </AppText>
                </StyledView>
                <AppText className="text-[#1FC9C3] text-lg font-semibold">
                  Sign in with Google
                </AppText>
              </StyledTouchableOpacity>

              <StyledTouchableOpacity
                className="bg-white border border-[#1FC9C3] rounded-3xl py-4 px-5 flex-row items-center justify-center"
                onPress={() => handleLoginOption('email')}
              >
                <StyledView className="w-8 h-8 items-center justify-center mr-4">
                  <Icon name="email" size={24} color="#1FC9C3" />
                </StyledView>
                <AppText className="text-[#1FC9C3] text-lg font-semibold">
                  Continue with email
                </AppText>
              </StyledTouchableOpacity>
            </StyledView>

            {/* Terms */}
            <StyledView className="items-center mb-4">
              <AppText className="text-gray-600 text-sm text-center">
                By continuing you agree to Ping's{' '}
                <AppText className="text-[#1FC9C3] underline">Terms and Conditions</AppText>
                {' '}and{' '}
                <AppText className="text-[#1FC9C3] underline">Privacy Policy</AppText>
              </AppText>
            </StyledView>
          </StyledView>
        </StyledView>
      </Modal>
    </>
  );
};

export default StartupScreen;
