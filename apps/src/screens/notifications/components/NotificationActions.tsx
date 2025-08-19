import React, { useState } from 'react';
import {
  View,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';
import { Notification } from '../types/Notification';
import { supabase } from '../../../../lib/supabase';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface NotificationActionsProps {
  notification: Notification;
  onActionComplete: () => void;
}

const NotificationActions: React.FC<NotificationActionsProps> = ({
  notification,
  onActionComplete,
}) => {
  const [loading, setLoading] = useState(false);

  const handleAcceptFriendRequest = async () => {
    if (!notification.metadata?.senderId) return;

    setLoading(true);
    try {
      // Update friendship status to accepted
      const { error: updateError } = await supabase
        .from('friendships')
        .update({ status: 'accepted' })
        .eq('user_id', notification.metadata.senderId)
        .eq('friend_id', notification.metadata.recipientId || '');

      if (updateError) throw updateError;

      // Create a notification for the requester
      const { error: notificationError } = await supabase
        .from('notifications')
        .insert({
          recipient_id: notification.metadata.senderId,
          sender_id: notification.metadata.recipientId,
          type: 'system',
          title: 'Friend Request Accepted',
          message: 'Your friend request was accepted!',
          is_read: false,
        });

      if (notificationError) throw notificationError;

      Alert.alert('Success', 'Friend request accepted!');
      onActionComplete();
    } catch (error) {
      console.error('Error accepting friend request:', error);
      Alert.alert('Error', 'Failed to accept friend request. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleDeclineFriendRequest = async () => {
    if (!notification.metadata?.senderId) return;

    Alert.alert(
      'Decline Friend Request',
      'Are you sure you want to decline this friend request?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Decline',
          style: 'destructive',
          onPress: async () => {
            setLoading(true);
            try {
              const { error } = await supabase
                .from('friendships')
                .delete()
                .eq('user_id', notification.metadata.senderId)
                .eq('friend_id', notification.metadata.recipientId || '');

              if (error) throw error;

              Alert.alert('Success', 'Friend request declined.');
              onActionComplete();
            } catch (error) {
              console.error('Error declining friend request:', error);
              Alert.alert('Error', 'Failed to decline friend request. Please try again.');
            } finally {
              setLoading(false);
            }
          },
        },
      ]
    );
  };

  const handleFollowBack = async () => {
    if (!notification.metadata?.senderId) return;

    setLoading(true);
    try {
      // Check if already following
      const { data: existingFollow, error: checkError } = await supabase
        .from('follows')
        .select('*')
        .eq('follower_id', notification.metadata.recipientId)
        .eq('following_id', notification.metadata.senderId)
        .single();

      if (checkError && checkError.code !== 'PGRST116') throw checkError;

      if (existingFollow) {
        Alert.alert('Already Following', 'You are already following this user.');
        return;
      }

      // Create follow relationship
      const { error: followError } = await supabase
        .from('follows')
        .insert({
          follower_id: notification.metadata.recipientId,
          following_id: notification.metadata.senderId,
        });

      if (followError) throw followError;

      // Create notification for the user being followed back
      const { error: notificationError } = await supabase
        .from('notifications')
        .insert({
          recipient_id: notification.metadata.senderId,
          sender_id: notification.metadata.recipientId,
          type: 'follow',
          title: 'New Follower',
          message: 'Someone followed you back!',
          is_read: false,
        });

      if (notificationError) throw notificationError;

      Alert.alert('Success', 'You are now following back!');
      onActionComplete();
    } catch (error) {
      console.error('Error following back:', error);
      Alert.alert('Error', 'Failed to follow back. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleViewProfile = () => {
    if (notification.metadata?.senderId) {
      Alert.alert('View Profile', `View ${notification.metadata?.senderName || 'user'}'s profile`);
    }
  };

  const handleViewPlace = () => {
    if (notification.metadata?.placeName) {
      Alert.alert('View Place', `View ${notification.metadata.placeName} details`);
    }
  };

  if (loading) {
    return (
      <StyledView className="flex-row justify-center items-center p-4">
        <ActivityIndicator size="small" color={COLORS.mint} />
        <AppText className="text-mint ml-2">Processing...</AppText>
      </StyledView>
    );
  }

  // Render different actions based on notification type
  switch (notification.type) {
    case 'friend_request':
      return (
        <StyledView className="flex-row justify-end space-x-2 p-4 pt-0">
          <StyledTouchableOpacity
            onPress={handleDeclineFriendRequest}
            className="px-4 py-2 rounded-full border border-red-500"
          >
            <AppText className="text-red-500 font-semibold">Decline</AppText>
          </StyledTouchableOpacity>
          <StyledTouchableOpacity
            onPress={handleAcceptFriendRequest}
            className="px-4 py-2 rounded-full bg-mint"
          >
            <AppText className="text-white font-semibold">Accept</AppText>
          </StyledTouchableOpacity>
        </StyledView>
      );

    case 'follow':
      return (
        <StyledView className="flex-row justify-end space-x-2 p-4 pt-0">
          <StyledTouchableOpacity
            onPress={handleViewProfile}
            className="px-4 py-2 rounded-full border border-gray-300"
          >
            <AppText className="text-gray-700 font-semibold">View Profile</AppText>
          </StyledTouchableOpacity>
          <StyledTouchableOpacity
            onPress={handleFollowBack}
            className="px-4 py-2 rounded-full bg-mint"
          >
            <AppText className="text-white font-semibold">Follow Back</AppText>
          </StyledTouchableOpacity>
        </StyledView>
      );

    case 'place_visit':
      return (
        <StyledView className="flex-row justify-end space-x-2 p-4 pt-0">
          <StyledTouchableOpacity
            onPress={handleViewPlace}
            className="px-4 py-2 rounded-full bg-mint"
          >
            <AppText className="text-white font-semibold">View Place</AppText>
          </StyledTouchableOpacity>
        </StyledView>
      );

    default:
      return null;
  }
};

export default NotificationActions; 