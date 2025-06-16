// import React from 'react';
// import { View, Text } from 'react-native';
// import { styled } from 'nativewind';
// import TopNavBar from '../components/TopNavBar';
// import BottomNavBar from '../components/BottomNavBar';
// import { SafeAreaView } from 'react-native-safe-area-context';
// import Icon from 'react-native-vector-icons/MaterialIcons';

// const StyledSafeAreaView = styled(SafeAreaView);
// const StyledView = styled(View);
// const StyledText = styled(Text);

// export default function ProfileScreen({ route }: { route: any }) {
//   const currentUser = route?.params?.currentUser;
//   return (
//     <StyledSafeAreaView className="flex-1 bg-[#FAF6F2]">
//       <TopNavBar currentUser={currentUser} />
//       <StyledView className="flex-1 justify-center items-center">
//         <Icon name="person" size={64} color="#FFA726" />
//         <StyledText className="text-2xl font-bold text-[#FFA726] mt-4">Profile coming soon!</StyledText>
//       </StyledView>
//       <BottomNavBar currentUser={currentUser} />
//     </StyledSafeAreaView>
//   );
// } 

/* -------------------------------------------------------------- */


// import React, { useState } from 'react';
// import { View, Text, Image, Pressable, ScrollView } from 'react-native';
// import { styled } from 'nativewind';
// import { SafeAreaView } from 'react-native-safe-area-context';
// import Icon from 'react-native-vector-icons/MaterialIcons';
// import TopNavBar from '../components/TopNavBar';
// import BottomNavBar from '../components/BottomNavBar';
// import { useNavigation, NavigationProp } from '@react-navigation/native'; // Add this at the top
// import { Animated, Easing } from 'react-native';
// import { useRef } from 'react';


// // Inside ProfileScreen component


// // Styled NativeWind components
// const StyledSafeAreaView = styled(SafeAreaView);
// const StyledView = styled(View);
// const StyledText = styled(Text);
// const StyledImage = styled(Image);

// const mockUser = {
//   id: 'ping123',
//   name: 'Aaron Alvarez',
//   avatar: 'https://via.placeholder.com/150', // fallback avatar
//   username: 'aaron_ping',
//   email: 'aaron@example.com',
//   displayName: 'Aaron A.',
//   creationDate: '2024-05-01',
//   birthday: '1998-11-12',
//   profilePicture: require('../assets/profilepic.png'),
//   saved: ['Top Taco Spots', 'Late Night Coffee Shops', 'Chill Date Ideas',
//     'Top Taco Spots', 'Late Night Coffee Shops', 'Chill Date Ideas',
//     'Top Taco Spots', 'Late Night Coffee Shops', 'Chill Date Ideas',
//     'Top Taco Spots', 'Late Night Coffee Shops', 'Chill Date Ideas',
//     'Top Taco Spots', 'Late Night Coffee Shops', 'Chill Date Ideas',
//   ],
//   creations: ['My Austin Eats Board', 'Hidden Gems Collection'],
//   following: 7,
//   followers: 7,
// };

// type RootStackParamList = {
//   ProfileScreen: undefined;
//   SettingsScreen: undefined;
//   // Add other screens here as needed
// };

// export default function ProfileScreen() {
//   const scrollY = useRef(new Animated.Value(0)).current;

//   const navigation = useNavigation<NavigationProp<RootStackParamList>>();
//   const currentUser = mockUser;
//   const [activeTab, setActiveTab] = useState<'Boards' | 'Creations' | 'Followers'>('Boards');

//   const renderContent = () => {
//     switch (activeTab) {
//       case 'Boards':
//         return (
//           // <View className="p-4">
//           //   {currentUser.saved.map((item: string, index: number) => (
//           //     <Text key={index} className="text-base mb-2 text-gray-800">
//           //       {item}
//           //     </Text>
//           //   ))}
//           // </View>

