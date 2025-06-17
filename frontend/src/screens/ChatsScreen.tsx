import React from 'react';
import { View, Text } from 'react-native';
import { styled } from 'nativewind';
import Icon from 'react-native-vector-icons/MaterialIcons';
import TopNavBar from '../components/TopNavBar';
import BottomNavBar from '../components/BottomNavBar';
import { COLORS } from '../theme/colors';

const StyledView = styled(View);
const StyledText = styled(Text);

export default function ChatsScreen({ route }: { route: any }) {
  const currentUser = route?.params?.currentUser;

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      {/* Top nav includes safe area inset */}
      <TopNavBar currentUser={currentUser} />

      {/* Main content */}
      <StyledView className="flex-1 justify-center items-center">
        <Icon name="chat-bubble-outline" size={64} color={COLORS.orange} />
        <StyledText className="text-2xl font-bold mt-4" style={{ color: COLORS.orange }}>
          Chats coming soon!
        </StyledText>
      </StyledView>

      {/* Bottom nav */}
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
