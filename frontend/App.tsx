/* Starter Code */

// import React from 'react';
// import { NavigationContainer } from '@react-navigation/native';
// import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
// import { createStackNavigator } from '@react-navigation/stack';
// import { StatusBar } from 'react-native';
// import { SafeAreaProvider } from 'react-native-safe-area-context';
// import { GestureHandlerRootView } from 'react-native-gesture-handler';
// import Icon from 'react-native-vector-icons/MaterialIcons';
// // import LoginScreen from './src/screens/LoginScreen';
// import SwipeScreen from './src/screens/SwipeScreen';
// import LoadingScreen from './src/screens/LoadingScreen';
// import ResultsScreen from './src/screens/ResultsScreen';
// import ProfileScreen from './src/screens/ProfileScreen';
// import { COLORS } from './src/theme/colors';

// export type RootStackParamList = {
//   MainTabs: undefined;
//   Loading: undefined;
//   Results: undefined;
// };

// export type TabParamList = {
//   Discover: undefined;
//   Saved: undefined;
//   Profile: undefined;
// };

// const Stack = createStackNavigator<RootStackParamList>();
// const Tab = createBottomTabNavigator<TabParamList>();

// interface TabBarIconProps {
//   color: string;
//   size: number;
// }

// const MainTabs = () => {
//   return (
//     <Tab.Navigator
//       id={undefined} // Pass id explicitly
//       screenOptions={{
//         headerShown: false,
//         tabBarStyle: {
//           backgroundColor: COLORS.background,
//           borderTopColor: 'rgba(0, 0, 0, 0.1)',
//           paddingBottom: 8,
//           paddingTop: 8,
//           height: 60,
//         },
//         tabBarActiveTintColor: COLORS.coral,
//         tabBarInactiveTintColor: COLORS.textSecondary,
//       }}
//     >
//       <Tab.Screen
//         name="Discover"
//         component={SwipeScreen}
//         options={{
//           tabBarIcon: ({ color, size }: TabBarIconProps) => (
//             <Icon name="explore" size={size} color={color} />
//           ),
//         }}
//       />
//       <Tab.Screen
//         name="Saved"
//         component={ResultsScreen}
//         options={{
//           tabBarIcon: ({ color, size }: TabBarIconProps) => (
//             <Icon name="favorite" size={size} color={color} />
//           ),
//         }}
//       />
//       <Tab.Screen
//         name="Profile"
//         component={ProfileScreen}
//         options={{
//           tabBarIcon: ({ color, size }: TabBarIconProps) => (
//             <Icon name="person" size={size} color={color} />
//           ),
//         }}
//       />
//     </Tab.Navigator>
//   );
// };

// export default function App() {
//   return (
//     <GestureHandlerRootView style={{ flex: 1 }}>
//       <SafeAreaProvider>
//         <NavigationContainer>
//           <StatusBar barStyle="dark-content" backgroundColor={COLORS.background} />
//           <Stack.Navigator
//             id={undefined} // Pass id explicitly
//             screenOptions={{
//               headerShown: false,
//               cardStyle: { backgroundColor: COLORS.background },
//             }}
//             initialRouteName="MainTabs"
//           >
//             <Stack.Screen name="MainTabs" component={MainTabs} />
//             <Stack.Screen name="Loading" component={LoadingScreen} />
//             <Stack.Screen name="Results" component={ResultsScreen} />
//           </Stack.Navigator>
//         </NavigationContainer>
//       </SafeAreaProvider>
//     </GestureHandlerRootView>
//   );
// } 


// App.tsx
import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { supabase } from './lib/supabase';
import { Session } from '@supabase/supabase-js';
import HomeScreen from './src/screens/HomeScreen';
import DiscoverScreen from './src/screens/DiscoverScreen';
import PostScreen from './src/screens/PostScreen';
import NotificationsScreen from './src/screens/NotificationsScreen';
import ProfileScreen from './src/screens/ProfileScreen';
import LoadingScreen from './src/screens/LoadingScreen';
import StartupScreen from './src/screens/StartupScreen';
import SurveyScreen from './src/screens/SurveyScreen';
import ResultsScreen from './src/screens/ResultsScreen';
import SwipeScreen from './src/screens/SwipeScreen';
import ChatsScreen from './src/screens/ChatsScreen';
import SignUpScreen from './src/screens/Auth/SignupScreen';
import SignInScreen from './src/screens/Auth/SigninScreen';
import OnboardingScreen from './src/screens/OnboardingScreen';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { View, Text } from 'react-native';
import TopNavBar from './src/components/TopNavBar';
import BottomNavBar from './src/components/BottomNavBar';
import SettingScreen from './src/screens/Profile/SettingsScreen';

const Stack = createNativeStackNavigator();

interface User {
  id: string;
  name: string;
  avatar: string | null;
  hasOnboarded?: boolean;
}

// function SettingsScreen({ route }: { route: any }) {
//   const currentUser = route?.params?.currentUser;
//   return (
//     <SafeAreaProvider>
//       <View style={{ flex: 1, backgroundColor: '#FAF6F2' }}>
//         <SafeAreaView edges={['top']} style={{ backgroundColor: '#FFA726' }}>
//           <TopNavBar currentUser={currentUser} />
//         </SafeAreaView>
//         <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
//           <Icon name="settings" size={64} color="#FFA726" />
//           <Text style={{ fontSize: 24, fontWeight: 'bold', color: '#FFA726', marginTop: 16 }}>Settings coming soon!</Text>
//         </View>
//         <BottomNavBar currentUser={currentUser} />
//       </View>
//     </SafeAreaProvider>
//   );
// }

export default function App() {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [currentUser, setCurrentUser] = useState<User | null>(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session?.user) {
        // fetchUserProfile(session.user.id);
      }
      setLoading(false);
    });

    supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session?.user) {
        // fetchUserProfile(session.user.id);
      }
    });
  }, []);

  const fetchUserProfile = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) {
        console.error('Error fetching user profile:', error);
        return;
      }

      setCurrentUser({
        id: data.id,
        name: data.full_name || 'User',
        avatar: data.avatar_url || null,
        hasOnboarded: data.has_onboarded || false,
      });
    } catch (error) {
      console.error('Error in fetchUserProfile:', error);
    }
  };

  return (
    <SafeAreaProvider>
      <NavigationContainer>
        <Stack.Navigator
          screenOptions={{
            headerShown: false,
            animation: 'fade',
          }}
        >
          {/* {loading ? (
            <Stack.Screen name="Loading" component={LoadingScreen} />
          ) : !session ? (
            <Stack.Screen name="Startup" component={StartupScreen} />
          ) : ( */}
            <>
              <Stack.Screen 
                name="Home" 
                component={HomeScreen}
                initialParams={{ currentUser }}
              />
              <Stack.Screen name="Discover" component={DiscoverScreen} />
              <Stack.Screen name="Post" component={PostScreen} />
              <Stack.Screen name="Notifications" component={NotificationsScreen} />
              <Stack.Screen name="ProfileScreen" component={ProfileScreen} />
              <Stack.Screen name="SettingsScreen" component={SettingScreen} />
              <Stack.Screen name="Chats" component={ChatsScreen} />
              {/* <Stack.Screen name="Settings" component={SettingsScreen} /> */}
              <Stack.Screen name="Survey" component={SurveyScreen} />
              <Stack.Screen name="Results" component={ResultsScreen} />
              <Stack.Screen name="Swipe" component={SwipeScreen} />
            </>
          {/* )} */}
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
