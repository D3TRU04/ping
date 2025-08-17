import { supabase } from '../../../../lib/supabase';
import { NotificationCounts, NotificationSettings } from '../types/Notification';

// Get notification counts
export const getNotificationCounts = async (userId: string): Promise<NotificationCounts> => {
  try {
    const { data, error } = await supabase
      .from('notifications')
      .select('type, is_read')
      .eq('recipient_id', userId);

    if (error) throw error;

    const counts: NotificationCounts = {
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

    return counts;
  } catch (error) {
    return {
      total: 0,
      unread: 0,
      follow: 0,
      friendRequest: 0,
      placeVisit: 0,
      placeRecommendation: 0,
      chat: 0,
      system: 0,
      event: 0,
    };
  }
};

// Get notification settings
export const getNotificationSettings = async (userId: string): Promise<NotificationSettings | null> => {
  try {
    const { data, error } = await supabase
      .from('notification_settings')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error) throw error;
    return data;
  } catch (error) {
    return null;
  }
};

// Update notification settings
export const updateNotificationSettings = async (
  userId: string, 
  settings: Partial<NotificationSettings>
): Promise<boolean> => {
  try {
    const { error } = await supabase
      .from('notification_settings')
      .upsert({
        user_id: userId,
        ...settings,
      });

    if (error) throw error;
    return true;
  } catch (error) {
    return false;
  }
};

// Format timestamp for display
export const formatTimestamp = (timestamp: string): string => {
  const date = new Date(timestamp);
  const now = new Date();
  const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60));
  
  if (diffInMinutes < 1) return 'Just now';
  if (diffInMinutes < 60) return `${diffInMinutes}m ago`;
  if (diffInMinutes < 1440) return `${Math.floor(diffInMinutes / 60)}h ago`;
  return `${Math.floor(diffInMinutes / 1440)}d ago`;
};

// Get notification icon based on type
export const getNotificationIcon = (type: string): string => {
  switch (type) {
    case 'follow': return 'person-add';
    case 'friend_request': return 'people';
    case 'place_visit': return 'place';
    case 'place_recommendation': return 'restaurant';
    case 'chat_message': return 'chat-bubble';
    case 'event': return 'event';
    case 'system': return 'info';
    default: return 'notifications';
  }
};

// Get notification color based on type
export const getNotificationColor = (type: string): string => {
  switch (type) {
    case 'follow': return '#4CAF50';
    case 'friend_request': return '#2196F3';
    case 'place_visit': return '#FF9800';
    case 'place_recommendation': return '#1FC9C3';
    case 'chat_message': return '#9C27B0';
    case 'event': return '#FF5722';
    case 'system': return '#9E9E9E';
    default: return '#1FC9C3';
  }
}; 