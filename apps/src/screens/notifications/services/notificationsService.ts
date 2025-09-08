import { supabase } from '../../../../lib/supabase';
import { Notification, NotificationCounts, NotificationSettings } from '../types/Notification';

export class NotificationsService {
  private static instance: NotificationsService;
  private realtimeSubscription: any = null;

  static getInstance(): NotificationsService {
    if (!NotificationsService.instance) {
      NotificationsService.instance = new NotificationsService();
    }
    return NotificationsService.instance;
  }

  // Fetch all notifications for a user with pre-loaded follow statuses
  async fetchNotifications(userId: string): Promise<Notification[]> {
    try {
      const { data, error } = await supabase
        .from('notifications')
        .select('*')
        .eq('recipient_id', userId)
        .order('created_at', { ascending: false });

      if (error) {
        throw error;
      }

      const notifications = data || [];
      
      // Pre-load follow statuses for follow notifications
      const followNotifications = notifications.filter(n => n.type === 'follow' && n.sender_id);
      if (followNotifications.length > 0) {
        const followStatuses = await this.getFollowStatuses(userId, followNotifications);
        
        // Add follow status to each follow notification
        return notifications.map(notification => {
          if (notification.type === 'follow' && notification.sender_id) {
            const followStatus = followStatuses[notification.sender_id];
            return {
              ...notification,
              metadata: {
                ...notification.metadata,
                isFollowing: followStatus || false
              }
            };
          }
          return notification;
        });
      }

      return notifications;
    } catch (error) {
      return [];
    }
  }

  // Fetch notifications by type
  async fetchNotificationsByType(userId: string, type: string): Promise<Notification[]> {
    try {
      const { data, error } = await supabase
        .from('notifications')
        .select('*')
        .eq('recipient_id', userId)
        .eq('type', type)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error(`Error fetching ${type} notifications:`, error);
      return [];
    }
  }

  // Mark notification as read
  async markAsRead(notificationId: string): Promise<boolean> {
    try {
      const { error } = await supabase
        .from('notifications')
        .update({ is_read: true })
        .eq('id', notificationId);

      if (error) throw error;
      return true;
    } catch (error) {
      console.error('Error marking notification as read:', error);
      return false;
    }
  }

  // Mark all notifications as read
  async markAllAsRead(userId: string): Promise<boolean> {
    try {
      const { error } = await supabase
        .from('notifications')
        .update({ is_read: true })
        .eq('recipient_id', userId)
        .eq('is_read', false);

      if (error) throw error;
      return true;
    } catch (error) {
      console.error('Error marking all notifications as read:', error);
      return false;
    }
  }

  // Delete notification
  async deleteNotification(notificationId: string): Promise<boolean> {
    try {
      const { error } = await supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId);

      if (error) throw error;
      return true;
    } catch (error) {
      console.error('Error deleting notification:', error);
      return false;
    }
  }

  // Subscribe to real-time notifications
  subscribeToNotifications(userId: string, callback: (notification: Notification) => void): void {
    if (this.realtimeSubscription) {
      this.realtimeSubscription.unsubscribe();
    }

    this.realtimeSubscription = supabase
      .channel('notifications')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'notifications',
          filter: `recipient_id=eq.${userId}`,
        },
        (payload) => {
          callback(payload.new as Notification);
        }
      )
      .subscribe();
  }

  // Unsubscribe from real-time notifications
  unsubscribeFromNotifications(): void {
    if (this.realtimeSubscription) {
      this.realtimeSubscription.unsubscribe();
      this.realtimeSubscription = null;
    }
  }

  // Background loading method - loads notifications without UI state management
  async loadNotificationsInBackground(userId: string): Promise<{
    notifications: Notification[];
    counts: NotificationCounts;
  }> {
    try {
      const [notifications, counts] = await Promise.all([
        this.fetchNotifications(userId),
        this.getNotificationCounts(userId)
      ]);

      return { notifications, counts };
    } catch (error) {
      console.error('Error loading notifications in background:', error);
      return { 
        notifications: [], 
        counts: { 
          total: 0, 
          unread: 0, 
          follow: 0, 
          friendRequest: 0, 
          placeVisit: 0, 
          placeRecommendation: 0, 
          chat: 0, 
          system: 0, 
          event: 0 
        } 
      };
    }
  }

  // Get follow statuses for multiple users efficiently
  private async getFollowStatuses(userId: string, followNotifications: Notification[]): Promise<Record<string, boolean>> {
    try {
      const senderIds = followNotifications.map(n => n.sender_id).filter(Boolean);
      if (senderIds.length === 0) return {};

      const { data, error } = await supabase
        .from('follows')
        .select('following_id')
        .eq('follower_id', userId)
        .in('following_id', senderIds);

      if (error) {
        console.error('Error fetching follow statuses:', error);
        return {};
      }

      // Create a map of sender_id -> isFollowing
      const followStatusMap: Record<string, boolean> = {};
      senderIds.forEach(senderId => {
        followStatusMap[senderId] = data?.some(follow => follow.following_id === senderId) || false;
      });

      return followStatusMap;
    } catch (error) {
      console.error('Error getting follow statuses:', error);
      return {};
    }
  }

  // Get notification counts (moved from notificationUtils for consistency)
  async getNotificationCounts(userId: string): Promise<NotificationCounts> {
    try {
      const { data, error } = await supabase
        .from('notifications')
        .select('type, is_read')
        .eq('recipient_id', userId);

      if (error) throw error;

      return {
        total: data?.length || 0,
        unread: data?.filter(n => !n.is_read).length || 0,
        follow: data?.filter(n => n.type === 'follow' && !n.is_read).length || 0,
        friendRequest: data?.filter(n => n.type === 'friend_request' && !n.is_read).length || 0,
        placeVisit: data?.filter(n => n.type === 'place_visit' && !n.is_read).length || 0,
        placeRecommendation: data?.filter(n => n.type === 'place_recommendation' && !n.is_read).length || 0,
        chat: data?.filter(n => n.type === 'chat_message' && !n.is_read).length || 0,
        system: data?.filter(n => n.type === 'system' && !n.is_read).length || 0,
        event: data?.filter(n => n.type === 'event' && !n.is_read).length || 0,
      };
    } catch (error) {
      console.error('Error getting notification counts:', error);
      return { 
        total: 0, 
        unread: 0, 
        follow: 0, 
        friendRequest: 0, 
        placeVisit: 0, 
        placeRecommendation: 0, 
        chat: 0, 
        system: 0, 
        event: 0 
      };
    }
  }
}

// Create and export a single instance
const notificationsService = NotificationsService.getInstance();
export default notificationsService; 