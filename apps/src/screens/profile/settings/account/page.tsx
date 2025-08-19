import React, { useState, useEffect } from 'react';
import { View, ScrollView, Alert, Pressable } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { supabase } from '../../../../../lib/supabase';
import AppText from '../../../../components/AppText';
import { LinearGradient } from 'expo-linear-gradient';
import ProfilePicture from './components/ProfilePicture';
import PersonalInfo from './components/PersonalInfo';
import AccountActions from './components/AccountActions';
import ActionButtons from './components/ActionButtons';

const StyledSafeAreaView = styled(SafeAreaView);
const StyledView = styled(View);

export default function AccountInfoScreen() {
  const navigation = useNavigation();
  const [user, setUser] = useState<any>(null);
  const [profile, setProfile] = useState<any>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    fullName: '',
    username: '',
    email: '',
    phoneNumber: '',
    bio: '',
    location: '',
  });

  useEffect(() => {
    fetchUserData();
  }, []);

  const fetchUserData = async () => {
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error) {
      Alert.alert('Error', 'Failed to fetch user data');
      return;
    }
    setUser(user);

    if (user) {
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();

      if (profileError) {
        Alert.alert('Error', 'Failed to fetch profile data');
        return;
      }

      setProfile(profileData);
      setFormData({
        fullName: profileData.full_name || '',
        username: profileData.username || '',
        email: user.email || '',
        phoneNumber: profileData.phone_number || '',
        bio: profileData.bio || '',
        location: profileData.location || '',
      });
    }
  };

  const handleFormDataChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleSave = async () => {
    if (!user || !profile) return;

    try {
      const { error } = await supabase
        .from('profiles')
        .update({
          full_name: formData.fullName,
          username: formData.username,
          phone_number: formData.phoneNumber,
          bio: formData.bio,
          location: formData.location,
          updated_at: new Date().toISOString(),
        })
        .eq('id', user.id);

      if (error) {
        Alert.alert('Error', 'Failed to update profile');
        return;
      }

      Alert.alert('Success', 'Profile updated successfully');
      setIsEditing(false);
      await fetchUserData();
    } catch (error) {
      Alert.alert('Error', 'Something went wrong');
    }
  };

  const handleCancel = () => {
    setFormData({
      fullName: profile?.full_name || '',
      username: profile?.username || '',
      email: user?.email || '',
      phoneNumber: profile?.phone_number || '',
      bio: profile?.bio || '',
      location: profile?.location || '',
    });
    setIsEditing(false);
  };

  if (!user || !profile) {
    return (
      <LinearGradient colors={["#FAF6F2", "#F5F5F5"]} style={{ flex: 1 }}>
        <StyledSafeAreaView className="flex-1 bg-white">
          <StyledView className="flex-1 justify-center items-center">
            <AppText>Loading account information...</AppText>
          </StyledView>
        </StyledSafeAreaView>
      </LinearGradient>
    );
  }

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
          <AppText className="text-lg font-semibold text-gray-900">Account Info</AppText>
          <StyledView className="w-8 h-8" />
        </StyledView>

        <ScrollView className="flex-1 px-4 py-6" showsVerticalScrollIndicator={false}>
          <ProfilePicture fullName={profile.full_name} />
          <PersonalInfo 
            isEditing={isEditing}
            formData={formData}
            onFormDataChange={handleFormDataChange}
          />
          <AccountActions />
          <ActionButtons 
            isEditing={isEditing}
            onEdit={() => setIsEditing(true)}
            onSave={handleSave}
            onCancel={handleCancel}
          />
        </ScrollView>
      </StyledSafeAreaView>
    </LinearGradient>
  );
} 