import React from 'react';
import { View, Pressable, Platform } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import AppText from '../../../components/AppText';
import { LinearGradient } from 'expo-linear-gradient';

const StyledView = styled(View);

const SettingsTopNavBar: React.FC = () => {
  const navigation = useNavigation();

  return (
    <LinearGradient
      colors={["#FAF6F2", "#F5F5F5"]}
      style={{
        width: '100%',
        borderBottomLeftRadius: 0,
        borderBottomRightRadius: 0,
      }}
    >
      <StyledView
        className="w-full flex-row items-center justify-between px-4 pb-0.5"
        style={{
          paddingTop: 4,
          backgroundColor: 'white',
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 1 },
          shadowOpacity: 0.08,
          shadowRadius: 2,
          elevation: Platform.OS === 'android' ? 2 : 0,
        }}
      >
        {/* Left: Back button */}
        <StyledView className="flex-row items-center min-w-[40px]">
          <Pressable onPress={() => navigation.goBack()} style={{ elevation: 2 }}>
            <Icon name="arrow-back" size={22} color="#1FC9C3" />
          </Pressable>
        </StyledView>

        {/* Center: Title */}
        <AppText className="text-2xl font-semibold text-gray-900 text-center flex-1" style={{ fontFamily: 'Satoshi-Medium' }}>
          Settings
        </AppText>

        {/* Right: Spacer for symmetry */}
        <StyledView className="min-w-[40px]" />
      </StyledView>
    </LinearGradient>
  );
};

export default SettingsTopNavBar;
