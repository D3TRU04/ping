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
import Icon from 'react-native-vector-icons/MaterialIcons';

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
      name: 'Post',
      icon: 'add-circle-outline',
      route: 'Post',
    },
    {
      name: 'Notifications',
      icon: 'notifications',
      route: 'Notifications',
    },
  ];

  return (
    <StyledView 
      className={`absolute bottom-0 left-0 right-0 bg-[#FFA726] border-t border-orange-400 ${
        Platform.OS === 'ios' ? 'pb-8' : 'pb-4'
      }`}
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -2 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
        elevation: 10,
      }}
    >
      <StyledView className="flex-row justify-around items-center px-4 pt-2">
        {navItems.map((item) => (
          <StyledTouchableOpacity
            key={item.name}
            onPress={() => navigation.navigate(item.route)}
            className="items-center"
          >
            <StyledView className={`p-2 rounded-full ${isRouteActive(item.route) ? 'bg-white' : ''}`}>
              <Icon
                name={item.icon}
                size={24}
                color={isRouteActive(item.route) ? '#FFA726' : '#fff'}
              />
            </StyledView>
          </StyledTouchableOpacity>
        ))}

        <StyledTouchableOpacity
          onPress={() => navigation.navigate('Chats')}
          className="items-center"
        >
          <StyledView 
            className={`p-2 rounded-full ${
              isRouteActive('Chats') ? 'bg-white' : ''
            }`}
          >
            <Icon
              name="chat-bubble-outline"
              size={24}
              color={isRouteActive('Chats') ? '#FFA726' : '#fff'}
            />
          </StyledView>
        </StyledTouchableOpacity>
      </StyledView>
    </StyledView>
  );
}
