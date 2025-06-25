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

const logo = require('../../assets/logo/logo1.png');

type RootStackParamList = {
  Home: undefined;
  ProfileScreen: undefined;
  Settings: undefined;
  Notifications: undefined;
};

type NavigationProp = StackNavigationProp<RootStackParamList>;

interface HomeTopNavBarProps {
  currentUser?: {
    id: string;
    name: string;
    avatar?: string;
  };
}

const HomeTopNavBar: React.FC<HomeTopNavBarProps> = ({ currentUser }) => {
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

      {/* Right side actions */}
      <StyledView className="flex-row items-center min-w-[40px] justify-end space-x-2">
        {/* Filter button */}
        <StyledTouchableOpacity
          onPress={() => console.log('Open filters')}
          className="justify-center mr-1"
        >
          <StyledView style={{
            padding: 8,
            borderRadius: 9999,
            backgroundColor: 'transparent',
          }}>
            <Icon
              name="tune"
              size={24}
              color="#1FC9C3"
            />
          </StyledView>
        </StyledTouchableOpacity>

        {/* Profile */}
        <StyledTouchableOpacity
          onPress={() => navigation.navigate('ProfileScreen')}
          className="justify-center"
        >
          {currentUser?.avatar ? (
            <StyledImage
              source={{ uri: currentUser.avatar }}
              className="w-8 h-8 rounded-full border-2 border-[#1FC9C3]"
            />
          ) : (
            <StyledView style={{
              padding: 8,
              borderRadius: 9999,
              backgroundColor: 'transparent',
            }}>
              <Icon
                name="person"
                size={24}
                color="#1FC9C3"
              />
            </StyledView>
          )}
        </StyledTouchableOpacity>
      </StyledView>
    </StyledView>
  );
};

export default HomeTopNavBar; 