import { supabase } from '../../../../lib/supabase';

// Create a follow notification
export const createFollowNotification = async (followerId: string, followingId: string): Promise<boolean> => {
  try {
    // Get follower details
    const { data: followerData, error: followerError } = await supabase
      .from('profiles')
      .select('full_name, profile_picture')
      .eq('id', followerId)
      .single();

    if (followerError) throw followerError;

    const notification = {
      recipient_id: followingId,
      sender_id: followerId,
      type: 'follow',
      title: 'New Follower',
      message: `${followerData.full_name || 'Someone'} started following you`,
      is_read: false,
      metadata: {
        senderId: followerId,
        senderName: followerData.full_name || 'Unknown User',
        senderAvatar: followerData.profile_picture,
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

// Create a place visit notification (simplified - no friends needed)
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
      .select('full_name, profile_picture')
      .eq('id', visitorId)
      .single();

    if (visitorError) throw visitorError;

    // For now, just log the place visit since we can't notify friends
    // In the future, you could implement a different notification system
    console.log(`${visitorData.full_name || 'User'} visited ${placeName}`);
    
    return true;
  } catch (error) {
    console.error('Error creating place visit notification:', error);
    return false;
  }
};

// Create a place recommendation notification
export const createPlaceRecommendationNotification = async (
  recommenderId: string,
  recipientId: string,
  placeName: string,
  placeImage?: string,
  placeAddress?: string
): Promise<boolean> => {
  try {
    // Get recommender details
    const { data: recommenderData, error: recommenderError } = await supabase
      .from('profiles')
      .select('full_name, profile_picture')
      .eq('id', recommenderId)
      .single();

    if (recommenderError) throw recommenderError;

    const notification = {
      recipient_id: recipientId,
      sender_id: recommenderId,
      type: 'place_recommendation',
      title: 'Place Recommendation',
      message: `${recommenderData.full_name || 'Someone'} recommended ${placeName} to you`,
      is_read: false,
      metadata: {
        senderId: recommenderId,
        senderName: recommenderData.full_name || 'Unknown User',
        senderAvatar: recommenderData.profile_picture,
        placeName,
        placeImage,
        placeAddress,
      },
    };

    const { error } = await supabase
      .from('notifications')
      .insert(notification);

    if (error) throw error;
    return true;
  } catch (error) {
    console.error('Error creating place recommendation notification:', error);
    return false;
  }
}; 