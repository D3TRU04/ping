export interface Notification {
  id: string;
  recipient_id: string;
  sender_id: string;
  type: 'follow' | 'place_visit' | 'place_recommendation' | 'chat_message' | 'system' | 'event';
  title: string;
  message: string;
  is_read: boolean;
  created_at: string;
  metadata?: any;
  action_data?: any;
}

export interface FollowNotification extends Notification {
  type: 'follow';
  metadata: {
    senderId: string;
    senderName: string;
    senderAvatar?: string;
  };
}

export interface PlaceVisitNotification extends Notification {
  type: 'place_visit';
  metadata: {
    senderId: string;
    senderName: string;
    senderAvatar?: string;
    placeName: string;
    placeImage?: string;
    placeAddress?: string;
    visitDate: string;
  };
  action_data: {
    userId: string;
    placeId: string;
  };
}

export interface PlaceRecommendationNotification extends Notification {
  type: 'place_recommendation';
  metadata: {
    senderId: string;
    senderName: string;
    senderAvatar?: string;
    placeName: string;
    placeImage?: string;
    placeAddress?: string;
  };
}

export interface ChatMessageNotification extends Notification {
  type: 'chat_message';
  metadata: {
    senderId: string;
    senderName: string;
    senderAvatar?: string;
    conversationId: string;
    messagePreview: string;
  };
}

export interface SystemNotification extends Notification {
  type: 'system';
  metadata: {
    actionType?: string;
    actionData?: any;
  };
}

export interface NotificationSettings {
  userId: string;
  followNotifications: boolean;
  friendRequestNotifications: boolean;
  placeVisitNotifications: boolean;
  placeRecommendationNotifications: boolean;
  chatNotifications: boolean;
  systemNotifications: boolean;
  eventNotifications: boolean;
  pushNotifications: boolean;
  emailNotifications: boolean;
}

export interface NotificationCounts {
  total: number;
  unread: number;
  follow: number;
  friendRequest: number;
  placeVisit: number;
  placeRecommendation: number;
  chat: number;
  system: number;
  event: number;
} 