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
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

type RootStackParamList = {
  Notifications: undefined;
  ProfileScreen: undefined;
  Settings: undefined;
};

type NavigationProp = StackNavigationProp<RootStackParamList>;

interface NotificationsTopNavBarProps {
  currentUser?: {
    id: string;
    name: string;
    avatar?: string;
  };
}

const NotificationsTopNavBar: React.FC<NotificationsTopNavBarProps> = ({ currentUser }) => {
  const navigation = useNavigation<NavigationProp>();
  const insets = useSafeAreaInsets();

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
      <StyledView className="flex-row items-center min-w-[40px] py-2">
        <AppText className="text-2xl font-semibold text-gray-900">
          Notifications
        </AppText>
      </StyledView>

      {/* Spacer */}
      <StyledView className="flex-1" />
    </StyledView>
  );
};

export default NotificationsTopNavBar; 