import React, { useState } from 'react';
import { View, Pressable, ScrollView } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import AppText from '../../../../components/AppText';
import { LinearGradient } from 'expo-linear-gradient';
import AppearanceGroup from './components/AppearanceGroup';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);

export default function AppearanceSettingsScreen() {
  const navigation = useNavigation();
  const [darkMode, setDarkMode] = useState(false);
  const [reducedMotion, setReducedMotion] = useState(false);
  const [largeText, setLargeText] = useState(false);
  const [highContrast, setHighContrast] = useState(false);
  const [colorBlindMode, setColorBlindMode] = useState(false);

  const themeItems = [
    {
      icon: 'dark-mode',
      label: 'Dark Mode',
      subtitle: 'Use dark theme',
      value: darkMode,
      onValueChange: setDarkMode,
    },
    {
      icon: 'palette',
      label: 'Accent Color',
      subtitle: 'Customize app colors',
      value: false,
      onValueChange: () => {},
    },
  ];

  const accessibilityItems = [
    {
      icon: 'text-fields',
      label: 'Large Text',
      subtitle: 'Increase text size',
      value: largeText,
      onValueChange: setLargeText,
    },
    {
      icon: 'contrast',
      label: 'High Contrast',
      subtitle: 'Increase contrast',
      value: highContrast,
      onValueChange: setHighContrast,
    },
    {
      icon: 'visibility',
      label: 'Color Blind Mode',
      subtitle: 'Color blind friendly',
      value: colorBlindMode,
      onValueChange: setColorBlindMode,
    },
  ];

  const animationItems = [
    {
      icon: 'animation',
      label: 'Reduced Motion',
      subtitle: 'Minimize animations',
      value: reducedMotion,
      onValueChange: setReducedMotion,
    },
  ];

  return (
    <LinearGradient colors={["#FAF6F2", "#F5F5F5"]} style={{ flex: 1 }}>
      <StyledSafeAreaView className="flex-1 bg-white">
        <StyledView className="w-full flex-row items-center justify-between px-4 py-3 bg-white border-b border-gray-100">
          <Pressable 
            onPress={() => navigation.goBack()} 
            className="w-8 h-8 rounded-lg bg-transparent items-center justify-center"
            style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}
          >
            <Icon name="arrow-back" size={20} color="#1FC9C3" />
          </Pressable>
          <AppText className="text-lg font-semibold text-gray-900">Appearance</AppText>
          <StyledView className="w-8 h-8" />
        </StyledView>

        <ScrollView className="flex-1 px-4 py-6" showsVerticalScrollIndicator={false}>
          <AppearanceGroup title="Theme" items={themeItems} />
          <AppearanceGroup title="Accessibility" items={accessibilityItems} />
          <AppearanceGroup title="Animation" items={animationItems} />
          
          <StyledView className="mb-6">
            <StyledView className="mb-3 px-2">
              <AppText className="text-sm font-medium text-gray-600">Preview</AppText>
            </StyledView>
            
            <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden p-4">
              <StyledView className="flex-row items-center mb-3">
                <StyledView className="w-12 h-12 bg-[#1FC9C3] rounded-full items-center justify-center mr-3">
                  <AppText className="text-white font-bold text-lg">P</AppText>
                </StyledView>
                <StyledView>
                  <AppText className={`text-base font-semibold ${largeText ? 'text-lg' : ''} ${highContrast ? 'text-black' : 'text-gray-900'}`}>
                    Profile Preview
                  </AppText>
                  <AppText className={`text-sm ${largeText ? 'text-base' : ''} ${highContrast ? 'text-gray-800' : 'text-gray-500'}`}>
                    This is how your profile will look
                  </AppText>
                </StyledView>
              </StyledView>
              
              <StyledView className="flex-row space-x-2">
                <StyledView className="flex-1 h-2 bg-[#1FC9C3] rounded-full" />
                <StyledView className="flex-1 h-2 bg-gray-200 rounded-full" />
                <StyledView className="flex-1 h-2 bg-gray-200 rounded-full" />
              </StyledView>
            </StyledView>
          </StyledView>
        </ScrollView>
      </StyledSafeAreaView>
    </LinearGradient>
  );
} 