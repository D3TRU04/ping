import React from 'react';
import { View, Text } from 'react-native';
import { styled } from 'nativewind';
import TopNavBar from '../components/TopNavBar';
import BottomNavBar from '../components/BottomNavBar';
import { SafeAreaView } from 'react-native-safe-area-context';
import Icon from 'react-native-vector-icons/MaterialIcons';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);
const StyledText = styled(Text);

export default function DiscoverScreen({ route }: { route: any }) {
  const currentUser = route?.params?.currentUser;
  return (
    <StyledSafeAreaView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar currentUser={currentUser} />
      <StyledView className="flex-1 justify-center items-center">
        <Icon name="search" size={64} color="#FFA726" />
        <StyledText className="text-2xl font-bold text-[#FFA726] mt-4">Discover coming soon!</StyledText>
      </StyledView>
      <BottomNavBar currentUser={currentUser} />
    </StyledSafeAreaView>
  );
} 