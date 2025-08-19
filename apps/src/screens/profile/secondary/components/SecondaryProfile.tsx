import React from 'react';
import {
  View,
  TouchableOpacity,
  Image,
  Platform,
} from 'react-native';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useNavigation, useRoute } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

type RootStackParamList = {
  ProfileScreen: undefined;
  SettingsScreen: undefined;
  Notifications: undefined;
  SearchUsersScreen: { currentUser?: { id: string; name: string; avatar?: string } };
  Chats: { currentUser: any };
  ChatRoomScreen: { currentUser: any; otherUser: any; conversationId: string };
  publicProfileScreen: { userId: string; currentUser?: any; fromScreen?: string };
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
  const route = useRoute<any>();
  const insets = useSafeAreaInsets();

  // Get the source screen from route params to determine where to go back
  const fromScreen = route.params?.fromScreen;
  const routeCurrentUser = route.params?.currentUser;

  const handleBackPress = () => {
    // If we came from a chat conversation, go back to chats
    if (fromScreen === 'ChatRoomScreen' || fromScreen === 'Chats') {
      if (routeCurrentUser) {
        navigation.navigate('Chats', { currentUser: routeCurrentUser });
      } else {
        navigation.goBack();
      }
    } else {
      // Default: go back to user search
      navigation.navigate({ name: 'SearchUsersScreen', params: { currentUser } });
    }
  };

  return (
    <StyledView
      className="w-full flex-row items-center justify-between px-4 pb-1"
      style={{
        paddingTop: insets.top + 4,
        backgroundColor: 'white',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.08,
        shadowRadius: 2,
        elevation: Platform.OS === 'android' ? 2 : 0,
      }}
    >
      {/* Back button and title */}
      <StyledView className="flex-row items-center min-w-[40px]">
        <StyledTouchableOpacity
          onPress={handleBackPress}
          className="justify-center mr-2"
        >
          <Icon name="arrow-back" size={24} color="#1FC9C3" />
        </StyledTouchableOpacity>
      </StyledView>

      {/* Spacer */}
      <StyledView className="flex-1" />

      {/* Right side actions */}
      <StyledView className="flex-row items-center min-w-[40px] justify-end space-x-2">
        {/* Share profile */}
        <StyledTouchableOpacity
          onPress={() => {/* TODO: Implement share functionality */}}
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
        {/* Notifications */}
        <StyledTouchableOpacity
          onPress={() => navigation.navigate('Notifications')}
          className="justify-center"
        >
          <StyledView style={{
            padding: 8,
            borderRadius: 9999,
            backgroundColor: 'transparent',
          }}>
            <Icon
              name="notifications"
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