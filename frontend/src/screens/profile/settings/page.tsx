import React from 'react';
import { View, Text, Pressable, ScrollView } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { supabase } from '../../../../lib/supabase';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);
const StyledText = styled(Text);

export default function SettingsScreen() {
  const navigation = useNavigation();

  const handleLogout = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) {
      console.error('Logout error:', error.message);
    } else {
      navigation.reset({
        index: 0,
        routes: [{ name: 'Startup' as never }],
      });
    }
  };

  const settingsOptions = [
    {
      icon: 'person',
      label: 'Account Info',
      onPress: () => navigation.navigate('EditAccount' as never),
    },
    { icon: 'notifications', label: 'Notifications', onPress: () => {} },
    { icon: 'lock', label: 'Privacy & Security', onPress: () => {} },
    { icon: 'palette', label: 'Appearance', onPress: () => {} },
    { icon: 'info', label: 'About Ping', onPress: () => {} },
    { icon: 'logout', label: 'Log Out', onPress: handleLogout },
  ];

  return (
    <StyledSafeAreaView className="flex-1 bg-[#FAF6F2]">
      <StyledView className="px-6 py-8">
        <Pressable onPress={() => navigation.goBack()} className="mb-4">
          <View className="flex-row items-center">
            <Icon name="arrow-back" size={24} color="#4B5563" />
            <Text className="ml-2 text-base text-gray-800">Back to Profile</Text>
          </View>
        </Pressable>

        <StyledText className="text-2xl font-bold text-gray-800 mb-6">Settings</StyledText>

        <ScrollView showsVerticalScrollIndicator={false}>
          {settingsOptions.map((item, index) => (
            <Pressable
              key={index}
              onPress={item.onPress}
              className="flex-row items-center justify-between py-4 border-b border-gray-200"
            >
              <View className="flex-row items-center">
                <Icon name={item.icon as any} size={24} color="#4B5563" />
                <Text className="ml-4 text-base text-gray-800">{item.label}</Text>
              </View>
              <Icon name="chevron-right" size={24} color="#9CA3AF" />
            </Pressable>
          ))}
        </ScrollView>
      </StyledView>
    </StyledSafeAreaView>
  );
}
