import React, { useState } from 'react';
import { View, Pressable, ScrollView, ActivityIndicator } from 'react-native';
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
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const handleLogout = async () => {
    if (isLoggingOut) return; // Prevent multiple logout attempts
    
    setIsLoggingOut(true);
    
    try {
      // Immediately clear navigation to prevent showing intermediate screens
      navigation.reset({
        index: 0,
        routes: [{ name: 'Startup' as never }],
      });
      
      // Small delay to ensure navigation reset is complete
      await new Promise(resolve => setTimeout(resolve, 100));
      
      // Then sign out from Supabase
      const { error } = await supabase.auth.signOut();
      if (error) {
        console.error('Logout error:', error);
      }
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      setIsLoggingOut(false);
    }
  };

  const settingsSections = [
    {
      title: 'Account',
      items: [
    {
      icon: 'person',
      label: 'Account Info',
          onPress: () => navigation.navigate('AccountInfo' as never),
    },
        {
          icon: 'notifications',
          label: 'Notifications',
          onPress: () => navigation.navigate('NotificationsSettings' as never),
        },
      ],
    },
    {
      title: 'Privacy & Security',
      items: [
        {
          icon: 'lock',
          label: 'Privacy & Security',
          onPress: () => navigation.navigate('PrivacySecurity' as never),
        },
        {
          icon: 'palette',
          label: 'Appearance',
          onPress: () => navigation.navigate('AppearanceSettings' as never),
        },
      ],
    },
    {
      title: 'Support',
      items: [
        {
          icon: 'info',
          label: 'About Ping',
          onPress: () => navigation.navigate('AboutPing' as never),
        },
      ],
    },
  ];

  return (
    <LinearGradient
      colors={["#FAF6F2", "#F5F5F5"]}
      style={{ flex: 1 }}
    >
      <StyledSafeAreaView className="flex-1 bg-white">
        <SettingsTopNavBar />
        <ScrollView className="flex-1 px-4 py-6" showsVerticalScrollIndicator={false}>
          {/* Settings Sections */}
          {settingsSections.map((section, sectionIndex) => (
            <StyledView key={sectionIndex} className="mb-6">
              {/* Section Header */}
              <StyledView className="mb-3 px-2">
                <AppText className="text-sm font-medium text-gray-600">
                  {section.title}
                </AppText>
              </StyledView>
              
              {/* Section Items */}
              <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden">
                {section.items.map((item, itemIndex) => (
                  <Pressable
                    key={itemIndex}
                    onPress={item.onPress}
                    className={`flex-row items-center px-4 py-3 ${
                      itemIndex !== section.items.length - 1 ? 'border-b border-gray-100' : ''
                    }`}
                    style={({ pressed }) => [
                      {
                        opacity: pressed ? 0.7 : 1,
                      },
                    ]}
                  >
                    <StyledView className="w-8 h-8 bg-[#1FC9C3]/10 rounded-lg items-center justify-center mr-3">
                      <Icon name={item.icon as any} size={18} color="#1FC9C3" />
                    </StyledView>
                    <AppText className="text-base text-gray-900 flex-1">
                      {item.label}
                    </AppText>
                    <Icon name="chevron-right" size={18} color="#D1D5DB" />
                  </Pressable>
                ))}
              </StyledView>
            </StyledView>
          ))}

          {/* Logout Section */}
          <StyledView className="mb-6">
            <StyledView className="mb-3 px-2">
              <AppText className="text-sm font-medium text-gray-600">
                Account
              </AppText>
            </StyledView>
            
            <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden">
              <Pressable
                onPress={handleLogout}
                disabled={isLoggingOut}
                className="flex-row items-center px-4 py-3"
                style={({ pressed }) => [
                  {
                    opacity: isLoggingOut ? 0.5 : pressed ? 0.7 : 1,
                  },
                ]}
              >
                <StyledView className="w-8 h-8 bg-red-50 rounded-lg items-center justify-center mr-3">
                  {isLoggingOut ? (
                    <ActivityIndicator size="small" color="#EF4444" />
                  ) : (
                    <Icon name="logout" size={18} color="#EF4444" />
                  )}
                </StyledView>
                <AppText className="text-base text-red-600 flex-1">
                  {isLoggingOut ? 'Logging Out...' : 'Log Out'}
                </AppText>
                {!isLoggingOut && (
                  <Icon name="chevron-right" size={18} color="#FCA5A5" />
                )}
              </Pressable>
            </StyledView>
          </StyledView>
        </ScrollView>
      </StyledSafeAreaView>
    </LinearGradient>
  );
}
