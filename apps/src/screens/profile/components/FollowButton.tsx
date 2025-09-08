import React, { useState, useEffect } from 'react';
import { View, TouchableOpacity, ActivityIndicator, Alert } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { supabase } from '../../../../lib/supabase';
import { createFollowNotification } from '../../notifications/services/notificationCreators';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface FollowButtonProps {
  currentUserId: string;
  profileUserId: string;
  onFollowChange?: (isFollowing: boolean) => void;
}

export default function FollowButton({ 
  currentUserId, 
  profileUserId, 
  onFollowChange 
}: FollowButtonProps) {
  const [isFollowing, setIsFollowing] = useState(false);
  const [isFriends, setIsFriends] = useState(false);
  const [loading, setLoading] = useState(false);
  const [initialLoading, setInitialLoading] = useState(true);

  // Check initial follow status
  useEffect(() => {
    const checkFollowStatus = async () => {
      if (!currentUserId || !profileUserId || currentUserId === profileUserId) {
        setInitialLoading(false);
        return;
      }

      try {
        // Simple check for existing follow
        const { data: followData, error: followError } = await supabase
          .from('follows')
          .select('follower_id, following_id')
          .eq('follower_id', currentUserId)
          .eq('following_id', profileUserId)
          .single();

        if (followError && followError.code !== 'PGRST116') {
          // Silent error handling for production
        }

        const following = !!followData;
        setIsFollowing(following);

        // Check for mutual follow
        if (following) {
          const { data: mutualData, error: mutualError } = await supabase
            .from('follows')
            .select('follower_id, following_id')
            .eq('follower_id', profileUserId)
            .eq('following_id', currentUserId)
            .single();

          if (mutualError && mutualError.code !== 'PGRST116') {
            // Silent error handling for production
          }

          setIsFriends(!!mutualData);
        }

      } catch (error) {
        console.error('Error checking follow status:', error);
      } finally {
        setInitialLoading(false);
      }
    };

    checkFollowStatus();
  }, [currentUserId, profileUserId]);

  const handleFollowToggle = async () => {
    if (loading || currentUserId === profileUserId) return;

    if (isFollowing) {
      Alert.alert(
        'Unfollow User',
        `Are you sure you want to unfollow ${isFriends ? 'this friend' : 'this user'}?`,
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Unfollow', style: 'destructive', onPress: performUnfollow },
        ]
      );
      return;
    }

    await performFollow();
  };

  const performUnfollow = async () => {
    setLoading(true);
    try {
      const { error } = await supabase
        .from('follows')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('following_id', profileUserId);

      if (error) throw error;

      setIsFollowing(false);
      setIsFriends(false);
      onFollowChange?.(false);
      Alert.alert('Unfollowed', 'You have unfollowed this user');
    } catch (error) {
      console.error('Error unfollowing:', error);
      Alert.alert('Error', 'Failed to unfollow user. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const performFollow = async () => {
    setLoading(true);
    try {
      const { error } = await supabase
        .from('follows')
        .upsert({
          follower_id: currentUserId,
          following_id: profileUserId,
          followed_at: new Date().toISOString(),
        }, {
          onConflict: 'follower_id, following_id'
        });

      if (error) throw error;

      setIsFollowing(true);
      onFollowChange?.(true);

      // Create follow notification
      const notificationSuccess = await createFollowNotification(currentUserId, profileUserId);
      if (notificationSuccess) {
        console.log('Follow notification created successfully');
      } else {
        console.log('Failed to create follow notification');
      }

      // Check for mutual follow
      const { data: mutualData, error: mutualError } = await supabase
        .from('follows')
        .select('follower_id, following_id')
        .eq('follower_id', profileUserId)
        .eq('following_id', currentUserId)
        .single();

      if (mutualError && mutualError.code !== 'PGRST116') {
        // Silent error handling for production
      }

      const mutual = !!mutualData;
      setIsFriends(mutual);

      // if (mutual) {
      //   Alert.alert('New Friend!', 'You are now friends with this user! 🎉');
      // } else {
      //   Alert.alert('Following', 'You are now following this user');
      // }
    } catch (error) {
      console.error('Error following user:', error);
      Alert.alert('Error', 'Failed to follow user. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  if (currentUserId === profileUserId) return null;
  if (initialLoading) {
    return (
      <StyledView className="w-full items-center py-2">
        <ActivityIndicator size="small" color="#1FC9C3" />
      </StyledView>
    );
  }

  const getButtonStyle = () => {
    if (isFriends) return 'bg-green-500';
    if (isFollowing) return 'bg-red-500';
    return 'bg-[#1FC9C3]';
  };

  const getButtonText = () => {
    if (isFriends) return 'Friends';
    if (isFollowing) return 'Unfollow';
    return 'Follow';
  };

  const getButtonIcon = () => {
    if (isFriends) return 'people';
    if (isFollowing) return 'person-remove';
    return 'person-add';
  };

  return (
    <StyledView className="w-full items-center py-2">
      <StyledTouchableOpacity
        onPress={handleFollowToggle}
        disabled={loading}
        className={`px-6 py-3 rounded-full flex-row items-center space-x-2 ${getButtonStyle()}`}
        // style={({ pressed }) => [
        //   { opacity: pressed ? 0.8 : 1, transform: [{ scale: pressed ? 0.95 : 1 }] },
        // ]}
      >
        {loading ? (
          <ActivityIndicator size="small" color="white" />
        ) : (
          <>
            <Icon name={getButtonIcon() as any} size={20} color="white" />
            <AppText className="font-semibold text-white">{getButtonText()}</AppText>
          </>
        )}
      </StyledTouchableOpacity>
    </StyledView>
  );
} 