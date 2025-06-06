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
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import StartupScreen from './src/screens/StartupScreen';
import SignUpScreen from './src/screens/Auth/SignupScreen';
import SignInScreen from './src/screens/Auth/SigninScreen';
import HomeScreen from './src/screens/HomeScreen';
import ProfileScreen from './src/screens/ProfileScreen';
import SurveyScreen from './src/screens/SurveyScreen';


const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        <Stack.Screen name="Startup" component={StartupScreen} />
        <Stack.Screen name="SignUp" component={SignUpScreen} />
        <Stack.Screen name="SignIn" component={SignInScreen} />
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="ProfileScreen" component={ProfileScreen} />
        <Stack.Screen name="Survey" component={SurveyScreen} />

      </Stack.Navigator>
    </NavigationContainer>
  );
}
