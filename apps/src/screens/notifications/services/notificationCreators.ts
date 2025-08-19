import { supabase } from '../../../../lib/supabase';

// Create a follow notification
export const createFollowNotification = async (followerId: string, followedId: string): Promise<boolean> => {
  try {
    // Get follower details
    const { data: followerData, error: followerError } = await supabase
      .from('profiles')
      .select('name, avatar_url')
      .eq('id', followerId)
      .single();

    if (followerError) throw followerError;

    const notification = {
      recipient_id: followedId,
      sender_id: followerId,
      type: 'follow',
      title: 'New Follower',
      message: `${followerData.name} started following you`,
      is_read: false,
      metadata: {
        senderId: followerId,
        senderName: followerData.name,
        senderAvatar: followerData.avatar_url,
      },
    };

    const { error } = await supabase
      .from('notifications')
      .insert(notification);

    if (error) throw error;
    return true;
  } catch (error) {
    console.error('Error creating follow notification:', error);
    return false;
  }
};

// Create a friend request notification
export const createFriendRequestNotification = async (requesterId: string, recipientId: string): Promise<boolean> => {
  try {
    // Get requester details
    const { data: requesterData, error: requesterError } = await supabase
      .from('profiles')
      .select('name, avatar_url')
      .eq('id', requesterId)
      .single();

    if (requesterError) throw requesterError;

    const notification = {
      recipient_id: recipientId,
      sender_id: requesterId,
      type: 'friend_request',
      title: 'New Friend Request',
      message: `${requesterData.name} sent you a friend request`,
      is_read: false,
      metadata: {
        senderId: requesterId,
        senderName: requesterData.name,
        senderAvatar: requesterData.avatar_url,
      },
    };

    const { error } = await supabase
      .from('notifications')
      .insert(notification);

    if (error) throw error;
    return true;
  } catch (error) {
    console.error('Error creating friend request notification:', error);
    return false;
  }
};

// Create a place visit notification
export const createPlaceVisitNotification = async (
  visitorId: string, 
  placeId: string, 
  placeName: string, 
  placeImage?: string, 
  placeAddress?: string
): Promise<boolean> => {
  try {
    // Get visitor details
    const { data: visitorData, error: visitorError } = await supabase
      .from('profiles')
      .select('name, avatar_url')
      .eq('id', visitorId)
      .single();

    if (visitorError) throw visitorError;

    // Get friends of the visitor
    const { data: friendsData, error: friendsError } = await supabase
      .from('friendships')
      .select('friend_id')
      .eq('user_id', visitorId)
      .eq('status', 'accepted');

    if (friendsError) throw friendsError;

    if (!friendsData || friendsData.length === 0) return true;

    // Create notifications for all friends
    const notifications = friendsData.map(friendship => ({
      recipient_id: friendship.friend_id,
      sender_id: visitorId,
      type: 'place_visit',
      title: 'Friend Activity',
      message: `${visitorData.name} recently visited ${placeName}`,
      is_read: false,
      metadata: {
        senderId: visitorId,
        senderName: visitorData.name,
        senderAvatar: visitorData.avatar_url,
        placeName,
        placeImage,
        placeAddress,
        visitDate: new Date().toISOString(),
      },
      action_data: {
        userId: visitorId,
        placeId,
      },
    }));

    const { error } = await supabase
      .from('notifications')
      .insert(notifications);

    if (error) throw error;
    return true;
  } catch (error) {
    console.error('Error creating place visit notification:', error);
    return false;
  }
}; 