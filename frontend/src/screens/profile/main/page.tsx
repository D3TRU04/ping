import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  Image,
  Pressable,
  ScrollView,
  Animated,
} from 'react-native';
import { styled } from 'nativewind';
import { SafeAreaView } from 'react-native-safe-area-context';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import BottomNavBar from '../../../components/navbar/BottomNavBar';
import { useNavigation, NavigationProp } from '@react-navigation/native';
import { supabase } from '../../../../lib/supabase';
import AppText from '../../../components/AppText';
import ProfileTopNavBar from '../../../components/navbar/Profile';
import { LinearGradient } from 'expo-linear-gradient';


const StyledSafeAreaView = styled(SafeAreaView);
const StyledImage = styled(Image);

type RootStackParamList = {
  ProfileScreen: { currentUser: any };
  SettingsScreen: undefined;
  EditAccount: undefined;
};

export default function ProfileScreen() {
  const scrollY = useRef(new Animated.Value(0)).current;
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const [user, setUser] = useState<any>(null);
  const [profile, setProfile] = useState<any>(null);
  const [followers, setFollowers] = useState(0);
  const [following, setFollowing] = useState(0);
  const [activeTab, setActiveTab] = useState<'Saved' | 'Creations' | 'Followers'>('Saved');

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
      <View className="flex-1 justify-center items-center bg-[#FAF6F2]">
        <AppText>Loading profile...</AppText>
      </View>
    );
  }

  const currentUser = {
    id: user.id,
    name: profile.full_name || user.display_name || '',
    username: profile.username || '',
    email: user.email,
    creationDate: user.created_at?.split('T')[0],
    birthday: profile.birthday ? new Date(profile.birthday).toLocaleDateString() : '',
    profilePicture: profile.profile_picture
      ? { uri: profile.profile_picture }
      : require('../../../assets/profilepic.png'),
    saved: (profile.saved as string[]) || [],
    creations: [], // optional: you can query a 'creations' table
    following,
    followers,
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'Saved':
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
                      className="mb-4 h-40 bg-[#FF5C5C]/10 rounded-lg justify-center items-center"
                    >
                      <AppText>{item}</AppText>
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
                      className="mb-4 h-40 bg-[#FF5C5C]/10 rounded-lg justify-center items-center"
                    >
                      <AppText>{item}</AppText>
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
              <AppText key={index} className="text-base mb-2 text-gray-800">
                {item}
              </AppText>
            ))}
          </View>
        );
      case 'Followers':
        return (
          <View className="p-4">
            <AppText className="text-gray-700">This tab can display follower details or links.</AppText>
          </View>
        );
      default:
        return null;
    }
  };

  return (
    <LinearGradient
      colors={["#FAF6F2", "#F5F5F5"]}
      style={{ flex: 1 }}
    >
      <ProfileTopNavBar currentUser={currentUser} />
      <ScrollView contentContainerStyle={{ flexGrow: 1 }}>
        {/* Profile Card */}
        <View className="mx-4 mt-6 mb-2 bg-white rounded-2xl shadow-lg p-6 items-center">
          {/* Profile Picture with border and shadow, using NativeWind */}
          <View className="items-center justify-center mb-3 border-4 border-[#E0E7EF] rounded-full">
            <StyledImage
              source={currentUser.profilePicture}
              className="w-28 h-28 rounded-full"
              style={{
                shadowColor: '#000',
                shadowOpacity: 0.1,
                shadowRadius: 8,
                shadowOffset: { width: 0, height: 2 },
              }}
            />
          </View>
          {profile.full_name && (
            <AppText className="text-3xl font-bold text-gray-900 mb-1" style={{ fontFamily: 'Satoshi-Medium' }}>
              {profile.full_name}
            </AppText>
          )}
          <AppText className="text-base text-gray-500 mb-1" style={{ fontFamily: 'Satoshi-Medium' }}>
            @{profile.username || 'No Username'}
          </AppText>
          <AppText className="text-sm text-gray-500 mb-1">
            <AppText className="font-bold text-gray-700">{following}</AppText> Following{' '}
            <AppText className="font-bold text-gray-700">{followers}</AppText> Followers
          </AppText>
          {profile.bio && (
            <AppText className="text-base text-gray-700 mt-2 mb-1" style={{ fontFamily: 'Satoshi-Medium' }}>
              {profile.bio}
            </AppText>
          )}
          {profile.links && (
            <AppText className="text-base text-blue-700 underline mb-1" style={{ fontFamily: 'Satoshi-Medium' }}>
              {profile.links}
            </AppText>
          )}
          {profile.pronouns && (
            <AppText className="text-base text-gray-500 mb-1" style={{ fontFamily: 'Satoshi-Medium' }}>
              {profile.pronouns}
            </AppText>
          )}
          {profile.location && (
            <AppText className="text-base text-gray-500 mb-1" style={{ fontFamily: 'Satoshi-Medium' }}>
              {profile.location}
            </AppText>
          )}
        </View>
        {/* Divider */}
        <View className="mx-4 mb-2 border-b border-gray-200" />
        {/* Tabs */}
        <View className="flex-row justify-center mb-2">
          {['Saved'].map((tab) => (
            <Pressable
              key={tab}
              onPress={() => setActiveTab(tab as 'Saved')}
              className={`px-6 py-2 mx-1 rounded-full ${activeTab === tab ? 'bg-[#00B4D8]' : 'bg-gray-100'}`}
              style={{ elevation: activeTab === tab ? 2 : 0 }}
            >
              <AppText
                className={`text-base ${activeTab === tab ? 'text-white font-bold' : 'text-gray-500'}`}
                style={{ fontFamily: 'Satoshi-Medium' }}
              >
                {tab}
              </AppText>
            </Pressable>
          ))}
        </View>
        {/* Tab Content */}
        <View className="flex-1 min-h-[200px]">
          {renderContent()}
        </View>
      </ScrollView>
      <BottomNavBar
        currentUser={{
          id: currentUser.id,
          name: currentUser.name,
          avatar: typeof currentUser.profilePicture === 'object' && currentUser.profilePicture.uri
            ? currentUser.profilePicture.uri
            : null,
        }}
      />
    </LinearGradient>
  );
}
