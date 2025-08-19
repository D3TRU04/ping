import React from 'react';
import { View, Pressable, Platform } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import AppText from '../../../../components/AppText';

const StyledView = styled(View);

export default function SettingsTopNavBar() {
  const navigation = useNavigation();

  return (
    <LinearGradient
      colors={['#FAF6F2', '#F5F5F5']}
      style={{
        paddingTop: Platform.OS === 'ios' ? 0 : 8,
      }}
    >
      <StyledView
        className="w-full flex-row items-center justify-between px-4 py-3"
        style={{
          paddingTop: 8,
          backgroundColor: 'white',
          borderBottomWidth: 1,
          borderBottomColor: '#F3F4F6',
        }}
      >
        {/* Left: Back button */}
        <StyledView className="min-w-[40px]">
          <Pressable
            onPress={() => navigation.goBack()}
            className="w-8 h-8 rounded-lg bg-transparent items-center justify-center"
            style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}
          >
            <Icon name="arrow-back" size={20} color="#1FC9C3" />
          </Pressable>
        </StyledView>

        {/* Center: Title */}
        <AppText className="text-lg font-semibold text-gray-900 text-center flex-1">
          Settings
        </AppText>

        {/* Right: Spacer for symmetry */}
        <StyledView className="min-w-[40px]" />
      </StyledView>
    </LinearGradient>
  );
}
