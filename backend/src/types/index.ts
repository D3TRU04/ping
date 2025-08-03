export interface Chat {
  id: string;
  name: string;
  avatar: string | null;
  lastMessage: string;
  lastMessageTime: string;
  unreadCount: number;
  isOnline: boolean;
  isGroup: boolean;
}

export interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

export interface Message {
  id: string;
  sender_id: string;
  receiver_id: string;
  conversation_id: string;
  group_chat_id?: string;
  message: { text: string };
  created_at: string;
  is_read: boolean;
}

export interface GroupChat {
  id: string;
  name: string;
  created_by: string;
  created_at: string;
  members?: User[];
}

export interface ChatItem {
  type: 'message' | 'date';
  data: Message | string;
}

// Discover types
export interface Place {
  place_id: string;
  name: string;
  image_url?: string;
  description?: string;
  type_of_food?: string;
  subtopic?: string;
  rating?: number;
  price_range?: number;
  hours: string[];
  address?: string;
  lat?: number;
  lng?: number;
  latitude?: number;
  longitude?: number;
}

export interface FilterOption {
  id: string;
  name: string;
  value: string;
  selected: boolean;
}

export interface DiscoverFilters {
  searchQuery?: string;
  selectedFilters?: string[];
  category?: string;
} 