//          <Animated.ScrollView
//             scrollEventThrottle={16}
//             onScroll={Animated.event(
//               [{ nativeEvent: { contentOffset: { y: scrollY } } }],
//               { useNativeDriver: true }
//             )}
//             className="p-4"
//           >
//             <View className="flex-row justify-between">
//               {/* Left Column – scrolls normally */}
//               <Animated.View
//                 style={{
//                   transform: [
//                     {
//                       translateY: scrollY.interpolate({
//                         inputRange: [0, 100],
//                         outputRange: [200, -50],
//                         extrapolate: 'clamp',
//                       }),
//                     },
//                   ],
//                 }}
//                 className="w-1/2 pr-2"
//               >
//                 {currentUser.saved.map((item, idx) =>
//                   idx % 2 === 0 ? (
//                     <View
//                       key={idx}
//                       className="mb-4 h-40 bg-orange-100 rounded-lg justify-center items-center"
//                     >
//                       <Text>{item}</Text>
//                     </View>
//                   ) : null
//                 )}
//               </Animated.View>

//               {/* Right Column – scrolls in reverse */}
//               <Animated.View
//                 style={{
//                   transform: [
//                     {
//                       translateY: scrollY.interpolate({
//                         inputRange: [0, 300],
//                         outputRange: [-10, 0], // opposite direction
//                         extrapolate: 'clamp',
//                       }),
//                     },
//                   ],
//                 }}
//                 className="w-1/2 pl-3"
//               >
//                 {currentUser.saved.map((item, idx) =>
//                   idx % 2 !== 0 ? (
//                     <View
//                       key={idx}
//                       className="mb-4 h-40 bg-blue-100 rounded-lg justify-center items-center"
//                     >
//                       <Text>{item}</Text>
//                     </View>
//                   ) : null
//                 )}
//               </Animated.View>
//             </View>
//           </Animated.ScrollView>
          
//         );
//       case 'Creations':
//         return (
//           <View className="p-4">
//             {currentUser.creations.map((item: string, index: number) => (
//               <Text key={index} className="text-base mb-2 text-gray-800">
//                 {item}
//               </Text>
//             ))}
//           </View>
//         );
//       case 'Followers':
//         return (
//           <View className="p-4">
//             {/* <Text className="mb-2 text-gray-800">Following: {currentUser.following.length}</Text>
//             <Text className="mb-2 text-gray-800">Followers: {currentUser.followers.length}</Text> */}
//           </View>
//         );
//       default:
//         return null;
//     }
//   };

//   return (
//     <StyledSafeAreaView className="flex-1 bg-[#FAF6F2]">
//       {/* <TopNavBar
//         currentUser={{
//           id: currentUser.username,
//           name: currentUser.displayName,
//           avatar: currentUser.profilePicture || 'https://example.com/default-avatar.png',
//         }}
//       /> */}

//         {/* Profile Header */}
//         <View className="relative bg-white pb-12 pt-10 px-4">
//           {/* Settings icon */}
//           <Pressable
//             onPress={() => navigation.navigate('SettingsScreen')}
//             className="absolute top-4 right-4 p-2"
//           >
//             <Icon name="settings" size={24} color="#4B5563" />
//           </Pressable>

//           {/* Profile Image and Info Row */}
//           <View className="flex-row items-center">
//             <StyledImage
//               source={currentUser.profilePicture}
//               className="w-24 h-24 rounded-full mr-4"
//             />
//             <Text className="text-2xl font-bold -top-3 text-gray-900">
//               {currentUser.displayName}
//             </Text>

//             <Text className="text-xs text-gray-500 mt-6 -mx-24">
//               <Text className="font-bold text-gray-700">{currentUser.following}</Text> Following   <Text className="font-bold text-gray-700">{currentUser.followers}</Text> Followers
//             </Text>

            
//           </View>

//           <View className="mx-1 mt-4">
//             <Text className="text-sm text-gray-600">@{currentUser.username}</Text>
//           </View>
//           {/* <Text className="text-sm text-gray-600">{currentUser.email}</Text>
//           <Text className="text-xs text-gray-500">Joined: {currentUser.creationDate}</Text>
//           <Text className="text-xs text-gray-500">Birthday: {currentUser.birthday}</Text> */}
//         </View>




