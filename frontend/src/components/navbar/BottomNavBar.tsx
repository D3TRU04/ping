// BottomNavBar.tsx
import React from 'react';
import {
  View,
  TouchableOpacity,
  Image,
  Platform,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

type RootStackParamList = {
  Home: undefined;
  Discover: undefined;
  Post: undefined;
  Notifications: undefined;
  ProfileScreen: undefined;
  Chats: undefined;
};

type NavigationProp = StackNavigationProp<RootStackParamList>;
type RouteNames = keyof RootStackParamList;

interface BottomNavBarProps {
  currentUser?: {
    id: string;
    name: string;
    avatar: string;
  };
}

interface NavItem {
  name: string;
  icon: string;
  route: RouteNames;
}

export default function BottomNavBar({ currentUser }: BottomNavBarProps) {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute();

  const isRouteActive = (routeName: RouteNames) => {
    return route.name === routeName;
  };

  const navItems: NavItem[] = [
    {
      name: 'Home',
      icon: 'home',
      route: 'Home',
    },
    {
      name: 'Discover',
      icon: 'explore',
      route: 'Discover',
    },
    {
      name: 'Notifications',
      icon: 'notifications',
      route: 'Notifications',
    },
  ];

  return (
    <StyledView 
      className={`absolute bottom-0 left-0 right-0 border-t ${
        Platform.OS === 'ios' ? 'pb-8' : 'pb-4'
      }`}
      style={{
        backgroundColor: 'rgba(255,255,255,0.85)',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -2 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
        elevation: 10,
        borderTopColor: 'rgba(31,201,195,0.12)',
      }}
    >
      <StyledView className="flex-row justify-around items-center px-4 pt-2">
        {navItems.map((item) => (
          <StyledTouchableOpacity
            key={item.name}
            onPress={() => navigation.navigate(item.route)}
            className="items-center"
          >
            <StyledView style={{
              padding: 8,
              borderRadius: 9999,
              backgroundColor: isRouteActive(item.route) ? '#1FC9C3' : 'transparent',
            }}>
              <Icon
                name={item.icon as any}
                size={24}
                color={isRouteActive(item.route) ? 'white' : '#1FC9C3'}
              />
            </StyledView>
          </StyledTouchableOpacity>
        ))}

        <StyledTouchableOpacity
          onPress={() => navigation.navigate('Chats')}
          className="items-center"
        >
          <StyledView 
            style={{
              padding: 8,
              borderRadius: 9999,
              backgroundColor: isRouteActive('Chats') ? '#1FC9C3' : 'transparent',
            }}
          >
            <Icon
              name="chat-bubble-outline"
              size={24}
              color={isRouteActive('Chats') ? 'white' : '#1FC9C3'}
            />
          </StyledView>
        </StyledTouchableOpacity>
      </StyledView>
    </StyledView>
  );
}
