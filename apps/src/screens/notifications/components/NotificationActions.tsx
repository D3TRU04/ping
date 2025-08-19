import React, { useState } from 'react';
import { View, TouchableOpacity, Alert } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { supabase } from '../../../../lib/supabase';
import AppText from '../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface NotificationActionsProps {
  notification: any;
  onActionComplete: () => void;
}

const NotificationActions: React.FC<NotificationActionsProps> = ({
  notification,
  onActionComplete,
}) => {
  const [loading, setLoading] = useState(false);

  const handleFollowBack = async () => {
    if (!notification.metadata?.senderId) return;

    setLoading(true);
    try {
      // Follow the user back
      const { error } = await supabase
        .from('follows')
        .upsert({
          follower_id: notification.metadata.recipientId,
          following_id: notification.metadata.senderId,
          followed_at: new Date().toISOString(),
        }, {
          onConflict: 'follower_id, following_id'
        });

      if (error) throw error;

      Alert.alert('Success', 'You are now following this user back!');
      onActionComplete();
    } catch (error) {
      console.error('Error following user back:', error);
      Alert.alert('Error', 'Failed to follow user back. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleViewProfile = () => {
    // Navigate to user profile
    // This would need navigation context
    Alert.alert('View Profile', 'Navigate to user profile');
  };

  const handleViewPlace = () => {
    // Navigate to place details
    // This would need navigation context
    Alert.alert('View Place', 'Navigate to place details');
  };

  const handleOpenChat = () => {
    // Navigate to chat
    // This would need navigation context
    Alert.alert('Open Chat', 'Navigate to chat conversation');
  };

  const renderActions = () => {
    switch (notification.type) {
      case 'follow':
        return (
          <StyledTouchableOpacity
            onPress={handleFollowBack}
            disabled={loading}
            className="bg-[#1FC9C3] px-4 py-2 rounded-lg mr-2"
          >
            <AppText className="text-white font-medium">
              {loading ? 'Following...' : 'Follow Back'}
            </AppText>
          </StyledTouchableOpacity>
        );

      case 'place_visit':
        return (
          <StyledTouchableOpacity
            onPress={handleViewPlace}
            className="bg-[#1FC9C3] px-4 py-2 rounded-lg mr-2"
          >
            <AppText className="text-white font-medium">View Place</AppText>
          </StyledTouchableOpacity>
        );

      case 'place_recommendation':
        return (
          <StyledTouchableOpacity
            onPress={handleViewPlace}
            className="bg-[#1FC9C3] px-4 py-2 rounded-lg mr-2"
          >
            <AppText className="text-white font-medium">View Place</AppText>
          </StyledTouchableOpacity>
        );

      case 'chat_message':
        return (
          <StyledTouchableOpacity
            onPress={handleOpenChat}
            className="bg-[#1FC9C3] px-4 py-2 rounded-lg mr-2"
          >
            <AppText className="text-white font-medium">Open Chat</AppText>
          </StyledTouchableOpacity>
        );

      default:
        return null;
    }
  };

  if (!renderActions()) return null;

  return (
    <StyledView className="flex-row items-center mt-3">
      {renderActions()}
      
      <StyledTouchableOpacity
        onPress={handleViewProfile}
        className="border border-gray-300 px-4 py-2 rounded-lg"
      >
        <AppText className="text-gray-700 font-medium">View Profile</AppText>
      </StyledTouchableOpacity>
    </StyledView>
  );
};

export default NotificationActions; 