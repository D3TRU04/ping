import React, { useState, useEffect } from 'react';
import { View, FlatList, TouchableOpacity, Image } from 'react-native';
import { styled } from 'nativewind';
import { useRoute, useNavigation, RouteProp, NavigationProp } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { supabase } from '../../../../lib/supabase';
import AppText from '../../../components/AppText';
import SearchBar from '../../../components/SearchBar';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

type RootStackParamList = {
  FollowersScreen: { userId: string };
  publicProfileScreen: { userId: string; currentUser?: any };
};

type Follower = {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
  bio?: string;
};

export default function FollowersScreen() {
  const route = useRoute<RouteProp<RootStackParamList, 'FollowersScreen'>>();
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const { userId } = route.params;
  
  const [followers, setFollowers] = useState<Follower[]>([]);
  const [filteredFollowers, setFilteredFollowers] = useState<Follower[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    const fetchFollowers = async () => {
      try {
        setLoading(true);
        
        const { data: followData, error: followError } = await supabase
          .from('follows')
          .select('follower_id')
          .eq('following_id', userId);

        if (followError) {
          console.error('Error fetching follower IDs:', followError);
          return;
        }

        if (!followData || followData.length === 0) {
          setFollowers([]);
          setFilteredFollowers([]);
          setLoading(false);
          return;
        }

        const followerIds = followData.map(item => item.follower_id);

        const { data: profileData, error: profileError } = await supabase
          .from('profiles')
          .select('id, username, full_name, profile_picture, bio')
          .in('id', followerIds);

        if (profileError) {
          console.error('Error fetching follower profiles:', profileError);
          return;
        }

        setFollowers(profileData || []);
        setFilteredFollowers(profileData || []);
      } catch (error) {
        console.error('Error in fetchFollowers:', error);
      } finally {
        setLoading(false);
      }
    };

    if (userId) {
      fetchFollowers();
    }
  }, [userId]);

  useEffect(() => {
    if (searchQuery.trim() === '') {
      setFilteredFollowers(followers);
    } else {
      const filtered = followers.filter(follower =>
        follower.username?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        follower.full_name?.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredFollowers(filtered);
    }
  }, [searchQuery, followers]);

  const handleProfilePress = (follower: Follower) => {
    navigation.navigate('publicProfileScreen', { 
      userId: follower.id,
      currentUser: { id: userId },
      fromScreen: 'FollowersScreen'
    });
  };

  const renderFollower = ({ item }: { item: Follower }) => (
    <StyledTouchableOpacity
      onPress={() => handleProfilePress(item)}
      className="flex-row items-center p-3 bg-white rounded-xl shadow-sm border border-gray-50"
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 2,
      }}
    >
      <View className="w-10 h-10 rounded-full overflow-hidden mr-3 border border-gray-100">
        {item.profile_picture ? (
          <Image 
            source={{ uri: item.profile_picture }} 
            className="w-full h-full"
          />
        ) : (
          <View className="w-full h-full bg-gradient-to-br from-gray-200 to-gray-300 items-center justify-center">
            <Icon name="person" size={20} color="#6B7280" />
          </View>
        )}
      </View>

      <View className="flex-1">
        <AppText className="font-semibold text-gray-900 text-sm mb-1">
          {item.full_name || 'No Name'}
        </AppText>
        <AppText className="text-gray-500 text-xs">
          @{item.username || 'no_username'}
        </AppText>
      </View>

      <Icon name="chevron-right" size={16} color="#6B7280" />
    </StyledTouchableOpacity>
  );

  return (
    <LinearGradient colors={["#FAF6F2", "#F5F5F5"]} style={{ flex: 1 }}>
      <StyledView className="flex-row items-center justify-between px-4 pt-14 pb-4 bg-white border-b border-gray-100">
        <StyledTouchableOpacity
          onPress={() => navigation.goBack()}
          className="p-2"
        >
          <Icon name="arrow-back" size={18} color="#374151" />
        </StyledTouchableOpacity>
        
        <AppText className="text-base font-semibold text-gray-900">
          Followers
        </AppText>
        
        <View className="w-8" />
      </StyledView>

      <StyledView className="px-4 py-4 bg-white border-b border-gray-50">
        <SearchBar
          placeholder="Search followers..."
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </StyledView>

      <StyledView className="flex-1 px-4 pt-3">
        {loading ? (
          <StyledView className="flex-1 items-center justify-center">
            <Icon name="people" size={24} color="#9CA3AF" />
            <AppText className="text-gray-500 text-sm font-medium mt-3">Loading followers...</AppText>
          </StyledView>
        ) : filteredFollowers.length === 0 ? (
          <StyledView className="flex-1 items-center justify-center">
            <Icon name="people-outline" size={32} color="#D1D5DB" />
            <AppText className="text-gray-600 text-base font-semibold mb-2 mt-4">
              {searchQuery ? 'No followers found' : 'No followers yet'}
            </AppText>
            {searchQuery ? (
              <AppText className="text-gray-400 text-xs text-center">
                Try adjusting your search terms
              </AppText>
            ) : (
              <AppText className="text-gray-400 text-xs text-center">
                When people follow you, they'll appear here
              </AppText>
            )}
          </StyledView>
        ) : (
          <FlatList
            data={filteredFollowers}
            renderItem={renderFollower}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={{ paddingBottom: 20 }}
            ItemSeparatorComponent={() => <View className="h-2" />}
          />
        )}
      </StyledView>
    </LinearGradient>
  );
} 