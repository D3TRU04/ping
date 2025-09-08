import React, { useState, useEffect } from 'react';
import { View, Pressable, ScrollView, Alert } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { supabase } from '../../../../../lib/supabase';
import AppText from '../../../../components/AppText';
import { LinearGradient } from 'expo-linear-gradient';
import NotificationGroup from './components/NotificationGroup';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);

export default function NotificationsSettingsScreen() {
  const navigation = useNavigation();
  const [pushNotifications, setPushNotifications] = useState(false);
  const [emailNotifications, setEmailNotifications] = useState(false);
  const [messages, setMessages] = useState(false);
  const [placeRecommendations, setPlaceRecommendations] = useState(false);
  const [loading, setLoading] = useState(true);
  const [userId, setUserId] = useState<string | null>(null);

  // Fetch current user and notification settings
  useEffect(() => {
    fetchUserAndSettings();
  }, []);

  // Create default notification settings for users who don't have them
  const createDefaultNotificationSettings = async () => {
    if (!userId) return;

    try {
      const { error } = await supabase
        .from('notification_settings')
        .insert({
          user_id: userId,
          push_notifications: true,
          email_notifications: true,
          message_notifications: true,
          place_recommendation_notifications: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        });

      if (error) {
        throw error;
      }

      // Set the default values in state
      setPushNotifications(true);
      setEmailNotifications(true);
      setMessages(true);
      setPlaceRecommendations(true);

      console.log('Default notification settings created successfully');
    } catch (error) {
      console.error('Error creating default notification settings:', error);
      Alert.alert('Error', 'Failed to create notification settings');
    }
  };

  const fetchUserAndSettings = async () => {
    try {
      setLoading(true);
      
      // Get current user
      const { data: { user }, error: userError } = await supabase.auth.getUser();
      if (userError) throw userError;
      
      setUserId(user?.id || null);
      if (!user?.id) return;

      // Fetch notification settings
      const { data: settings, error: settingsError } = await supabase
        .from('notification_settings')
        .select('*')
        .eq('user_id', user.id)
        .single();

      if (settingsError && settingsError.code !== 'PGRST116') {
        // PGRST116 means no rows found, which is fine for new users
        throw settingsError;
      }

      if (settings) {
        setPushNotifications(settings.push_notifications || false);
        setEmailNotifications(settings.email_notifications || false);
        setMessages(settings.message_notifications || false);
        setPlaceRecommendations(settings.place_recommendation_notifications || false);
      } else {
        // If no settings found, create default settings for the user
        console.log('No notification settings found, creating default settings');
        await createDefaultNotificationSettings();
      }
    } catch (error) {
      console.error('Error fetching notification settings:', error);
      Alert.alert('Error', 'Failed to load notification settings');
    } finally {
      setLoading(false);
    }
  };

  // Update notification setting in database
  const updateNotificationSetting = async (setting: string, value: boolean) => {
    if (!userId) return;

    try {
      const { error } = await supabase
        .from('notification_settings')
        .upsert({
          user_id: userId,
          [setting]: value,
          updated_at: new Date().toISOString(),
        }, {
          onConflict: 'user_id'
        });

      if (error) {
        throw error;
      }

      console.log(`Updated ${setting} to ${value}`);
    } catch (error) {
      console.error(`Error updating ${setting}:`, error);
      Alert.alert('Error', `Failed to update ${setting} setting`);
    }
  };

  // Handle toggle changes
  const handlePushNotificationsChange = (value: boolean) => {
    setPushNotifications(value);
    updateNotificationSetting('push_notifications', value);
  };

  const handleEmailNotificationsChange = (value: boolean) => {
    setEmailNotifications(value);
    updateNotificationSetting('email_notifications', value);
  };

  const handleMessagesChange = (value: boolean) => {
    setMessages(value);
    updateNotificationSetting('message_notifications', value);
  };

  const handlePlaceRecommendationsChange = (value: boolean) => {
    setPlaceRecommendations(value);
    updateNotificationSetting('place_recommendation_notifications', value);
  };

  const generalNotifications = [
    {
      icon: 'notifications',
      label: 'Push Notifications',
      value: pushNotifications,
      onValueChange: handlePushNotificationsChange,
    },
    {
      icon: 'email',
      label: 'Email Notifications',
      value: emailNotifications,
      onValueChange: handleEmailNotificationsChange,
    },
  ];

  const appNotifications = [
    {
      icon: 'chat',
      label: 'Messages',
      value: messages,
      onValueChange: handleMessagesChange,
    },
    {
      icon: 'place',
      label: 'Place Recommendations',
      value: placeRecommendations,
      onValueChange: handlePlaceRecommendationsChange,
    },
  ];

  return (
    <LinearGradient colors={["#FAF6F2", "#F5F5F5"]} style={{ flex: 1 }}>
      <StyledSafeAreaView className="flex-1 bg-white">
        <StyledView className="w-full flex-row items-center justify-between px-4 py-3 bg-white border-b border-gray-100">
          <Pressable 
            onPress={() => navigation.goBack()} 
            className="w-8 h-8 rounded-lg bg-transparent items-center justify-center"
            style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}
          >
            <Icon name="arrow-back" size={20} color="#1FC9C3" />
          </Pressable>
          {/* <AppText className="text-lg font-semibold text-gray-900">Notifications</AppText> */}
          <StyledView className="w-8 h-8" />
        </StyledView>

        <ScrollView className="flex-1 px-4 py-6" showsVerticalScrollIndicator={false}>
          {loading ? (
            <StyledView className="flex-1 justify-center items-center py-20">
              <AppText className="text-gray-500">Loading notification settings...</AppText>
            </StyledView>
          ) : (
            <>
              <NotificationGroup title="General" items={generalNotifications} />
              <NotificationGroup title="App Notifications" items={appNotifications} />
            </>
          )}
        </ScrollView>
      </StyledSafeAreaView>
    </LinearGradient>
  );
} 