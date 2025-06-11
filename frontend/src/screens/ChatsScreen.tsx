import React from 'react';
import { View, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import Icon from 'react-native-vector-icons/MaterialIcons';
import TopNavBar from '../components/TopNavBar';
import BottomNavBar from '../components/BottomNavBar';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);
const StyledText = styled(Text);

export default function ChatsScreen({ route }: { route: any }) {
  // If you want to pass currentUser, you can get it from route.params or context
  const currentUser = route?.params?.currentUser;
  return (
    <StyledSafeAreaView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar currentUser={currentUser} />
      <StyledView className="flex-1 justify-center items-center">
        <Icon name="chat-bubble-outline" size={64} color="#FFA726" />
        <StyledText className="text-2xl font-bold text-[#FFA726] mt-4">Chats coming soon!</StyledText>
      </StyledView>
      <BottomNavBar currentUser={currentUser} />
    </StyledSafeAreaView>
  );
} 