import React, { useState } from 'react';
import { View, Pressable, ScrollView } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import AppText from '../../../../components/AppText';
import { LinearGradient } from 'expo-linear-gradient';
import NotificationGroup from './components/NotificationGroup';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);

export default function NotificationsSettingsScreen() {
  const navigation = useNavigation();
  const [pushNotifications, setPushNotifications] = useState(true);
  const [emailNotifications, setEmailNotifications] = useState(false);
  const [messages, setMessages] = useState(true);
  const [placeRecommendations, setPlaceRecommendations] = useState(false);

  const generalNotifications = [
    {
      icon: 'notifications',
      label: 'Push Notifications',
      value: pushNotifications,
      onValueChange: setPushNotifications,
    },
    {
      icon: 'email',
      label: 'Email Notifications',
      value: emailNotifications,
      onValueChange: setEmailNotifications,
    },
  ];

  const appNotifications = [
    {
      icon: 'chat',
      label: 'Messages',
      value: messages,
      onValueChange: setMessages,
    },
    {
      icon: 'place',
      label: 'Place Recommendations',
      value: placeRecommendations,
      onValueChange: setPlaceRecommendations,
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
          <AppText className="text-lg font-semibold text-gray-900">Notifications</AppText>
          <StyledView className="w-8 h-8" />
        </StyledView>

        <ScrollView className="flex-1 px-4 py-6" showsVerticalScrollIndicator={false}>
          <NotificationGroup title="General" items={generalNotifications} />
          <NotificationGroup title="App Notifications" items={appNotifications} />
        </ScrollView>
      </StyledSafeAreaView>
    </LinearGradient>
  );
} 