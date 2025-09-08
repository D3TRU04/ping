import React, { useEffect } from 'react';
import {
  View,
  FlatList,
  ActivityIndicator,
  RefreshControl,
  Alert,
} from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import NotificationsTopNavBar from './components/NavBar';
import NotificationItem from './components/NotificationItem';
import BottomNavBar from '../../components/BottomNavBar';
import AppText from '../../components/AppText';
import { COLORS } from '../../theme/colors';
import { useNotifications } from './hooks/useNotifications';
import { Notification } from './types/Notification';

const StyledView = styled(View);

type RootStackParamList = {
  publicProfileScreen: { userId: string; currentUser?: any; fromScreen?: string };
  [key: string]: any;
};

type NotificationsScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Notifications'>;

export default function NotificationsScreen({ route }: { route: any }) {
  const currentUser = route?.params?.currentUser;
  const userId = currentUser?.id;
  const navigation = useNavigation<NotificationsScreenNavigationProp>();

  const {
    notifications,
    filteredNotifications,
    loading,
    refreshing,
    notificationCounts,
    activeFilter,
    error,
    setActiveFilter,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    onRefresh,
    refetch,
    setLoading,
  } = useNotifications(userId || '');

  useEffect(() => {
    if (error) {
      Alert.alert('Error', error);
    }
  }, [error]);

  // Safeguard: Reset loading if it gets stuck for too long
  useEffect(() => {
    if (loading && userId) {
      const timeoutId = setTimeout(() => {
        if (loading) {
          setLoading(false);
        }
      }, 15000); // 15 second safeguard
      
      return () => clearTimeout(timeoutId);
    }
  }, [loading, userId, setLoading]);

  const handleNotificationPress = (notification: Notification) => {
    // Mark as read if unread
    if (!notification.is_read) {
      markAsRead(notification.id);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case 'follow':
        if (notification.sender_id) {
          navigation.navigate('publicProfileScreen', { 
            userId: notification.sender_id,
            currentUser: currentUser,
            fromScreen: 'Notifications'
          });
        }
        break;
      case 'place_visit':
        Alert.alert('View Place', `View ${notification.metadata?.placeName || 'place'} details`);
        break;
      case 'place_recommendation':
        Alert.alert('View Place', `View ${notification.metadata?.placeName || 'place'} details`);
        break;
      case 'chat_message':
        Alert.alert('Open Chat', 'Navigate to chat conversation');
        break;
      default:
        // Handle other notification types
        break;
    }
  };

  const handleActionComplete = () => {
    // Refresh notifications after action completion
    refetch();
  };

  const renderNotificationItem = ({ item }: { item: Notification }) => (
    <NotificationItem
      notification={item}
      onPress={handleNotificationPress}
      onMarkAsRead={markAsRead}
      onDelete={deleteNotification}
      onActionComplete={handleActionComplete}
    />
  );

  const renderEmptyState = () => (
    <StyledView className="flex-1 justify-center items-center px-8">
      <Icon name="notifications-none" size={80} color={COLORS.mint} />
      <AppText className="text-xl text-gray-900 mt-4 text-center">
        No notifications
      </AppText>
      <AppText className="text-gray-600 text-center mt-2 leading-6">
        You're all caught up! New notifications will appear here.
      </AppText>
    </StyledView>
  );

  const renderHeader = () => (
    <StyledView className="px-4 -pt-2 ">
      <StyledView className="flex-row items-center justify-between">
        {/* <AppText className="text-lg font-semibold text-gray-900">
          Notifications
        </AppText> */}
        {notificationCounts.unread > 0 && (
          <AppText 
            className="text-[#1FC9C3] font-semibold text-sm"
            onPress={markAllAsRead}
          >
            Mark all read
          </AppText>
        )}
      </StyledView>
    </StyledView>
  );

  // if (!userId) {
  //   return (
  //     <StyledView className="flex-1 bg-white justify-center items-center">
  //       <AppText className="text-lg text-gray-600">Please log in to view notifications</AppText>
  //     </StyledView>
  //   );
  // }

  return (
    <StyledView className="flex-1 bg-white">
      <NotificationsTopNavBar currentUser={currentUser} />

      {/* Header */}
      {renderHeader()}

      {/* Notifications List */}
      {loading ? (
        <StyledView className="flex-1 justify-center items-center">
          <ActivityIndicator size="large" color={COLORS.mint} />
          <AppText className="text-mint mt-4 text-lg">
            Loading notifications...
          </AppText>
        </StyledView>
      ) : (
        <FlatList
          data={notifications}
          renderItem={renderNotificationItem}
          keyExtractor={(item) => item.id}
          showsVerticalScrollIndicator={false}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              tintColor={COLORS.mint}
              colors={[COLORS.mint]}
            />
          }
          ListEmptyComponent={renderEmptyState}
          contentContainerStyle={{ 
            paddingTop: 0,
            paddingBottom: 120,
          }}
        />
      )}

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