//         {/* Sub Nav Buttons */}
//         <View className="flex-row justify-around bg-white border-y border-white">
//           {['Boards', 'Creations', 'Followers'].map((tab) => (
//             <Pressable
//               key={tab}
//               onPress={() => setActiveTab(tab as 'Boards' | 'Creations' | 'Followers')}
//               className={`py-3 flex-1 items-center 
//                 ${
//                   activeTab === tab ? 'border-b-2 border-black' : ''}`}
//             >
//               <Text
//                 className={`text-base ${
//                   activeTab === tab ? 'text-slate-800 font-bold' : 'text-gray-500'
//                 }`}
//               >
//                 {tab}
//               </Text>
//             </Pressable>
//           ))}
//         </View>
//       <ScrollView className="flex-1">

//         {/* Dynamic Tab Content */}
//         {renderContent()}
//       </ScrollView>

//       <BottomNavBar
//         currentUser={{
//           id: currentUser.username,
//           name: currentUser.displayName,
//           avatar: currentUser.profilePicture || 'https://example.com/default-avatar.png',
//         }}
//       />
//     </StyledSafeAreaView>
//   );
// }


/* -------------------------------With Authenication------------------------------- */

import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  Image,
  Pressable,
  ScrollView,
  Animated,
  Easing,
} from 'react-native';
import { styled } from 'nativewind';
import { SafeAreaView } from 'react-native-safe-area-context';
import Icon from 'react-native-vector-icons/MaterialIcons';
import TopNavBar from '../components/TopNavBar';
import BottomNavBar from '../components/BottomNavBar';
import { useNavigation, NavigationProp } from '@react-navigation/native';
import { supabase } from '../../lib/supabase'; // adjust if needed
import { useRoute, RouteProp } from '@react-navigation/native';


const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);
const StyledText = styled(Text);
const StyledImage = styled(Image);

type RootStackParamList = {
  ProfileScreen: { currentUser: any };
  SettingsScreen: undefined;
  EditAccount: undefined;
};



