import React, { useState, useEffect } from 'react';
import { View, ScrollView, Alert } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../components/AppText';
import { supabase } from '../../../lib/supabase';
import { createFollowNotification } from '../notifications/services/notificationCreators';

const StyledView = styled(View);
const StyledScrollView = styled(ScrollView);

interface TestUser {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

export default function FollowNotificationTest() {
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [testUsers, setTestUsers] = useState<TestUser[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadCurrentUser();
    loadTestUsers();
  }, []);

  const loadCurrentUser = async () => {
    try {
      const { data: { user }, error } = await supabase.auth.getUser();
      if (error) throw error;
      setCurrentUser(user);
    } catch (error) {
      console.error('Error loading current user:', error);
    }
  };

  const loadTestUsers = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('profiles')
        .select('id, username, full_name, profile_picture')
        .limit(10);

      if (error) throw error;
      setTestUsers(data || []);
    } catch (error) {
      console.error('Error loading test users:', error);
    } finally {
      setLoading(false);
    }
  };

  const testFollowNotification = async (targetUserId: string, targetUsername: string) => {
    if (!currentUser) {
      Alert.alert('Error', 'No current user found');
      return;
    }

    try {
      const success = await createFollowNotification(currentUser.id, targetUserId);
      if (success) {
        Alert.alert(
          'Success!', 
          `Follow notification sent to ${targetUsername}. Check their notifications screen to see it!`
        );
      } else {
        Alert.alert('Error', 'Failed to create follow notification');
      }
    } catch (error) {
      console.error('Error creating follow notification:', error);
      Alert.alert('Error', 'Failed to create follow notification');
    }
  };

  const checkNotifications = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('notifications')
        .select('*')
        .eq('recipient_id', userId)
        .order('created_at', { ascending: false });

      if (error) throw error;
      
      Alert.alert(
        'Notifications', 
        `Found ${data?.length || 0} notifications for this user`
      );
    } catch (error) {
      console.error('Error checking notifications:', error);
      Alert.alert('Error', 'Failed to check notifications');
    }
  };

  if (loading) {
    return (
      <StyledView className="flex-1 justify-center items-center bg-white">
        <AppText className="text-lg">Loading test users...</AppText>
      </StyledView>
    );
  }

  return (
    <StyledView className="flex-1 bg-white">
      <StyledView className="p-4 bg-[#1FC9C3]">
        <AppText className="text-white text-xl font-bold text-center">
          Follow Notification Test
        </AppText>
        <AppText className="text-white text-center mt-2">
          Current User: {currentUser?.email || 'Not logged in'}
        </AppText>
      </StyledView>

      <StyledScrollView className="flex-1 p-4">
        <AppText className="text-lg font-semibold mb-4">
          Test Users (Click to send follow notification)
        </AppText>

        {testUsers.map((user) => (
          <StyledView 
            key={user.id}
            className="bg-gray-50 rounded-lg p-4 mb-3 border border-gray-200"
          >
            <StyledView className="flex-row items-center justify-between">
              <StyledView className="flex-row items-center flex-1">
                <StyledView className="w-12 h-12 bg-gray-300 rounded-full mr-3 items-center justify-center">
                  {user.profile_picture ? (
                    <AppText className="text-xs">IMG</AppText>
                  ) : (
                    <Icon name="person" size={24} color="#666" />
                  )}
                </StyledView>
                <StyledView className="flex-1">
                  <AppText className="font-semibold text-gray-900">
                    {user.full_name || 'No name'}
                  </AppText>
                  <AppText className="text-gray-600">@{user.username}</AppText>
                  <AppText className="text-xs text-gray-500">ID: {user.id}</AppText>
                </StyledView>
              </StyledView>
              
              <StyledView className="flex-row">
                <StyledView 
                  className="bg-[#1FC9C3] px-3 py-2 rounded-lg mr-2"
                  onTouchEnd={() => testFollowNotification(user.id, user.username)}
                >
                  <AppText className="text-white font-medium text-xs">
                    Send Follow
                  </AppText>
                </StyledView>
                
                <StyledView 
                  className="bg-gray-500 px-3 py-2 rounded-lg"
                  onTouchEnd={() => checkNotifications(user.id)}
                >
                  <AppText className="text-white font-medium text-xs">
                    Check Notifications
                  </AppText>
                </StyledView>
              </StyledView>
            </StyledView>
          </StyledView>
        ))}

        <StyledView className="mt-6 p-4 bg-blue-50 rounded-lg">
          <AppText className="font-semibold text-blue-900 mb-2">
            How to Test:
          </AppText>
          <AppText className="text-blue-800 text-sm leading-5">
            1. Click "Send Follow" for any user above{'\n'}
            2. Switch to that user's account{'\n'}
            3. Go to their Notifications screen{'\n'}
            4. You should see a follow notification with their profile picture, username, and "{username} has followed you" message
          </AppText>
        </StyledView>
      </StyledScrollView>
    </StyledView>
  );
}
