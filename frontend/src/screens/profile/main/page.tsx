import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  ScrollView,
  Animated,
  Image,
} from 'react-native';
import { styled } from 'nativewind';
import { SafeAreaView } from 'react-native-safe-area-context';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import BottomNavBar from '../../../components/BottomNavBar';
import { useNavigation, NavigationProp } from '@react-navigation/native';
import { supabase } from '../../../../lib/supabase';
import AppText from '../../../components/AppText';
import ProfileTopNavBar from '../components/NavBar';
import { LinearGradient } from 'expo-linear-gradient';
import ProfileCard from '../components/ProfileCard';
import ProfileStats from '../components/ProfileStats';
import ProfileTabs from '../components/ProfileTabs';
import ProfileEmptyState from '../components/ProfileEmptyState';
import ProfileTabContent from '../components/ProfileTabContent';

import { Image as RNImage } from 'react-native';


const StyledSafeAreaView = styled(SafeAreaView);
const StyledImage = styled(Image);

type RootStackParamList = {
  ProfileScreen: { currentUser: any };
  SettingsScreen: undefined;
  EditAccount: undefined;
  SearchUsersScreen: undefined;
  OtherUserProfileScreen: { userId: string };
  FollowingScreen: { userId: string };
  FollowersScreen: { userId: string };
};

export default function ProfileScreen() {
  const scrollY = useRef(new Animated.Value(0)).current;
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const [user, setUser] = useState<any>(null);
  const [profile, setProfile] = useState<any>(null);
  const [followers, setFollowers] = useState(0);
  const [following, setFollowing] = useState(0);
  const [activeTab, setActiveTab] = useState<'Saved' | 'Been' | 'Likes'>('Saved');

  // Fetch user
  useEffect(() => {
    const fetchUser = async () => {
      const {
        data: { user },
        error,
      } = await supabase.auth.getUser();
      if (error) {
        // Handle error silently
      }
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

      if (error) {
        // Handle error silently
      }
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
  }else{
    console.log('Profile:', profile);
  }

  // Determine profile picture with safety checks
  const profilePictureUri = profile.profile_picture && profile.profile_picture.startsWith('http')
    ? profile.profile_picture
    : null;


  // useEffect(() => {
  // if (profilePictureUri) {
  //   RNImage.prefetch(profilePictureUri);
  // }
  // }, [profilePictureUri]);

  


  console.log('Profile picture URL:', profilePictureUri);

  const currentUser = {
    id: user.id,
    name: profile.full_name || user.display_name || '',
    username: profile.username || '',
    email: user.email,
    creationDate: user.created_at?.split('T')[0],
    birthday: profile.birthday ? new Date(profile.birthday).toLocaleDateString() : '',
    profilePicture: profilePictureUri
      ? { uri: profilePictureUri }
      : require('../../../../src/assets/profilepic.png'),
    saved: (profile.saved as string[]) || [],
    been: (profile.been as string[]) || [],
    likes: (profile.likes as string[]) || [],
    creations: [], // optional
    following,
    followers,
  };

  return (
    <LinearGradient colors={["#FAF6F2", "#F5F5F5"]} style={{ flex: 1 }}>
      <ProfileTopNavBar currentUser={currentUser} />
      <ScrollView contentContainerStyle={{ flexGrow: 1 }}>
        {/* Profile Card */}
        <ProfileCard
          profilePicture={currentUser.profilePicture}
          fullName={profile.full_name}
          pronouns={profile.pronouns}
          username={currentUser.username}
          creationDate={
            currentUser.creationDate
              ? new Date(currentUser.creationDate).toLocaleString('default', {
                  month: 'long',
                  year: 'numeric',
                })
              : ''
          }
          bio={profile.bio}
          location={profile.location}
          links={profile.links}
        >
          <ProfileStats
            following={following}
            followers={followers}
            onPressFollowing={() => navigation.navigate('FollowingScreen', { userId: currentUser.id })}
            onPressFollowers={() => navigation.navigate('FollowersScreen', { userId: currentUser.id })}
          />
          <ProfileTabs activeTab={activeTab} setActiveTab={setActiveTab} />
        </ProfileCard>

        {/* Divider */}
        <View className="mx-4 mb-2 border-b border-gray-200" />

        {/* Tab Content */}
        <View className="flex-1 min-h-[200px]">
          <ProfileTabContent
            activeTab={activeTab}
            currentUser={currentUser}
            scrollY={scrollY}
            isOwnProfile={true}
          />
        </View>
      </ScrollView>

      <BottomNavBar
        currentUser={{
          id: currentUser.id,
          name: currentUser.name,
          avatar: profilePictureUri || null,
        }}
      />
    </LinearGradient>
  );
}
