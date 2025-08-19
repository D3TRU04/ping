import { useState, useEffect, useCallback, useRef } from 'react';
import { Notification, NotificationCounts } from '../types/Notification';
import notificationsService from '../services/notificationsService';
import { getNotificationCounts } from '../services/notificationUtils';

export const useNotifications = (userId: string) => {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [filteredNotifications, setFilteredNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [notificationCounts, setNotificationCounts] = useState<NotificationCounts>({
    total: 0,
    unread: 0,
    follow: 0,
    friendRequest: 0,
    placeVisit: 0,
    placeRecommendation: 0,
    chat: 0,
    system: 0,
    event: 0,
  });
  const [activeFilter, setActiveFilter] = useState<'all' | 'unread' | 'read'>('all');
  const [error, setError] = useState<string | null>(null);

  const isMounted = useRef(true);

  useEffect(() => {
    return () => {
      isMounted.current = false;
      notificationsService.unsubscribeFromNotifications();
      // Reset loading states on cleanup
      setLoading(false);
      setRefreshing(false);
    };
  }, []);

  // Fetch notifications - use useCallback with stable dependencies
  const fetchNotifications = useCallback(async (isRefresh = false) => {
    if (!userId) {
      setLoading(false);
      return;
    }

    try {
      setError(null);
      if (isRefresh) {
        setRefreshing(true);
      } else {
        setLoading(true);
      }

      const [notificationsData, countsData] = await Promise.all([
        notificationsService.fetchNotifications(userId),
        getNotificationCounts(userId),
      ]);

      if (isMounted.current) {
        setNotifications(notificationsData);
        setNotificationCounts(countsData);
      }
    } catch (err) {
      if (isMounted.current) {
        setError('Failed to fetch notifications');
      }
    } finally {
      if (isMounted.current) {
        setLoading(false);
        setRefreshing(false);
      }
    }
  }, [userId]);

  // Filter notifications based on active filter
  const filterNotifications = useCallback(() => {
    let filtered = [...notifications];
    
    if (activeFilter === 'unread') {
      filtered = filtered.filter(notification => !notification.isRead);
    } else if (activeFilter === 'read') {
      filtered = filtered.filter(notification => notification.isRead);
    }
    
    setFilteredNotifications(filtered);
  }, [activeFilter, notifications]);

  // Mark notification as read
  const markAsRead = useCallback(async (notificationId: string) => {
    try {
      const success = await notificationsService.markAsRead(notificationId);
      if (success && isMounted.current) {
        setNotifications(prev => 
          prev.map(notification => 
            notification.id === notificationId 
              ? { ...notification, isRead: true }
              : notification
          )
        );
        
        // Update counts
        const newCounts = await getNotificationCounts(userId);
        if (isMounted.current) {
          setNotificationCounts(newCounts);
        }
      }
    } catch (err) {
      // Silent error handling
    }
  }, [userId]);

  // Mark all notifications as read
  const markAllAsRead = useCallback(async () => {
    try {
      const success = await notificationsService.markAllAsRead(userId);
      if (success && isMounted.current) {
        setNotifications(prev => 
          prev.map(notification => ({ ...notification, isRead: true }))
        );
        
        // Update counts
        const newCounts = await getNotificationCounts(userId);
        if (isMounted.current) {
          setNotificationCounts(newCounts);
        }
      }
    } catch (err) {
      // Silent error handling
    }
  }, [userId]);

  // Delete notification
  const deleteNotification = useCallback(async (notificationId: string) => {
    try {
      const success = await notificationsService.deleteNotification(notificationId);
      if (success && isMounted.current) {
        setNotifications(prev => prev.filter(n => n.id !== notificationId));
        
        // Update counts
        const newCounts = await getNotificationCounts(userId);
        if (isMounted.current) {
          setNotificationCounts(newCounts);
        }
      }
    } catch (err) {
      // Silent error handling
    }
  }, [userId]);

  // Handle refresh
  const onRefresh = useCallback(() => {
    fetchNotifications(true);
  }, [fetchNotifications]);

  // Subscribe to real-time notifications
  useEffect(() => {
    if (!userId) return;

    notificationsService.subscribeToNotifications(userId, (newNotification) => {
      if (isMounted.current) {
        setNotifications(prev => [newNotification, ...prev]);
        
        // Update counts
        getNotificationCounts(userId).then(counts => {
          if (isMounted.current) {
            setNotificationCounts(counts);
          }
        });
      }
    });

    return () => {
      notificationsService.unsubscribeFromNotifications();
    };
  }, [userId]);

  // Apply filters when notifications or filter changes
  useEffect(() => {
    filterNotifications();
  }, [filterNotifications]);

  // Reset loading state when userId changes
  useEffect(() => {
    if (userId) {
      setLoading(false);
      setRefreshing(false);
      setError(null);
    }
  }, [userId]);

  // Initial fetch - only when userId changes, and reset loading state
  useEffect(() => {
    if (userId) {
      setLoading(true);
      fetchNotifications();
    } else {
      setLoading(false);
    }
  }, [userId]);

  return {
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
    refetch: () => fetchNotifications(),
    setLoading,
  };
}; 