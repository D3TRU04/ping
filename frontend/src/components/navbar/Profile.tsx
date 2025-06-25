import React from 'react';
import {
  View,
  TouchableOpacity,
  Image,
  Platform,
} from 'react-native';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import AppText from '../AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

type RootStackParamList = {
  ProfileScreen: undefined;
  Settings: undefined;
  Notifications: undefined;
};

type NavigationProp = StackNavigationProp<RootStackParamList>;

interface ProfileTopNavBarProps {
  currentUser?: {
    id: string;
    name: string;
    avatar?: string;
  };
}

const ProfileTopNavBar: React.FC<ProfileTopNavBarProps> = ({ currentUser }) => {
  const navigation = useNavigation<NavigationProp>();
  const insets = useSafeAreaInsets();

  return (
    <StyledView
      className="w-full flex-row items-center justify-between px-4 pb-1"
      style={{
        paddingTop: insets.top + 4,
        backgroundColor: 'rgba(255,255,255,0.85)',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.08,
        shadowRadius: 2,
        elevation: Platform.OS === 'android' ? 2 : 0,
      }}
    >
      {/* Back button and title */}
      <StyledView className="flex-row items-center min-w-[40px]">
        {/* Removed back button */}
        <AppText className="text-2xl font-semibold text-gray-900">
          Profile
        </AppText>
      </StyledView>

      {/* Spacer */}
      <StyledView className="flex-1" />

      {/* Right side actions */}
      <StyledView className="flex-row items-center min-w-[40px] justify-end space-x-2">
        {/* Edit profile */}
        <StyledTouchableOpacity
          onPress={() => console.log('Edit profile')}
          className="justify-center mr-1"
        >
          <StyledView style={{
            padding: 8,
            borderRadius: 9999,
            backgroundColor: 'transparent',
          }}>
            <Icon
              name="edit"
              size={24}
              color="#1FC9C3"
            />
          </StyledView>
        </StyledTouchableOpacity>

        {/* Share profile */}
        <StyledTouchableOpacity
          onPress={() => console.log('Share profile')}
          className="justify-center mr-1"
        >
          <StyledView style={{
            padding: 8,
            borderRadius: 9999,
            backgroundColor: 'transparent',
          }}>
            <Icon
              name="share"
              size={24}
              color="#1FC9C3"
            />
          </StyledView>
        </StyledTouchableOpacity>

        {/* Settings */}
        <StyledTouchableOpacity
          onPress={() => navigation.navigate('Settings')}
          className="justify-center"
        >
          <StyledView style={{
            padding: 8,
            borderRadius: 9999,
            backgroundColor: 'transparent',
          }}>
            <Icon
              name="settings"
              size={24}
              color="#1FC9C3"
            />
          </StyledView>
        </StyledTouchableOpacity>
      </StyledView>
    </StyledView>
  );
};

export default ProfileTopNavBar; 