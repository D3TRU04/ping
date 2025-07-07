import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  Image,
  Button,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { supabase } from '../../../../lib/supabase';
import AppText from '../../../components/AppText';
import { MaterialIcons as Icon } from '@expo/vector-icons';

const PublicProfileScreen = () => {
  const { params } = useRoute<any>();
  const navigation = useNavigation();
  const [profile, setProfile] = useState<any>(null);
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);
  const [isFollowing, setIsFollowing] = useState(false);

  const viewedUserId = params.userId;

  useEffect(() => {
    const fetchAuthUser = async () => {
      const { data } = await supabase.auth.getUser();
      if (data?.user) setCurrentUserId(data.user.id);
    };
    fetchAuthUser();
  }, []);

  useEffect(() => {
    const fetchProfile = async () => {
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', viewedUserId)
        .single();
      setProfile(data);
    };

    const checkFollowStatus = async () => {
      if (!currentUserId) return;
      const { data } = await supabase
        .from('follows')
        .select('*')
        .eq('follower_id', currentUserId)
        .eq('following_id', viewedUserId);
      setIsFollowing(Array.isArray(data) && data.length > 0);
    };

    fetchProfile();
    checkFollowStatus();
  }, [viewedUserId, currentUserId]);

  const handleFollow = async () => {
    if (!currentUserId || isFollowing) return;
    await supabase.from('follows').insert({
      follower_id: currentUserId,
      following_id: viewedUserId,
    });
    setIsFollowing(true);
  };

  if (!profile)
    return (
      <View className="flex-1 justify-center items-center">
        <Text>Loading...</Text>
      </View>
    );

  return (
    <ScrollView className="my-20">
      {/* Back Button */}
      <TouchableOpacity
        onPress={() => navigation.goBack()}
        className="mb-4 flex-row items-center"
      >
        <Icon name="arrow-back" size={24} color="#1FC9C3" />
        <Text className="ml-2 text-[#1FC9C3] text-base font-medium">Back</Text>
      </TouchableOpacity>

      {/* Profile Content */}
      <View className="items-center">
        <Image
          source={
            profile.profile_picture
              ? { uri: profile.profile_picture }
              : require('../../../../src/assets/profilepic.png')
          }
          className="w-24 h-24 rounded-full mb-4"
        />
        <AppText className="text-2xl font-bold text-gray-800">{profile.full_name}</AppText>
        <AppText className="text-gray-500">@{profile.username}</AppText>
        {profile.bio && <AppText className="mt-2 text-center">{profile.bio}</AppText>}

        {!isFollowing && currentUserId !== viewedUserId && (
          <Button title="Follow" onPress={handleFollow} />
        )}
      </View>
    </ScrollView>
  );
};

export default PublicProfileScreen;
