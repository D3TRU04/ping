// NavBar.tsx
import React from 'react';
import {
  View,
  TouchableOpacity,
  Image,
  Platform,
  StyleSheet,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation, useRoute } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

type RootStackParamList = {
  Home: undefined;
  Discover: undefined;
  Post: undefined;
  Notifications: undefined;
  Profile: undefined;
};

type NavigationProp = StackNavigationProp<RootStackParamList>;

interface NavBarProps {
  profileImage?: string;
}

const NavBar: React.FC<NavBarProps> = ({
  profileImage = 'https://via.placeholder.com/150',
}) => {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute();
  const insets = useSafeAreaInsets();

  const isRouteActive = (routeName: string) => route.name === routeName;

  return (
    <View style={[styles.container, { paddingBottom: insets.bottom }]}>
      <View style={styles.navBarInner}>
        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigation.navigate('Home')}
        >
          <Icon
            name="home"
            size={28}
            color={isRouteActive('Home') ? '#000' : '#666'}
          />
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigation.navigate('Discover')}
        >
          <Icon
            name="search"
            size={28}
            color={isRouteActive('Discover') ? '#000' : '#666'}
          />
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigation.navigate('Post')}
        >
          <View style={styles.postButton}>
            <Icon name="add" size={24} color="#fff" />
          </View>
        </TouchableOpacity>

        {/* <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigation.navigate('Notifications')}
        >
          <Icon
            name="notifications"
            size={28}
            color={isRouteActive('Notifications') ? '#000' : '#666'}
          />
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigation.navigate('Profile')}
        >
          <View style={styles.profileContainer}>
            <Image
              source={{ uri: profileImage }}
              style={styles.profileImage}
              resizeMode="cover"
            />
          </View>
        </TouchableOpacity> */}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#E5E7EB',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -2 },
        shadowOpacity: 0.05,
        shadowRadius: 3,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  navBarInner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 24, // corresponds to Tailwind px-6
    height: 64, // corresponds to Tailwind h-16
  },
  navItem: {
    alignItems: 'center',
    justifyContent: 'center',
    width: 48, // corresponds to Tailwind w-12
  },
  postButton: {
    width: 40, // corresponds to Tailwind w-10
    height: 40, // corresponds to Tailwind h-10
    borderRadius: 8, // approximate value for rounded-lg
    backgroundColor: 'black', // bg-black
    alignItems: 'center',
    justifyContent: 'center',
  },
  profileContainer: {
    width: 40, // corresponds to Tailwind w-10
    height: 40, // corresponds to Tailwind h-10
    borderRadius: 20, // rounded-full (half of 40)
    overflow: 'hidden',
    backgroundColor: '#E5E7EB', // bg-gray-200
  },
  profileImage: {
    width: '100%',
    height: '100%',
  },
});

export default NavBar;
