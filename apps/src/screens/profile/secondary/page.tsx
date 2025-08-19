import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  ScrollView,
  Animated,
} from 'react-native';
import { styled } from 'nativewind';
import { SafeAreaView } from 'react-native-safe-area-context';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import BottomNavBar from '../../../components/BottomNavBar';
import { useNavigation, NavigationProp, useRoute, RouteProp, useFocusEffect } from '@react-navigation/native';
import { supabase } from '../../../../lib/supabase';
import AppText from '../../../components/AppText';
import ProfileTopNavBar from './components/SecondaryProfile';
import { LinearGradient } from 'expo-linear-gradient';
import ProfileCard from '../components/ProfileCard';
import ProfileStats from '../components/ProfileStats';
import ProfileTabs from '../components/ProfileTabs';
import ProfileEmptyState from '../components/ProfileEmptyState';
import ProfileTabContent from '../components/ProfileTabContent';
import { useAuth } from '../../../contexts/AuthContext';


const StyledSafeAreaView = styled(SafeAreaView);

type RootStackParamList = {
  ProfileScreen: { currentUser: any };
  SettingsScreen: undefined;
  EditAccount: undefined;
  SearchUsersScreen: undefined;
  OtherUserProfileScreen: { userId: string };
  publicProfileScreen: { userId: string; currentUser?: any };
  FollowingScreen: { userId: string };
  FollowersScreen: { userId: string };
  Chats: { currentUser: any };
  ChatRoomScreen: { currentUser: any; otherUser: any; conversationId: string };
};

