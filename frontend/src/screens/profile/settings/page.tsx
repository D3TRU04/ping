import React from 'react';
import { View, Pressable, ScrollView } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { supabase } from '../../../../lib/supabase';
import AppText from '../../../components/AppText';
import { LinearGradient } from 'expo-linear-gradient';
import SettingsTopNavBar from './components/Settings';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);

export default function SettingsScreen() {
  const navigation = useNavigation();

  const handleLogout = async () => {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) {
        // Handle error silently
      } else {
        navigation.reset({
          index: 0,
          routes: [{ name: 'Startup' as never }],
        });
      }
    } catch (error) {
      // Handle error silently
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
    <LinearGradient
      colors={["#FAF6F2", "#F5F5F5"]}
      style={{ flex: 1 }}
    >
      <StyledSafeAreaView className="flex-1 bg-white">
        <SettingsTopNavBar />
        <StyledView className="px-6 py-8">
          {/* Settings Options */}
          <StyledView className="bg-white rounded-2xl shadow-lg overflow-hidden mt-2">
            {settingsOptions.map((item, index) => (
              <Pressable
                key={index}
                onPress={item.onPress}
                className={`flex-row items-center justify-between px-6 py-5 ${
                  index !== settingsOptions.length - 1 ? 'border-b border-gray-100' : ''
                }`}
                style={{ elevation: 1, borderRadius: 16 }}
              >
                <StyledView className="flex-row items-center">
                  <StyledView className="w-11 h-11 bg-[#1FC9C3]/10 rounded-full items-center justify-center mr-4">
                    <Icon name={item.icon as any} size={22} color="#1FC9C3" />
                  </StyledView>
                  <AppText className="text-lg text-gray-900" style={{ fontFamily: 'Satoshi-Medium' }}>
                    {item.label}
                  </AppText>
                </StyledView>
                <Icon name="chevron-right" size={26} color="#1FC9C3" />
              </Pressable>
            ))}
          </StyledView>
        </StyledView>
      </StyledSafeAreaView>
    </LinearGradient>
  );
}
