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
  SearchUsersScreen: { currentUser: any };
  NewChatScreen: { currentUser: any };
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
  // Selection mode props
  isSelectionMode?: boolean;
  selectedCount?: number;
  onToggleSelectionMode?: () => void;
  onCancelSelection?: () => void;
  onDeleteSelected?: () => void;
  onMuteSelected?: () => void;
}

const ChatsTopNavBar: React.FC<ChatsTopNavBarProps> = ({ 
  currentUser,
  searchQuery = '',
  setSearchQuery,
  onNewChat,
  showUserSearch = false,
  userSearchQuery = '',
  setUserSearchQuery,
  searchingUsers = false,
  isSelectionMode = false,
  selectedCount = 0,
  onToggleSelectionMode,
  onCancelSelection,
  onDeleteSelected,
  onMuteSelected
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

  // Selection mode header
  if (isSelectionMode) {
    return (
      <StyledView
        className="w-full flex-row items-center justify-between px-4 pb-1 bg-white shadow-sm"
        style={{
          paddingTop: insets.top + 4,
        }}
      >
        {/* Cancel button */}
        <StyledTouchableOpacity
          onPress={onCancelSelection}
          className="min-w-[40px]"
        >
          <AppText className="text-base text-mint font-medium">
            Cancel
          </AppText>
        </StyledTouchableOpacity>

        {/* Selection count */}
        <StyledView className="flex-1 items-center">
          <AppText className="text-lg font-semibold text-gray-900">
            {selectedCount} {selectedCount === 1 ? 'conversation' : 'conversations'} selected
          </AppText>
        </StyledView>

        {/* Action buttons */}
        <StyledView className="flex-row items-center space-x-3">
          {/* Mute button */}
          <StyledTouchableOpacity
            onPress={onMuteSelected}
            className="px-3 py-1.5 bg-gray-100 rounded-lg"
          >
            <AppText className="text-sm text-gray-700 font-medium">
              Mute
            </AppText>
          </StyledTouchableOpacity>

          {/* Delete button */}
          <StyledTouchableOpacity
            onPress={onDeleteSelected}
            className="px-3 py-1.5 bg-red-500 rounded-lg"
          >
            <AppText className="text-sm text-white font-medium">
              Delete
            </AppText>
          </StyledTouchableOpacity>
        </StyledView>
      </StyledView>
    );
  }

  // Normal mode header
  return (
    <StyledView
      className="w-full flex-row items-center justify-between px-4 pb-1 bg-white shadow-sm"
      style={{
        paddingTop: insets.top + 4,
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
          className="w-12 h-12 items-center justify-center shadow-md"
        >
          <Icon name="add" size={24} color="#1FC9C3" />
        </StyledTouchableOpacity>

        {/* Search messages */}
        <StyledTouchableOpacity
          onPress={() => navigation.navigate('SearchUsersScreen', { currentUser })}
          className="justify-center mr-1"
        >
          <StyledView className="p-2 rounded-full">
            <Icon
              name="search"
              size={24}
              color="#1FC9C3"
            />
          </StyledView>
        </StyledTouchableOpacity>

        {/* More options - triggers selection mode */}
        <StyledTouchableOpacity
          onPress={onToggleSelectionMode}
          className="justify-center"
        >
          <StyledView className="p-2 rounded-full">
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