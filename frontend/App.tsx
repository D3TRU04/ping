import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { supabase } from './lib/supabase';
import { Session } from '@supabase/supabase-js';
// import * as Linking from 'expo-linking';
import * as Font from 'expo-font';
import * as SplashScreen from 'expo-splash-screen';
// import useCustomFonts from './src/hooks/useFonts';
// import { MaterialIcons } from '@expo/vector-icons';
import { Text as RNText } from 'react-native';

// Screens
import HomeScreen from './src/screens/home/page';
import DiscoverScreen from './src/screens/discover/page';
import NotificationsScreen from './src/screens/notifications/page';
import ProfileScreen from './src/screens/profile/main/page';
import LoadingScreen from './src/screens/core/loading/page';
import StartupScreen from './src/screens/core/startup/page';
import ResultsScreen from './src/screens/results/page';
import ChatsScreen from './src/screens/chat/page';
import SignUpScreen from './src/screens/auth/signup/page';
import SignInScreen from './src/screens/auth/signin/page';
import OnboardingScreen from './src/screens/auth/onboarding/page';
import SettingScreen from './src/screens/profile/settings/page';
import EditAccountScreen from './src/screens/profile/edit/page';

// UI Components (optional)
// import BottomNavBar from './src/components/navbar/BottomNavBar';
// import { View } from 'react-native';

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
  const [sessionLoaded, setSessionLoaded] = useState(false);
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [fontsLoaded] = Font.useFonts({
    'Satoshi-Regular': require('./src/assets/fonts/Satoshi-Regular.ttf'),
    'Satoshi-Bold': require('./src/assets/fonts/Satoshi-Bold.ttf'),
    'Satoshi-Black': require('./src/assets/fonts/Satoshi-Black.ttf'),
    'Satoshi-Light': require('./src/assets/fonts/Satoshi-Light.ttf'),
    'Satoshi-Medium': require('./src/assets/fonts/Satoshi-Medium.ttf'),
    'Satoshi-Italic': require('./src/assets/fonts/Satoshi-Italic.ttf'),
    'Satoshi-BoldItalic': require('./src/assets/fonts/Satoshi-BoldItalic.ttf'),
    'Satoshi-BlackItalic': require('./src/assets/fonts/Satoshi-BlackItalic.ttf'),
    'Satoshi-LightItalic': require('./src/assets/fonts/Satoshi-LightItalic.ttf'),
    'Satoshi-MediumItalic': require('./src/assets/fonts/Satoshi-MediumItalic.ttf'),
    'Material Icons': require('@expo/vector-icons/build/vendor/react-native-vector-icons/Fonts/MaterialIcons.ttf'),
  });

  useEffect(() => {
    SplashScreen.preventAutoHideAsync();
  }, []);

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync();
      // Set Satoshi-Regular as the default font for all Text components
      const oldRender = (RNText as any).render;
      (RNText as any).render = function (...args: any[]) {
        const origin = oldRender.call(this, ...args);
        return React.cloneElement(origin, {
          style: [{ fontFamily: 'Satoshi-Regular' }, origin.props.style],
        });
      };
    }
  }, [fontsLoaded]);

  useEffect(() => {
    // Initial session check
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session?.user) {
        fetchUserProfile(session.user.id);
      }
      setSessionLoaded(true);
    });

    // Listener for session changes
    supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session?.user) {
        fetchUserProfile(session.user.id);
      }
    });
  }, []);

  // Ensure loading screen shows for at least 2 seconds
  useEffect(() => {
    if (sessionLoaded && fontsLoaded) {
      const timer = setTimeout(() => {
        setLoading(false);
      }, 2000);
      return () => clearTimeout(timer);
    }
  }, [sessionLoaded, fontsLoaded]);

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

  if (!fontsLoaded) {
    return null;
  }

  return (
    <SafeAreaProvider>
      <NavigationContainer linking={linking}>
        <Stack.Navigator
          screenOptions={{
            headerShown: false,
            animation: 'fade',
            animationDuration: 300,
            gestureEnabled: true,
            gestureDirection: 'horizontal',
          }}
        >
          {loading ? (
            <Stack.Screen 
              name="Loading" 
              component={LoadingScreen}
              options={{
                animation: 'fade',
                animationDuration: 300,
              }}
            />
          ) : (
            <>
              <Stack.Screen 
                name="Loading" 
                component={LoadingScreen}
                options={{
                  animation: 'fade',
                  animationDuration: 300,
                }}
              />
              <Stack.Screen 
                name="Startup" 
                component={StartupScreen}
                options={{
                  animation: 'slide_from_bottom',
                  animationDuration: 400,
                }}
              />
              <Stack.Screen 
                name="SignupScreen" 
                component={SignUpScreen}
                options={{
                  animation: 'fade',
                  animationDuration: 300,
                }}
              />
              <Stack.Screen 
                name="SignIn" 
                component={SignInScreen}
                options={{
                  animation: 'fade',
                  animationDuration: 300,
                }}
              />
              <Stack.Screen 
                name="Onboarding" 
                component={OnboardingScreen}
                options={{
                  animation: 'fade',
                  animationDuration: 300,
                }}
              />
              {session && (
                <>
                  <Stack.Screen 
                    name="Home" 
                    component={HomeScreen} 
                    initialParams={{ currentUser }}
                    options={{
                      animation: 'fade',
                      animationDuration: 300,
                      gestureEnabled: true,
                      gestureDirection: 'horizontal',
                    }}
                  />
                  <Stack.Screen 
                    name="Discover" 
                    component={DiscoverScreen}
                    options={{
                      animation: 'fade',
                      animationDuration: 300,
                      gestureEnabled: true,
                      gestureDirection: 'horizontal',
                    }}
                  />
                  <Stack.Screen 
                    name="Notifications" 
                    component={NotificationsScreen}
                    options={{
                      animation: 'fade',
                      animationDuration: 300,
                      gestureEnabled: true,
                      gestureDirection: 'horizontal',
                    }}
                  />
                  <Stack.Screen 
                    name="ProfileScreen" 
                    component={ProfileScreen} 
                    initialParams={{ currentUser }}
                    options={{
                      animation: 'fade',
                      animationDuration: 300,
                      gestureEnabled: true,
                      gestureDirection: 'horizontal',
                    }}
                  />
                  <Stack.Screen 
                    name="EditAccount" 
                    component={EditAccountScreen}
                    options={{
                      animation: 'fade',
                      animationDuration: 300,
                      gestureEnabled: true,
                      gestureDirection: 'horizontal',
                    }}
                  />
                  <Stack.Screen 
                    name="SettingsScreen" 
                    component={SettingScreen}
                    options={{
                      animation: 'fade',
                      animationDuration: 300,
                      gestureEnabled: true,
                      gestureDirection: 'horizontal',
                    }}
                  />
                  <Stack.Screen 
                    name="Chats" 
                    component={ChatsScreen}
                    options={{
                      animation: 'fade',
                      animationDuration: 300,
                      gestureEnabled: true,
                      gestureDirection: 'horizontal',
                    }}
                  />
                  <Stack.Screen 
                    name="Results" 
                    component={ResultsScreen}
                    options={{
                      animation: 'fade',
                      animationDuration: 300,
                      gestureEnabled: true,
                      gestureDirection: 'horizontal',
                    }}
                  />
                </>
              )}
            </>
          )}
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}

