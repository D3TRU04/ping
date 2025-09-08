import React, { useState } from 'react';
import { View, Alert } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../components/AppText';
import { supabase } from '../../../lib/supabase';
import { createFollowNotification } from '../notifications/services/notificationCreators';

const StyledView = styled(View);

export default function TestFollowNotification() {
  const [loading, setLoading] = useState(false);

  const testFollowNotification = async () => {
    setLoading(true);
    try {
      // Get current user
      const { data: { user }, error: userError } = await supabase.auth.getUser();
      if (userError) throw userError;
      
      if (!user) {
        Alert.alert('Error', 'No user logged in');
        return;
      }

      // Get a random user to follow (not the current user)
      const { data: users, error: usersError } = await supabase
        .from('profiles')
        .select('id, username, full_name, profile_picture')
        .neq('id', user.id)
        .limit(1);

      if (usersError) throw usersError;
      
      if (!users || users.length === 0) {
        Alert.alert('Error', 'No other users found to test with');
        return;
      }

      const targetUser = users[0];
      
      // Create follow notification
      const success = await createFollowNotification(user.id, targetUser.id);
      
      if (success) {
        Alert.alert(
          'Success!', 
          `Follow notification sent to ${targetUser.username || targetUser.full_name}. Check their notifications screen!`
        );
      } else {
        Alert.alert('Error', 'Failed to create follow notification');
      }
    } catch (error) {
      console.error('Error testing follow notification:', error);
      Alert.alert('Error', 'Failed to test follow notification');
    } finally {
      setLoading(false);
    }
  };

  return (
    <StyledView className="flex-1 justify-center items-center bg-white p-4">
      <AppText className="text-xl font-bold mb-4 text-center">
        Follow Notification Test
      </AppText>
      
      <AppText className="text-gray-600 text-center mb-6 leading-5">
        This will send a follow notification from the current user to a random user in the database.
      </AppText>

      <StyledView 
        className={`px-6 py-3 rounded-lg ${loading ? 'bg-gray-400' : 'bg-[#1FC9C3]'}`}
        onTouchEnd={loading ? undefined : testFollowNotification}
      >
        <AppText className="text-white font-semibold text-center">
          {loading ? 'Testing...' : 'Send Test Follow Notification'}
        </AppText>
      </StyledView>

      <AppText className="text-sm text-gray-500 text-center mt-4">
        To see the notification:{'\n'}
        1. Switch to the target user's account{'\n'}
        2. Go to their Notifications screen{'\n'}
        3. Look for the follow notification
      </AppText>
    </StyledView>
  );
}
