import React from 'react';
import { View, Pressable, ScrollView, Linking } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import AppText from '../../../../components/AppText';
import { LinearGradient } from 'expo-linear-gradient';
import AboutSection from './components/AboutSection';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);

export default function AboutPingScreen() {
  const navigation = useNavigation();
  const appVersion = '1.0.0';
  const buildNumber = '2024.1';

  const handleOpenLink = (url: string) => {
    Linking.openURL(url);
  };

  const supportItems = [
    {
      icon: 'help',
      label: 'Help Center',
      subtitle: 'Get help and find answers',
      onPress: () => handleOpenLink('https://ping-app.com/help'),
    },
    {
      icon: 'contact-support',
      label: 'Contact Support',
      subtitle: 'Get in touch with our team',
      onPress: () => handleOpenLink('mailto:support@ping-app.com'),
    },
    {
      icon: 'bug-report',
      label: 'Report a Bug',
      subtitle: 'Help us improve the app',
      onPress: () => handleOpenLink('https://ping-app.com/bug-report'),
    },
    {
      icon: 'feedback',
      label: 'Send Feedback',
      subtitle: 'Share your thoughts with us',
      onPress: () => handleOpenLink('https://ping-app.com/feedback'),
    },
  ];

  const legalItems = [
    {
      icon: 'privacy-tip',
      label: 'Privacy Policy',
      onPress: () => handleOpenLink('https://ping-app.com/privacy'),
    },
    {
      icon: 'description',
      label: 'Terms of Service',
      onPress: () => handleOpenLink('https://ping-app.com/terms'),
    },
    {
      icon: 'security',
      label: 'Data Protection',
      onPress: () => handleOpenLink('https://ping-app.com/data-protection'),
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
          <AppText className="text-lg font-semibold text-gray-900">About Ping</AppText>
          <StyledView className="w-8 h-8" />
        </StyledView>

        <ScrollView className="flex-1 px-4 py-6" showsVerticalScrollIndicator={false}>
          <StyledView className="mb-6">
            <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden p-6 items-center">
              <StyledView className="w-20 h-20 bg-[#1FC9C3] rounded-2xl items-center justify-center mb-4">
                <AppText className="text-white font-bold text-3xl">P</AppText>
              </StyledView>

              <AppText className="text-2xl font-bold text-gray-900 mb-2">Ping</AppText>
              <AppText className="text-base text-gray-600 text-center mb-4">
                Social discovery platform for finding and sharing local places and events
              </AppText>

              <StyledView className="flex-row space-x-6">
                <StyledView className="items-center">
                  <AppText className="text-sm text-gray-500">Version</AppText>
                  <AppText className="text-base font-semibold text-gray-900">{appVersion}</AppText>
                </StyledView>
                <StyledView className="items-center">
                  <AppText className="text-sm text-gray-500">Build</AppText>
                  <AppText className="text-base font-semibold text-gray-900">{buildNumber}</AppText>
                </StyledView>
              </StyledView>
            </StyledView>
          </StyledView>

          <AboutSection title="Support" items={supportItems} />
          <AboutSection title="Legal" items={legalItems} />
          
          <StyledView className="mb-6">
            <StyledView className="mb-3 px-2">
              <AppText className="text-sm font-medium text-gray-600">Credits</AppText>
            </StyledView>
            
            <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden p-4">
              <AppText className="text-sm text-gray-600 text-center leading-5">
                Built with ❤️ by the Ping team{'\n'}
                Powered by React Native & Expo{'\n'}
                Icons by Material Design{'\n'}
                © 2024 Ping App. All rights reserved.
              </AppText>
            </StyledView>
          </StyledView>
        </ScrollView>
      </StyledSafeAreaView>
    </LinearGradient>
  );
} 