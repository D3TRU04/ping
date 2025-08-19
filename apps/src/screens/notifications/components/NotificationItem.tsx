import React from 'react';
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

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

interface NotificationItemProps {
  notification: Notification;
  onPress: (notification: Notification) => void;
  onMarkAsRead: (notificationId: string) => void;
  onDelete: (notificationId: string) => void;
}

const NotificationItem: React.FC<NotificationItemProps> = ({
  notification,
  onPress,
  onMarkAsRead,
  onDelete,
}) => {
  const getNotificationTitle = (type: string) => {
    switch (type) {
      case 'follow': return 'New Follower';
      case 'friend_request': return 'Friend Request';
      case 'place_visit': return 'Friend Activity';
      case 'place_recommendation': return 'Place Recommendation';
      case 'chat_message': return 'New Message';
      case 'event': return 'Event Update';
      case 'system': return 'System Update';
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

  const getMessage = () => {
    if (notification.message) return notification.message;
    
    switch (notification.type) {
      case 'follow':
        return `${notification.metadata?.senderName || 'Someone'} started following you`;
      case 'friend_request':
        return `${notification.metadata?.senderName || 'Someone'} sent you a friend request`;
      case 'place_visit':
        return `${notification.metadata?.senderName || 'A friend'} recently visited ${notification.metadata?.placeName || 'a place'}`;
      default:
        return notification.message || 'You have a new notification';
    }
  };

  return (
    <StyledTouchableOpacity
      onPress={() => onPress(notification)}
      onLongPress={handleLongPress}
      className={`mx-4 mb-2 rounded-2xl overflow-hidden ${
        notification.isRead ? 'bg-white' : 'bg-blue-50'
      }`}
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 2,
      }}
    >
      <StyledView className="flex-row items-start p-4">
        {/* Avatar/Icon */}
        <StyledView className="relative">
          {getAvatarSource() ? (
            <StyledImage
              source={getAvatarSource()}
              className="w-12 h-12 rounded-full"
              onError={() => {
                // Handle image loading failure silently
              }}
            />
          ) : (
            <StyledView 
              className="w-12 h-12 rounded-full items-center justify-center"
              style={{ backgroundColor: getNotificationColor(notification.type) + '20' }}
            >
              <Icon 
                name={getNotificationIcon(notification.type)} 
                size={24} 
                color={getNotificationColor(notification.type)} 
              />
            </StyledView>
          )}
          
          {/* Unread indicator */}
          {!notification.isRead && (
            <StyledView className="absolute -top-1 -right-1 w-4 h-4 bg-mint rounded-full border-2 border-white" />
          )}
        </StyledView>

        {/* Content */}
        <StyledView className="flex-1 ml-4">
          <StyledView className="flex-row justify-between items-start mb-1">
            <AppText 
              className={`text-base font-semibold flex-1 ${
                notification.isRead ? 'text-gray-900' : 'text-gray-900'
              }`}
            >
              {getNotificationTitle(notification.type)}
            </AppText>
            <AppText className="text-sm text-gray-500 ml-2">
              {formatTimestamp(notification.timestamp)}
            </AppText>
          </StyledView>

          <AppText 
            className={`text-sm leading-5 ${
              notification.isRead ? 'text-gray-600' : 'text-gray-700'
            }`}
            numberOfLines={2}
          >
            {getMessage()}
          </AppText>

          {/* Additional metadata for place visits */}
          {notification.type === 'place_visit' && notification.metadata?.placeAddress && (
            <StyledView className="mt-2 flex-row items-center">
              <Icon name="location-on" size={16} color="#666" />
              <AppText className="text-xs text-gray-500 ml-1" numberOfLines={1}>
                {notification.metadata.placeAddress}
              </AppText>
            </StyledView>
          )}
        </StyledView>

        {/* Action buttons */}
        <StyledView className="ml-2">
          {!notification.isRead && (
            <StyledTouchableOpacity
              onPress={() => onMarkAsRead(notification.id)}
              className="p-2"
            >
              <Icon name="check" size={20} color={COLORS.mint} />
            </StyledTouchableOpacity>
          )}
        </StyledView>
      </StyledView>
    </StyledTouchableOpacity>
  );
};

export default NotificationItem; 