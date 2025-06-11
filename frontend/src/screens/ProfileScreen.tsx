import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import TopNavBar from '../components/TopNavBar';
import BottomNavBar from '../components/BottomNavBar';
import { SafeAreaView } from 'react-native-safe-area-context';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { supabase } from '../../lib/supabase';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);

type RootStackParamList = {
  Profile: undefined;
  Startup: undefined;
};

type ProfileScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Profile'>;

export default function ProfileScreen({ route }: { route: any }) {
  const currentUser = route?.params?.currentUser;
  const navigation = useNavigation<ProfileScreenNavigationProp>();

  const handleLogout = async () => {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      navigation.navigate('Startup');
    } catch (error) {
      console.error('Error logging out:', error);
    }
  };

  return (
    <StyledSafeAreaView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar currentUser={currentUser} />
      <StyledView className="flex-1 justify-center items-center">
        <Icon name="person" size={64} color="#FFA726" />
        <StyledText className="text-2xl font-bold text-[#FFA726] mt-4">Profile coming soon!</StyledText>
        
        <StyledTouchableOpacity
          className="mt-8 bg-[#E74C3C] rounded-xl py-4 px-8 items-center shadow-lg"
          onPress={handleLogout}
        >
          <StyledText className="text-[#FFF6E3] text-base font-bold">
            Logout
          </StyledText>
        </StyledTouchableOpacity>
      </StyledView>
      <BottomNavBar currentUser={currentUser} />
    </StyledSafeAreaView>
  );
} 