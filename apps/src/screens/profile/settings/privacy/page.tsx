import React, { useState } from 'react';
import { View, Pressable, ScrollView, Switch } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import AppText from '../../../../components/AppText';
import { LinearGradient } from 'expo-linear-gradient';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);

export default function PrivacySecurityScreen() {
  const navigation = useNavigation();
  const [isPrivateAccount, setIsPrivateAccount] = useState(false);

  return (
    <LinearGradient colors={["#FAF6F2", "#F5F5F5"]} style={{ flex: 1 }}>
      <StyledSafeAreaView className="flex-1 bg-white">
        <StyledView className="w-full flex-row items-center justify-between px-4 py-3 bg-white border-b border-gray-100">
          <Pressable 
            onPress={() => navigation.goBack()} 
            className="w-8 h-8 rounded-lg bg-transparent items-center justify-center"
            style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}
          >
            <Icon name="arrow-back" size={20} color="#1FC9C3" />
          </Pressable>
          <AppText className="text-lg font-semibold text-gray-900">Privacy & Security</AppText>
          <StyledView className="w-8 h-8" />
        </StyledView>

        <ScrollView className="flex-1 px-4 py-6" showsVerticalScrollIndicator={false}>
          {/* Account Privacy */}
          <StyledView className="mb-6">
            <StyledView className="mb-3 px-2">
              <AppText className="text-sm font-medium text-gray-600">Account Privacy</AppText>
            </StyledView>
            
            <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden">
              <StyledView className="flex-row items-center justify-between px-4 py-3">
                <StyledView className="flex-row items-center flex-1">
                  <StyledView className="w-8 h-8 bg-[#1FC9C3]/10 rounded-lg items-center justify-center mr-3">
                    <Icon name="visibility" size={18} color="#1FC9C3" />
                  </StyledView>
                  <StyledView className="flex-1">
                    <AppText className="text-base text-gray-900">Private Account</AppText>
                  </StyledView>
                </StyledView>
                <Switch
                  value={isPrivateAccount}
                  onValueChange={setIsPrivateAccount}
                  trackColor={{ false: '#E5E7EB', true: '#1FC9C3' }}
                  thumbColor={isPrivateAccount ? '#FFFFFF' : '#FFFFFF'}
                />
              </StyledView>
            </StyledView>
          </StyledView>
        </ScrollView>
      </StyledSafeAreaView>
    </LinearGradient>
  );
} 