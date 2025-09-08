import React, { useState, useEffect } from 'react';
import {
  View,
  TouchableOpacity,
  Image,
  Alert,
} from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';
import { Notification } from '../types/Notification';
import { formatTimestamp, getNotificationIcon, getNotificationColor } from '../services/notificationUtils';
import { supabase } from '../../../../lib/supabase';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

interface NotificationItemProps {
  notification: Notification;
  onPress: (notification: Notification) => void;
  onMarkAsRead: (notificationId: string) => void;
  onDelete: (notificationId: string) => void;
  onActionComplete?: () => void;
}

const NotificationItem: React.FC<NotificationItemProps> = ({
  notification,
  onPress,
  onMarkAsRead,
  onDelete,
  onActionComplete,
}) => {
  const [loading, setLoading] = useState(false);
  const [isFollowing, setIsFollowing] = useState(notification.metadata?.isFollowing || false);
  const [checkingFollow, setCheckingFollow] = useState(false);

  const getNotificationTitle = () => {
    switch (notification.type) {
      case 'follow': return 'New Follower';
      case 'place_visit': return 'Place Visit';
      case 'place_recommendation': return 'Place Recommendation';
      case 'chat_message': return 'New Message';
      case 'system': return 'System Notification';
      default: return 'Notification';
    }
  };

  const handleLongPress = () => {
    Alert.alert(
      'Notification Options',
      'What would you like to do?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Mark as Read', onPress: () => onMarkAsRead(notification.id) },
        { text: 'Delete', style: 'destructive', onPress: () => onDelete(notification.id) },
      ]
    );
  };

  const getAvatarSource = () => {
    if (notification.metadata?.senderAvatar) {
      return { uri: notification.metadata.senderAvatar };
    }
    if (notification.metadata?.placeImage) {
      return { uri: notification.metadata.placeImage };
    }
    return null;
  };

  const parseBoldText = (text: string) => {
    const parts = text.split(/(\*\*.*?\*\*)/g);
    return parts.map((part, index) => {
      if (part.startsWith('**') && part.endsWith('**')) {
        const boldText = part.slice(2, -2);
        return (
          <AppText 
            key={index} 
            className={`font-extrabold text-sm${
              notification.is_read ? 'text-gray-600' : 'text-gray-900'
            }`}
          >
            {boldText}
          </AppText>
        );
      }
      return (
        <AppText 
          key={index} 
          className={`text-sm font-extrabold ${
            notification.is_read ? 'text-gray-600' : 'text-gray-900'
          }`}
        >
          {part}
        </AppText>
      );
    });
  };

  const getNotificationMessage = () => {
    switch (notification.type) {
      case 'follow':
        return parseBoldText(notification.message || `${notification.metadata?.senderName || 'Someone'} has followed you`);
      case 'place_visit':
        return `You recently visited ${notification.metadata?.placeName || 'a place'}`;
      case 'place_recommendation':
        return `${notification.metadata?.senderName || 'Someone'} recommended ${notification.metadata?.placeName || 'a place'} to you`;
      case 'chat_message':
        return `${notification.metadata?.senderName || 'Someone'} sent you a message: ${notification.metadata?.messagePreview || ''}`;
      case 'system':
        return notification.message || 'System notification';
      default:
        return notification.message || 'Notification';
    }
  };

  const handleFollowBack = async () => {
    if (!notification.sender_id) return;

    setLoading(true);
    try {
      // Follow the user back
      const { error } = await supabase
        .from('follows')
        .upsert({
          follower_id: notification.recipient_id, // Current user (who received the notification)
          following_id: notification.sender_id,   // Person to follow back (who sent the notification)
          followed_at: new Date().toISOString(),
        }, {
          onConflict: 'follower_id, following_id'
        });

      if (error) throw error;

      // Update follow status
      setIsFollowing(true);
      
      // Update the notification metadata to reflect the new follow status
      notification.metadata = {
        ...notification.metadata,
        isFollowing: true
      };
      
      onActionComplete?.();
    } catch (error) {
      console.error('Error following user back:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <StyledTouchableOpacity
      onPress={() => onPress(notification)}
      onLongPress={handleLongPress}
      className={`rounded-lg overflow-hidden ${
        notification.is_read ? 'bg-white' : 'bg-gray-200'
      }`}
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: notification.is_read ? 0.05 : 0.1,
        shadowRadius: 2,
        elevation: notification.is_read ? 1 : 2,
        borderWidth: notification.is_read ? 0 : 1,
        borderColor: notification.is_read ? 'transparent' : '#E5E7EB',
      }}
    >
      <StyledView className="flex-row items-center p-2">
        {/* Avatar/Icon */}
        <StyledView className="relative">
          {getAvatarSource() ? (
            <StyledImage
              source={getAvatarSource() || { uri: '' }}
              className="w-8 h-8 rounded-full"
              onError={() => {
                // Handle image loading failure silently
              }}
            />
          ) : (
            <StyledView 
              className="w-8 h-8 rounded-full items-center justify-center"
              style={{ backgroundColor: getNotificationColor(notification.type) + '20' }}
            >
              <Icon 
                name={getNotificationIcon(notification.type)} 
                size={16} 
                color={getNotificationColor(notification.type)} 
              />
            </StyledView>
          )}
          
          {/* Unread indicator */}
          {!notification.is_read && (
            <StyledView className="absolute -top-1 -right-1 w-3 h-3 bg-[#1FC9C3] rounded-full border border-white" />
          )}
        </StyledView>

        {/* Content */}
        <StyledView className="flex-1 ml-2">
          <StyledView className="flex-row items-center">
            <StyledView className="flex-row items-center flex-1">
              {notification.type === 'follow' ? (
                <StyledView className="flex-row items-center flex-1">
                  {parseBoldText('@'+ notification.message || `${notification.metadata?.recipientName || 'Someone'} has followed you`)}
                  <AppText className="text-xs text-gray-400 mr-4">
                    {formatTimestamp(notification.created_at)}
                  </AppText>
                </StyledView>
              ) : (
                <AppText 
                  className={`text-sm font-semibold ${
                    notification.is_read ? 'text-gray-600' : 'text-gray-900'
                  }`}
                >
                  {getNotificationMessage()}
                </AppText>
              )}
            </StyledView>
            {notification.type !== 'follow' && (
              <AppText className="text-xs text-gray-400 ">
                {formatTimestamp(notification.created_at)}
              </AppText>
            )}
          </StyledView>
        </StyledView>

        {/* Right side actions */}
        <StyledView className="ml-2 items-center">
          {notification.type === 'follow' ? (
            checkingFollow ? (
              <StyledView className="bg-gray-200 px-3 py-1.5 rounded-full">
                <AppText className="text-gray-500 font-medium text-xs">
                  Checking...
                </AppText>
              </StyledView>
            ) : isFollowing ? (
              <StyledView className="bg-white border border-[#1FC9C3] px-3 py-1.5 rounded-full">
                <AppText className="text-[#1FC9C3] font-medium text-xs">
                  Following
                </AppText>
              </StyledView>
            ) : (
              <StyledTouchableOpacity
                onPress={handleFollowBack}
                disabled={loading}
                className="bg-[#1FC9C3] px-3 py-1.5 rounded-full"
              >
                <AppText className="text-white font-medium text-xs">
                  {loading ? 'Following...' : 'Follow Back'}
                </AppText>
              </StyledTouchableOpacity>
            )
          ) : (
            !notification.is_read && (
              <StyledTouchableOpacity
                onPress={() => onMarkAsRead(notification.id)}
                className="p-1"
              >
                <Icon name="check" size={16} color={COLORS.mint} />
              </StyledTouchableOpacity>
            )
          )}
        </StyledView>
      </StyledView>
    </StyledTouchableOpacity>
  );
};

export default NotificationItem; 
