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
  FollowingScreen: { userId: string };
  publicProfileScreen: { userId: string; currentUser?: any };
};

type Following = {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
  bio?: string;
};

export default function FollowingScreen() {
  const route = useRoute<RouteProp<RootStackParamList, 'FollowingScreen'>>();
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const { userId } = route.params;
  
  const [following, setFollowing] = useState<Following[]>([]);
  const [filteredFollowing, setFilteredFollowing] = useState<Following[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    const fetchFollowing = async () => {
      try {
        setLoading(true);
        
        const { data: followData, error: followError } = await supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', userId);

        if (followError) {
          console.error('Error fetching following IDs:', followError);
          return;
        }

        if (!followData || followData.length === 0) {
          setFollowing([]);
          setFilteredFollowing([]);
          setLoading(false);
          return;
        }

        const followingIds = followData.map(item => item.following_id);

        const { data: profileData, error: profileError } = await supabase
          .from('profiles')
          .select('id, username, full_name, profile_picture, bio')
          .in('id', followingIds);

        if (profileError) {
          console.error('Error fetching following profiles:', profileError);
          return;
        }

        setFollowing(profileData || []);
        setFilteredFollowing(profileData || []);
      } catch (error) {
        console.error('Error in fetchFollowing:', error);
      } finally {
        setLoading(false);
      }
    };

    if (userId) {
      fetchFollowing();
    }
  }, [userId]);

  useEffect(() => {
    if (searchQuery.trim() === '') {
      setFilteredFollowing(following);
    } else {
      const filtered = following.filter(followingUser =>
        followingUser.username?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        followingUser.full_name?.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredFollowing(filtered);
    }
  }, [searchQuery, following]);

  const handleProfilePress = (followingUser: Following) => {
    navigation.navigate('publicProfileScreen', { 
      userId: followingUser.id,
      currentUser: { id: userId },
      fromScreen: 'FollowingScreen'
    });
  };

  const renderFollowing = ({ item }: { item: Following }) => (
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
          Following
        </AppText>
        
        <View className="w-8" />
      </StyledView>

      <StyledView className="px-4 py-4 bg-white border-b border-gray-50">
        <SearchBar
          placeholder="Search following..."
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </StyledView>

      <StyledView className="flex-1 px-4 pt-3">
        {loading ? (
          <StyledView className="flex-1 items-center justify-center">
            <Icon name="people" size={24} color="#9CA3AF" />
            <AppText className="text-gray-500 text-sm font-medium mt-3">Loading following...</AppText>
          </StyledView>
        ) : filteredFollowing.length === 0 ? (
          <StyledView className="flex-1 items-center justify-center">
            <Icon name="people-outline" size={32} color="#D1D5DB" />
            <AppText className="text-gray-600 text-base font-semibold mb-2 mt-4">
              {searchQuery ? 'No following found' : 'Not following anyone yet'}
            </AppText>
            {searchQuery ? (
              <AppText className="text-gray-400 text-xs text-center">
                Try adjusting your search terms
              </AppText>
            ) : (
              <AppText className="text-gray-400 text-xs text-center">
                Start following people to see them here
              </AppText>
            )}
          </StyledView>
        ) : (
          <FlatList
            data={filteredFollowing}
            renderItem={renderFollowing}
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