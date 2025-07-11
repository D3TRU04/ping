import React from 'react';
import { View, Pressable, Platform, Image } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import AppText from '../AppText';
import { LinearGradient } from 'expo-linear-gradient';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const StyledView = styled(View);
const StyledImage = styled(Image);

const logo = require('../../../src/assets/logo/logo2.png');

interface MatchmakingNavBarProps {
  onRefresh?: () => void;
}

const MatchmakingNavBar: React.FC<MatchmakingNavBarProps> = ({ onRefresh }) => {
  const navigation = useNavigation();
  const insets = useSafeAreaInsets();

  return (
    <LinearGradient
      colors={["#FAF6F2", "#F5F5F5"]}
      style={{
        width: '100%',
        borderBottomLeftRadius: 0,
        borderBottomRightRadius: 0,
      }}
    >
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
        {/* Left: Back button */}
        <StyledView className="flex-row items-center min-w-[40px]">
          <Pressable onPress={() => navigation.goBack()} style={{ elevation: 2 }}>
            <Icon name="arrow-back" size={22} color="#1FC9C3" />
          </Pressable>
        </StyledView>

        {/* Center: Title */}
        <StyledView className="flex-row items-center min-w-[40px]">
        <StyledView
          className="w-28 h-10 overflow-hidden justify-center"
        >
          <StyledImage
            source={logo}
            className="w-28 h-12"
            resizeMode="cover"
          />
        </StyledView>
      </StyledView>

        {/* Right: Refresh button */}
        <StyledView className="min-w-[40px] flex-row items-center justify-end">
          {onRefresh && (
            <Pressable onPress={onRefresh} style={{ elevation: 2, marginLeft: 8 }}>
              <Icon name="refresh" size={22} color="#1FC9C3" />
            </Pressable>
          )}
        </StyledView>
      </StyledView>
    </LinearGradient>
  );
};

export default MatchmakingNavBar;
