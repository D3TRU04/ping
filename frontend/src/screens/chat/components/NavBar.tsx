import React from 'react';
import {
  View,
  TouchableOpacity,
  Image,
  Platform,
  TextInput,
} from 'react-native';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);
const StyledTextInput = styled(TextInput);

type RootStackParamList = {
  Chats: undefined;
  ProfileScreen: undefined;
  Settings: undefined;
  Notifications: undefined;
};

type NavigationProp = StackNavigationProp<RootStackParamList>;

interface ChatsTopNavBarProps {
  currentUser?: {
    id: string;
    name: string;
    avatar?: string;
  };
  searchQuery?: string;
  setSearchQuery?: (query: string) => void;
  onNewChat?: () => void;
  showUserSearch?: boolean;
  userSearchQuery?: string;
  setUserSearchQuery?: (query: string) => void;
  searchingUsers?: boolean;
}

const ChatsTopNavBar: React.FC<ChatsTopNavBarProps> = ({ 
  currentUser,
  searchQuery = '',
  setSearchQuery,
  onNewChat,
  showUserSearch = false,
  userSearchQuery = '',
  setUserSearchQuery,
  searchingUsers = false
}) => {
  const navigation = useNavigation<NavigationProp>();
  const insets = useSafeAreaInsets();

  const handleNewChat = () => {
    if (onNewChat) {
      onNewChat();
    } else {
      navigation.navigate('NewChatScreen', { currentUser });
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
      {/* Title */}
      <StyledView className="flex-row items-center min-w-[40px]">
        <AppText className="text-2xl font-semibold text-gray-900">
          Messages
        </AppText>
      </StyledView>

      {/* Spacer */}
      <StyledView className="flex-1" />

      {/* Right side actions */}
      <StyledView className="flex-row items-center min-w-[40px] justify-end space-x-2">
        {/* New message button */}
        <StyledTouchableOpacity
          onPress={handleNewChat}
          className="w-12 h-12 bg-mint rounded-2xl items-center justify-center"
          style={{
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 0.1,
            shadowRadius: 4,
            elevation: 2,
          }}
        >
          <Icon name="add" size={24} color="white" />
        </StyledTouchableOpacity>

        {/* Search messages */}
        <StyledTouchableOpacity
          onPress={() => navigation.navigate('SearchUsersScreen', { currentUser })}
          className="justify-center mr-1"
        >
          <StyledView style={{
            padding: 8,
            borderRadius: 9999,
            backgroundColor: 'transparent',
          }}>
            <Icon
              name="search"
              size={24}
              color="#1FC9C3"
            />
          </StyledView>
        </StyledTouchableOpacity>

        {/* More options */}
        <StyledTouchableOpacity
          onPress={() => {}}
          className="justify-center"
        >
          <StyledView style={{
            padding: 8,
            borderRadius: 9999,
            backgroundColor: 'transparent',
          }}>
            <Icon
              name="more-vert"
              size={24}
              color="#1FC9C3"
            />
          </StyledView>
        </StyledTouchableOpacity>
      </StyledView>
    </StyledView>
  );
};

export default ChatsTopNavBar; 