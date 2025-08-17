export interface Notification {
  id: string;
  type: 'follow' | 'friend_request' | 'place_visit' | 'place_recommendation' | 'chat_message' | 'system' | 'event';
  title: string;
  message: string;
  timestamp: string;
  isRead: boolean;
  avatar?: string;
  actionData?: {
    userId?: string;
    placeId?: string;
    chatId?: string;
    eventId?: string;
  };
  metadata?: {
    senderId?: string;
    senderName?: string;
    senderAvatar?: string;
    placeName?: string;
    placeImage?: string;
    placeAddress?: string;
    visitDate?: string;
  };
}

export interface FollowNotification extends Notification {
  type: 'follow';
  actionData: {
    userId: string;
  };
  metadata: {
    senderId: string;
    senderName: string;
    senderAvatar?: string;
  };
}

export interface FriendRequestNotification extends Notification {
  type: 'friend_request';
  actionData: {
    userId: string;
  };
  metadata: {
    senderId: string;
    senderName: string;
    senderAvatar?: string;
  };
}

export interface PlaceVisitNotification extends Notification {
  type: 'place_visit';
  actionData: {
    userId: string;
    placeId: string;
  };
  metadata: {
    senderId: string;
    senderName: string;
    senderAvatar?: string;
    placeName: string;
    placeImage?: string;
    placeAddress?: string;
    visitDate: string;
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