import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { supabase } from './lib/supabase';
import { Session } from '@supabase/supabase-js';
import * as Linking from 'expo-linking';

// Screens
// import HomeScreen from './src/screens/home/HomeScreen.tsx';
import HomeScreen from './src/screens/Home/HomeScreen';
import DiscoverScreen from './src/screens/DiscoverScreen';
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
import OnboardingScreen from './src/screens/Auth/OnboardingScreen';
import SettingScreen from './src/screens/Profile/SettingsScreen';
import EditAccountScreen from './src/screens/Profile/EditAccountScreen'; // adjust path


// UI Components (optional)
import TopNavBar from './src/components/TopNavBar';
import BottomNavBar from './src/components/BottomNavBar';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { View, Text } from 'react-native';

const Stack = createNativeStackNavigator();

interface User {
  id: string;
  name: string;
  avatar: string | null;
  hasOnboarded?: boolean;
}

const linking = {
  prefixes: ['ping://'],
  config: {
    screens: {
      Onboarding: 'onboarding',
      // add other screens if you want to support more deep links
    },
  },
};

export default function App() {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [currentUser, setCurrentUser] = useState<User | null>(null);

  useEffect(() => {
    // Initial session check
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session?.user) {
        fetchUserProfile(session.user.id);
      }
      setLoading(false);
    });

    // Listener for session changes
    supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session?.user) {
        fetchUserProfile(session.user.id);
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
      <NavigationContainer linking={linking}>
        <Stack.Navigator
          screenOptions={{
            headerShown: false,
            animation: 'fade',
          }}
        >
          {loading ? (
            <Stack.Screen name="Loading" component={LoadingScreen} />
          ) : (
            <>
              <Stack.Screen name="Startup" component={StartupScreen} />
              <Stack.Screen name="SignupScreen" component={SignUpScreen} />
              <Stack.Screen name="SignIn" component={SignInScreen} />
              <Stack.Screen name="Onboarding" component={OnboardingScreen} />
              {session && (
                <>
                  <Stack.Screen name="Home" component={HomeScreen} initialParams={{ currentUser }} />
                  <Stack.Screen name="Discover" component={DiscoverScreen} />
                  <Stack.Screen name="Notifications" component={NotificationsScreen} />
                  <Stack.Screen name="ProfileScreen" component={ProfileScreen} initialParams={{ currentUser }} />
                  <Stack.Screen name="EditAccount" component={EditAccountScreen} />
                  <Stack.Screen name="SettingsScreen" component={SettingScreen} />
                  <Stack.Screen name="Chats" component={ChatsScreen} />
                  <Stack.Screen name="Survey" component={SurveyScreen} />
                  <Stack.Screen name="Results" component={ResultsScreen} />
                  <Stack.Screen name="Swipe" component={SwipeScreen} />
                </>
              )}
            </>
          )}
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}

