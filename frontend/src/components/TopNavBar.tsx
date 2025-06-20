import React from 'react';
import {
  View,
  TouchableOpacity,
  Text,
  Image,
  Platform,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import { COLORS } from '../theme/colors';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

const logo = require('../assets/logo1.png');

type RootStackParamList = {
  Home: undefined;
  Discover: undefined;
  // Post: undefined;
  Notifications: undefined;
  ProfileScreen: undefined;
  Settings: undefined;
};

type NavigationProp = StackNavigationProp<RootStackParamList>;

interface TopNavBarProps {
  currentUser?: {
    id: string;
    name: string;
    avatar?: string;
  };
}

const TopNavBar: React.FC<TopNavBarProps> = ({ currentUser }) => {
  const navigation = useNavigation<NavigationProp>();
  const insets = useSafeAreaInsets();

  return (
    <StyledView
      className="w-full flex-row items-center justify-between px-4 pb-1"
      style={{
        paddingTop: insets.top + 4, // Safe area + spacing
        backgroundColor: COLORS.orange,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.08,
        shadowRadius: 2,
        elevation: Platform.OS === 'android' ? 2 : 0,
      }}
    >
      {/* Logo */}
      <StyledView className="flex-row items-center min-w-[40px]">
        <StyledView
          className="w-28 h-10 overflow-hidden justify-center"
          style={{ marginLeft: -16 }}
        >
          <StyledImage
            source={logo}
            className="w-28 h-12"
            resizeMode="cover"
          />
        </StyledView>
      </StyledView>

      {/* Spacer */}
      <StyledView className="flex-1" />

      {/* Settings & Avatar */}
      <StyledView className="flex-row items-center min-w-[40px] justify-end space-x-2">
        <StyledTouchableOpacity
          onPress={() => navigation.navigate('Settings')}
          className="justify-center mr-1"
        >
          <Icon name="settings" size={26} color="#fff" />
        </StyledTouchableOpacity>

        <StyledTouchableOpacity
          onPress={() => navigation.navigate('ProfileScreen')}
          className="justify-center"
        >
          {currentUser?.avatar ? (
            <StyledImage
              source={{ uri: currentUser.avatar }}
              className="w-8 h-8 rounded-full border-2 border-white"
            />
          ) : (
            <Icon name="person" size={28} color="#fff" />
          )}
        </StyledTouchableOpacity>
      </StyledView>
    </StyledView>
  );
};

export default TopNavBar;