export default function ProfileScreen() {
  const scrollY = useRef(new Animated.Value(0)).current;
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();

  const route = useRoute<RouteProp<RootStackParamList, 'ProfileScreen'>>();
  // const currentUser = route.params.currentUser;

  const [user, setUser] = useState<any>(null);
  const [profile, setProfile] = useState<any>(null);
  const [followers, setFollowers] = useState(0);
  const [following, setFollowing] = useState(0);
  const [activeTab, setActiveTab] = useState<'Boards' | 'Creations' | 'Followers'>('Boards');

  // Fetch user
  useEffect(() => {
    const fetchUser = async () => {
      const {
        data: { user },
        error,
      } = await supabase.auth.getUser();
      if (error) console.error(error);
      else setUser(user);
    };

    fetchUser();
  }, []);

  // Fetch profile
  useEffect(() => {
    if (!user) return;

    const fetchProfile = async () => {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();

      if (error) console.error(error);
      else setProfile(data);
    };

    fetchProfile();
  }, [user]);

  // Fetch follower/following counts
  useEffect(() => {
    if (!user) return;

    const fetchFollowCounts = async () => {
      const [{ count: followersCount }, { count: followingCount }] = await Promise.all([
        supabase
          .from('follows')
          .select('*', { count: 'exact', head: true })
          .eq('following_id', user.id),
        supabase
          .from('follows')
          .select('*', { count: 'exact', head: true })
          .eq('follower_id', user.id),
      ]);

      setFollowers(followersCount || 0);
      setFollowing(followingCount || 0);
    };

    fetchFollowCounts();
  }, [user]);

  if (!user || !profile) {
    return (
      <View className="flex-1 justify-center items-center bg-white">
        <Text>Loading profile...</Text>
      </View>
    );
  }

  const currentUser = {
    id: user.id,
    name: user.display_name, // user.display_name
    // avatar: profile.profile_picture,
    avatar: require('../assets/profilepic.png'),
    username: profile.username || 'la flame', //profile.username
    email: user.email,
    creationDate: user.created_at?.split('T')[0],
    birthday: profile.birthday || '',
    profilePicture: { uri: profile.profile_picture },
    saved: (profile.saved as string[]) || [],
    creations: [], // optional: you can query a 'creations' table
    following,
    followers,
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'Boards':
        return (
          <Animated.ScrollView
            scrollEventThrottle={16}
            onScroll={Animated.event(
              [{ nativeEvent: { contentOffset: { y: scrollY } } }],
              { useNativeDriver: true }
            )}
            className="p-4"
          >
            <View className="flex-row justify-between">
              <Animated.View
                style={{
                  transform: [
                    {
                      translateY: scrollY.interpolate({
                        inputRange: [0, 100],
                        outputRange: [200, -50],
                        extrapolate: 'clamp',
                      }),
                    },
                  ],
                }}
                className="w-1/2 pr-2"
              >
                {currentUser.saved.map((item, idx) =>
                  idx % 2 === 0 ? (
                    <View
                      key={idx}
                      className="mb-4 h-40 bg-orange-100 rounded-lg justify-center items-center"
                    >
                      <Text>{item}</Text>
                    </View>
                  ) : null
                )}
                
              </Animated.View>

              <Animated.View
                style={{
                  transform: [
                    {
                      translateY: scrollY.interpolate({
                        inputRange: [0, 300],
                        outputRange: [-10, 0],
                        extrapolate: 'clamp',
                      }),
                    },
                  ],
                }}
                className="w-1/2 pl-3"
              >
                {currentUser.saved.map((item, idx) =>
                  idx % 2 !== 0 ? (
                    <View
                      key={idx}
                      className="mb-4 h-40 bg-blue-100 rounded-lg justify-center items-center"
                    >
                      <Text>{item}</Text>
                    </View>
                  ) : null
                )}
              </Animated.View>
            </View>
          </Animated.ScrollView>
        );
      case 'Creations':
        return (
          <View className="p-4">
            {currentUser.creations.map((item: string, index: number) => (
              <Text key={index} className="text-base mb-2 text-gray-800">
                {item}
              </Text>
            ))}
          </View>
        );
      case 'Followers':
        return (
          <View className="p-4">
            <Text className="text-gray-700">This tab can display follower details or links.</Text>
          </View>
        );
      default:
        return null;
    }
  };

  return (
    <StyledSafeAreaView className="flex-1 bg-[#FAF6F2]">
      <View className="relative bg-white pb-12 pt-10 px-4">
        <Pressable
          onPress={() => navigation.navigate('SettingsScreen')}
          className="absolute top-4 right-4 p-2"
        >
          <Icon name="settings" size={24} color="#4B5563" />
        </Pressable>

        <View className="flex-row items-center">
          {/* <StyledImage
            source={currentUser.profilePicture}
            className="w-24 h-24 rounded-full mr-4"
          /> */}
          <StyledImage
            source={currentUser.avatar} // now either { uri: string } or require(...)
            className="w-24 h-24 rounded-full mr-4"
          />
          <Text className="text-2xl font-bold -top-3 text-gray-900">
            {currentUser.name}
          </Text>

          <Text className="text-xs text-gray-500 mt-6 -mx-24">
            <Text className="font-bold text-gray-700">{currentUser.following}</Text> Following{' '}
            <Text className="font-bold text-gray-700">{currentUser.followers}</Text> Followers
          </Text>
        </View>

        <View className="mx-1 mt-4">
          {/* <Text className="text-sm text-gray-600">@{currentUser.username}</Text> */}
          <Text className="text-sm text-gray-600">@{currentUser.id}</Text>
          <Text className="text-sm text-gray-600">{currentUser.email}</Text>

        </View>
      </View>

      {/* Sub Nav Buttons */}
      <View className="flex-row justify-around bg-white border-y border-white">
        {['Boards', 'Creations', 'Followers'].map((tab) => (
          <Pressable
            key={tab}
            onPress={() => setActiveTab(tab as 'Boards' | 'Creations' | 'Followers')}
            className={`py-3 flex-1 items-center ${
              activeTab === tab ? 'border-b-2 border-black' : ''
            }`}
          >
            <Text
              className={`text-base ${
                activeTab === tab ? 'text-slate-800 font-bold' : 'text-gray-500'
              }`}
            >
              {tab}
            </Text>
          </Pressable>
        ))}
      </View>

      <ScrollView className="flex-1">{renderContent()}</ScrollView>

      <BottomNavBar
        currentUser={{
          id: currentUser.username,
          name: currentUser.name,
          avatar: currentUser.profilePicture.uri,
        }}
      />
    </StyledSafeAreaView>
  );
}