export default function ProfileScreen() {
  const scrollY = useRef(new Animated.Value(0)).current;
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const route = useRoute<RouteProp<RootStackParamList, 'publicProfileScreen'>>();
  const userId = route.params?.userId;
  const routeCurrentUser = route.params?.currentUser;
  const [profile, setProfile] = useState<any>(null);
  const [followers, setFollowers] = useState(0);
  const [following, setFollowing] = useState(0);
  const [activeTab, setActiveTab] = useState<'Saved' | 'Been' | 'Likes'>('Saved');
  const [currentUser, setCurrentUser] = useState<any>(null);

  // Get current user from auth or route params
  useEffect(() => {
    const getCurrentUser = async () => {
      if (routeCurrentUser) {
        setCurrentUser(routeCurrentUser);
        return;
      }

      try {
        const { data: { user }, error } = await supabase.auth.getUser();
        if (error) {
          console.error('Error getting current user:', error);
          return;
        }
        
        if (user) {
          // Get current user profile
          const { data: profileData, error: profileError } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .single();

          if (profileError) {
            console.error('Error getting current user profile:', profileError);
            return;
          }

          setCurrentUser({
            id: user.id,
            name: profileData.full_name || profileData.username || '',
            username: profileData.username || '',
            email: profileData.email,
            profilePicture: profileData.profile_picture
              ? { uri: profileData.profile_picture }
              : require('../../../assets/profilepic.png'),
          });
        }
      } catch (error) {
        console.error('Error in getCurrentUser:', error);
      }
    };

    getCurrentUser();
  }, [routeCurrentUser]);

  // Fetch profile
  useEffect(() => {
    if (!userId) return;

    const fetchProfile = async () => {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) {
        // Handle error silently
      }
      else setProfile(data);
    };

    fetchProfile();
  }, [userId]);

  // Fetch follower/following counts
  useEffect(() => {
    if (!userId) return;

    const fetchFollowCounts = async () => {
      const [{ count: followersCount }, { count: followingCount }] = await Promise.all([
        supabase
          .from('follows')
          .select('*', { count: 'exact', head: true })
          .eq('following_id', userId),
        supabase
          .from('follows')
          .select('*', { count: 'exact', head: true })
          .eq('follower_id', userId),
      ]);

      setFollowers(followersCount || 0);
      setFollowing(followingCount || 0);
    };

    fetchFollowCounts();
  }, [userId]);

  // Refresh counts when profile comes into focus
  useFocusEffect(
    React.useCallback(() => {
      if (userId) {
        const fetchFollowCounts = async () => {
          const [{ count: followersCount }, { count: followingCount }] = await Promise.all([
            supabase
              .from('follows')
              .select('*', { count: 'exact', head: true })
              .eq('following_id', userId),
            supabase
              .from('follows')
              .select('*', { count: 'exact', head: true })
              .eq('follower_id', userId),
          ]);

          setFollowers(followersCount || 0);
          setFollowing(followingCount || 0);
        };

        fetchFollowCounts();
      }
    }, [userId])
  );

  if (!profile || !currentUser) {
    return (
      <View className="flex-1 justify-center items-center bg-[#FAF6F2]">
        <AppText>Loading profile...</AppText>
      </View>
    );
  }

  const profileUser = {
    id: profile.id,
    name: profile.full_name || profile.display_name || '',
    username: profile.username || '',
    email: profile.email,
    creationDate: profile.created_at?.split('T')[0],
    birthday: profile.birthday ? new Date(profile.birthday).toLocaleDateString() : '',
    profilePicture: profile.profile_picture
      ? { uri: profile.profile_picture }
      : require('../../../assets/profilepic.png'),
    saved: (profile.saved as string[]) || [],
    been: (profile.been as string[]) || [],
    likes: (profile.likes as string[]) || [],
    creations: [], // optional: you can query a 'creations' table
    following,
    followers,
  };

  const handleFollowChange = (isFollowing: boolean) => {
    // Update the follower count when follow status changes
    if (isFollowing) {
      setFollowers(prev => prev + 1);
    } else {
      setFollowers(prev => Math.max(0, prev - 1));
    }

    // Refresh follow counts from database to ensure accuracy
    const refreshFollowCounts = async () => {
      if (!userId) return;

      try {
        const [{ count: followersCount }, { count: followingCount }] = await Promise.all([
          supabase
            .from('follows')
            .select('*', { count: 'exact', head: true })
            .eq('following_id', userId),
          supabase
            .from('follows')
            .select('*', { count: 'exact', head: true })
            .eq('follower_id', userId),
        ]);

        setFollowers(followersCount || 0);
        setFollowing(followingCount || 0);
      } catch (error) {
        console.error('Error refreshing follow counts:', error);
      }
    };

    // Small delay to ensure database update is complete
    setTimeout(refreshFollowCounts, 500);
  };

  return (
    <LinearGradient
      colors={["#FAF6F2", "#F5F5F5"]}
      style={{ flex: 1 }}
    >
      <ProfileTopNavBar currentUser={profileUser} />
      <ScrollView contentContainerStyle={{ flexGrow: 1 }}>
        {/* Profile Card */}
        <ProfileCard
          profilePicture={profileUser.profilePicture}
          fullName={profile.full_name}
          pronouns={profile.pronouns}
          username={profileUser.username}
          creationDate={profileUser.creationDate ? new Date(profileUser.creationDate).toLocaleString('default', { month: 'long', year: 'numeric' }) : ''}
          bio={profile.bio}
          location={profile.location}
          links={profile.links}
          currentUserId={currentUser.id}
          profileUserId={profileUser.id}
          showFollowButton={true}
          onFollowChange={handleFollowChange}
        >
          <ProfileStats
            following={following}
            followers={followers}
            onPressFollowing={() => navigation.navigate('FollowingScreen', { userId: profileUser.id })}
            onPressFollowers={() => navigation.navigate('FollowersScreen', { userId: profileUser.id })}
          />
          <ProfileTabs activeTab={activeTab} setActiveTab={setActiveTab} />
        </ProfileCard>
        {/* Divider */}
        <View className="mx-4 mb-2 border-b border-gray-200" />
        {/* Tab Content */}
        <View className="flex-1 min-h-[200px]">
          <ProfileTabContent
            activeTab={activeTab}
            currentUser={profileUser}
            scrollY={scrollY}
            isOwnProfile={false}
          />
        </View>
      </ScrollView>
      <BottomNavBar
        currentUser={{
          id: profileUser.id,
          name: profile.full_name || profile.username || 'User',
          avatar: typeof profileUser.profilePicture === 'object' && profileUser.profilePicture.uri
            ? profileUser.profilePicture.uri
            : null,
        }}
      />
    </LinearGradient>
  );
}
