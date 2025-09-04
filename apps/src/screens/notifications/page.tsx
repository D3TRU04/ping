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
import NotificationsTopNavBar from './components/NavBar';
import NotificationItem from './components/NotificationItem';
import NotificationActions from './components/NotificationActions';
import BottomNavBar from '../../components/BottomNavBar';
import AppText from '../../components/AppText';
import { COLORS } from '../../theme/colors';
import { useNotifications } from './hooks/useNotifications';
import { Notification } from './types/Notification';
import { useUserAuth } from '../chat/hooks/useUserAuth';

const StyledView = styled(View);

export default function NotificationsScreen({ route }: { route: any }) {
  const { currentUser } = useUserAuth(route?.params?.currentUser);
  const userId = currentUser?.id;

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
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case 'follow':
        Alert.alert('View Profile', `View ${notification.metadata?.senderName || 'user'}'s profile`);
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
    <StyledView>
      <NotificationItem
        notification={item}
        onPress={handleNotificationPress}
        onMarkAsRead={markAsRead}
        onDelete={deleteNotification}
      />
      <NotificationActions
        notification={item}
        onActionComplete={handleActionComplete}
      />
    </StyledView>
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

  const renderFilterButtons = () => (
    <StyledView className="px-4 pt-2 pb-2">
      <StyledView className="flex-row items-center mb-4">
        {notificationCounts.unread > 0 && (
          <StyledView className="flex-1">
            <AppText className="text-sm text-gray-600">
              {notificationCounts.unread} unread notification{notificationCounts.unread !== 1 ? 's' : ''}
            </AppText>
          </StyledView>
        )}
        {notificationCounts.unread > 0 && (
          <StyledView className="ml-auto">
            <AppText 
              className="text-mint font-semibold"
              onPress={markAllAsRead}
            >
              Mark all read
            </AppText>
          </StyledView>
        )}
      </StyledView>

      {/* Filter Buttons */}
      <StyledView className="items-start">
        <FlatList
          data={[
            { filter: 'all' as const, label: `All (${notificationCounts.total})` },
            { filter: 'unread' as const, label: `Unread (${notificationCounts.unread})` },
            { filter: 'read' as const, label: `Read (${notificationCounts.total - notificationCounts.unread})` },
          ]}
          renderItem={({ item }) => (
            <StyledView
              className={`px-4 py-2 rounded-full mr-2 border ${
                activeFilter === item.filter
                  ? 'border-mint bg-mint'
                  : 'bg-gray-100 border-gray-200'
              }`}
            >
              <AppText
                className={`text-sm font-semibold ${
                  activeFilter === item.filter ? 'text-white' : 'text-gray-900'
                }`}
                onPress={() => setActiveFilter(item.filter)}
              >
                {item.label}
              </AppText>
            </StyledView>
          )}
          keyExtractor={(item) => item.filter}
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={{ paddingBottom: 8, justifyContent: 'flex-start' }}
        />
      </StyledView>
    </StyledView>
  );

  if (!userId) {
    return (
      <StyledView className="flex-1 bg-white justify-center items-center">
        <AppText className="text-lg text-gray-600">Please log in to view notifications</AppText>
      </StyledView>
    );
  }

  return (
    <StyledView className="flex-1 bg-white">
      <NotificationsTopNavBar currentUser={currentUser} />

      {/* Header with Filters */}
      {renderFilterButtons()}

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
          data={filteredNotifications}
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
            flexGrow: 1,
            justifyContent: 'center',
            paddingTop: 8,
            paddingBottom: 120,
          }}
        />
      )}

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
