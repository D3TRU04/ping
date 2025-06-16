import React from 'react';
import { View, Text, Pressable, ScrollView } from 'react-native';
import { styled } from 'nativewind';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { SafeAreaView } from 'react-native-safe-area-context';
import BottomNavBar from '../../components/BottomNavBar';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
// import { RootStackParamList } from '../../types'; // Adjust path if needed

// NativeWind styled components
const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);
const StyledText = styled(Text);

// Props from navigation
// type Props = NativeStackScreenProps<RootStackParamList, 'SettingsScreen'>;

export default function SettingsScreen() {
//   const { currentUser } = route.params;i

  const settingsOptions = [
    { icon: 'person', label: 'Account Info', onPress: () => {} },
    { icon: 'notifications', label: 'Notifications', onPress: () => {} },
    { icon: 'lock', label: 'Privacy & Security', onPress: () => {} },
    { icon: 'palette', label: 'Appearance', onPress: () => {} },
    { icon: 'info', label: 'About Ping', onPress: () => {} },
    { icon: 'logout', label: 'Log Out', onPress: () => {} },
  ];

  return (
    <StyledSafeAreaView className="flex-1 bg-[#FAF6F2]">
      <StyledView className="px-6 py-8">
        <StyledText className="text-2xl font-bold text-gray-800 mb-6">Settings</StyledText>

        <ScrollView showsVerticalScrollIndicator={false}>
          {settingsOptions.map((item, index) => (
            <Pressable
              key={index}
              onPress={item.onPress}
              className="flex-row items-center justify-between py-4 border-b border-gray-200"
            >
              <View className="flex-row items-center">
                <Icon name={item.icon} size={24} color="#4B5563" />
                <Text className="ml-4 text-base text-gray-800">{item.label}</Text>
              </View>
              <Icon name="chevron-right" size={24} color="#9CA3AF" />
            </Pressable>
          ))}
        </ScrollView>
      </StyledView>

      {/* <BottomNavBar currentUser={currentUser} /> */}
    </StyledSafeAreaView>
  );
}
