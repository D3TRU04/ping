import React from 'react';
import { View, Text } from 'react-native';
import { styled } from 'nativewind';
import TopNavBar from '../components/TopNavBar';
import BottomNavBar from '../components/BottomNavBar';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { COLORS } from '../theme/colors';

const StyledView = styled(View);
const StyledText = styled(Text);

export default function PostScreen({ route }: { route: any }) {
  const currentUser = route?.params?.currentUser;

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar currentUser={currentUser} />

      <StyledView className="flex-1 justify-center items-center">
        <Icon name="add-circle-outline" size={64} color={COLORS.orange} />
        <StyledText className="text-2xl font-bold mt-4" style={{ color: COLORS.orange }}>
          Post coming soon!
        </StyledText>
      </StyledView>

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
