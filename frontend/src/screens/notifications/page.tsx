import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  RefreshControl,
  Alert,
  Image,
} from 'react-native';
import { styled } from 'nativewind';
import TopNavBar from '../../components/navbar/Notifications';
import BottomNavBar from '../../components/navbar/BottomNavBar';
import AppText from '../../components/AppText';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { COLORS } from '../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);

interface Notification {
  id: string;
  type: 'friend_request' | 'place_recommendation' | 'chat_message' | 'system' | 'event';
  title: string;
  message: string;
  timestamp: string;
  isRead: boolean;
  avatar?: string;
  actionData?: any;
}

export default function NotificationsScreen({ route }: { route: any }) {
  const currentUser = route?.params?.currentUser;
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [filteredNotifications, setFilteredNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [activeFilter, setActiveFilter] = useState<'all' | 'unread' | 'read'>('all');

  useEffect(() => {
    fetchNotifications();
  }, []);

  useEffect(() => {
    filterNotifications();
  }, [activeFilter, notifications]);

  const fetchNotifications = async (isRefresh = false) => {
    if (isRefresh) {
      setRefreshing(true);
    } else {
      setLoading(true);
    }

    try {
      // Mock data for now - replace with actual Supabase query
      const mockNotifications: Notification[] = [
        {
          id: '1',
          type: 'friend_request',
          title: 'New Friend Request',
          message: 'Sarah Johnson wants to connect with you',
          timestamp: '2 minutes ago',
          isRead: false,
          avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        },
        {
          id: '2',
          type: 'place_recommendation',
          title: 'Place Recommendation',
          message: 'Based on your preferences, you might like "Sakura Sushi"',
          timestamp: '15 minutes ago',
          isRead: false,
          avatar: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=150&h=150&fit=crop',
        },
        {
          id: '3',
          type: 'chat_message',
          title: 'New Message',
          message: 'Alex Chen sent you a message about dinner plans',
          timestamp: '1 hour ago',
          isRead: true,
          avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        },
        {
          id: '4',
          type: 'event',
          title: 'Event Reminder',
          message: 'Foodie Meetup starts in 30 minutes at Central Park',
          timestamp: '2 hours ago',
          isRead: true,
        },
        {
          id: '5',
          type: 'system',
          title: 'Welcome to Ping!',
          message: 'Your account has been successfully created. Start discovering amazing places!',
          timestamp: '1 day ago',
          isRead: true,
        },
        {
          id: '6',
          type: 'place_recommendation',
          title: 'Trending Place',
          message: '"The Coffee Corner" is trending in your area',
          timestamp: '2 days ago',
          isRead: true,
          avatar: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=150&h=150&fit=crop',
        },
      ];

      // Simulate API delay
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      setNotifications(mockNotifications);
    } catch (error) {
      console.error('Error fetching notifications:', error);
      Alert.alert('Error', 'Failed to load notifications. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const filterNotifications = () => {
    let filtered = [...notifications];
    
    if (activeFilter === 'unread') {
      filtered = filtered.filter(notification => !notification.isRead);
    } else if (activeFilter === 'read') {
      filtered = filtered.filter(notification => notification.isRead);
    }
    
    setFilteredNotifications(filtered);
  };

  const onRefresh = () => {
    fetchNotifications(true);
  };

  const markAsRead = (notificationId: string) => {
    setNotifications(prev => 
      prev.map(notification => 
        notification.id === notificationId 
          ? { ...notification, isRead: true }
          : notification
      )
    );
  };

  const markAllAsRead = () => {
    setNotifications(prev => 
      prev.map(notification => ({ ...notification, isRead: true }))
    );
  };

  const handleNotificationPress = (notification: Notification) => {
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    switch (notification.type) {
      case 'friend_request':
        Alert.alert(
          'Friend Request',
          `Accept ${notification.title}?`,
          [
            { text: 'Decline', style: 'destructive' },
            { text: 'Accept', onPress: () => console.log('Accept friend request') }
          ]
        );
        break;
      case 'place_recommendation':
        Alert.alert(
          'Place Recommendation',
          'View this place?',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'View', onPress: () => console.log('View place') }
          ]
        );
        break;
      case 'chat_message':
        Alert.alert(
          'New Message',
          'Open chat?',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Open', onPress: () => console.log('Open chat') }
          ]
        );
        break;
      default:
        console.log('Notification pressed:', notification.title);
    }
  };

  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'friend_request':
        return 'person-add';
      case 'place_recommendation':
        return 'restaurant';
      case 'chat_message':
        return 'chat-bubble';
      case 'event':
        return 'event';
      case 'system':
        return 'info';
      default:
        return 'notifications';
    }
  };

  const getNotificationColor = (type: string) => {
    switch (type) {
      case 'friend_request':
        return '#4CAF50';
      case 'place_recommendation':
        return COLORS.mint;
      case 'chat_message':
        return '#2196F3';
      case 'event':
        return '#FF9800';
      case 'system':
        return '#9E9E9E';
      default:
        return COLORS.mint;
    }
  };

  const renderNotificationItem = ({ item }: { item: Notification }) => (
    <StyledTouchableOpacity
      onPress={() => handleNotificationPress(item)}
      className={`mx-4 mb-2 rounded-2xl overflow-hidden ${
        item.isRead ? 'bg-white' : 'bg-blue-50'
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
          {item.avatar ? (
            <StyledImage
              source={{ uri: item.avatar }}
              className="w-12 h-12 rounded-full"
            />
          ) : (
            <StyledView 
              className="w-12 h-12 rounded-full items-center justify-center"
              style={{ backgroundColor: getNotificationColor(item.type) + '20' }}
            >
              <Icon 
                name={getNotificationIcon(item.type)} 
                size={24} 
                color={getNotificationColor(item.type)} 
              />
            </StyledView>
          )}
          
          {/* Unread indicator */}
          {!item.isRead && (
            <StyledView className="absolute -top-1 -right-1 w-4 h-4 bg-mint rounded-full border-2 border-white" />
          )}
        </StyledView>

        {/* Content */}
        <StyledView className="flex-1 ml-4">
          <StyledView className="flex-row justify-between items-start mb-1">
            <AppText 
              className={`text-base flex-1 ${
                item.isRead ? 'text-gray-900' : 'text-gray-900'
              }`}
            >
              {item.title}
            </AppText>
            <AppText className="text-sm text-gray-500 ml-2">
              {item.timestamp}
            </AppText>
          </StyledView>

          <AppText 
            className={`text-sm leading-5 ${
              item.isRead ? 'text-gray-600' : 'text-gray-700'
            }`}
            numberOfLines={2}
          >
            {item.message}
          </AppText>
        </StyledView>
      </StyledView>
    </StyledTouchableOpacity>
  );

  const renderFilterButton = (filter: 'all' | 'unread' | 'read', label: string) => (
    <StyledTouchableOpacity
      onPress={() => setActiveFilter(filter)}
      className={`px-4 py-2 rounded-full mr-2 border ${
        activeFilter === filter
          ? 'border-mint'
          : 'bg-gray-100 border-gray-200'
      }`}
      style={activeFilter === filter ? { backgroundColor: COLORS.mint } : {}}
    >
      <AppText
        className={`text-sm font-semibold ${
          activeFilter === filter ? 'text-white' : 'text-gray-900'
        }`}
      >
        {label}
      </AppText>
    </StyledTouchableOpacity>
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

  const unreadCount = notifications.filter(n => !n.isRead).length;

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar currentUser={currentUser} />

      {/* Header with Filters */}
      <StyledView className="px-4 pt-4 pb-2">
        <StyledView className="flex-row items-center mb-4">
          {/* Removed Notifications heading */}
          {unreadCount > 0 && (
            <StyledTouchableOpacity onPress={markAllAsRead}>
              <AppText className="text-mint">Mark all read</AppText>
            </StyledTouchableOpacity>
          )}
        </StyledView>

        {/* Filter Buttons */}
        <StyledView className="items-start">
          <FlatList
            data={[
              { filter: 'all' as const, label: 'All' },
              { filter: 'unread' as const, label: `Unread (${unreadCount})` },
              { filter: 'read' as const, label: 'Read' },
            ]}
            renderItem={({ item }) => renderFilterButton(item.filter, item.label)}
            keyExtractor={(item) => item.filter}
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ paddingBottom: 8, justifyContent: 'flex-start' }}
          />
        </StyledView>
      </StyledView>

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
            paddingTop: 8,
            paddingBottom: 120,
          }}
        />
      )}

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
