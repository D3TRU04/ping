import React, { useState, useEffect } from 'react';
import { View, Pressable, Image, Alert, ActivityIndicator } from 'react-native';
import { styled } from 'nativewind';
import * as ImagePicker from 'expo-image-picker';
import * as FileSystem from 'expo-file-system';
import { decode } from 'base64-arraybuffer';
import { supabase } from '../../../../../../lib/supabase';
import AppText from '../../../../../components/AppText';

const StyledView = styled(View);
const StyledImage = styled(Image);

interface ProfilePictureProps {
  fullName?: string;
  userId?: string;
  onImageUpdate?: (newImageUrl: string) => void;
}

export default function ProfilePicture({ fullName, userId, onImageUpdate }: ProfilePictureProps) {
  const [profileImage, setProfileImage] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [previousImagePath, setPreviousImagePath] = useState<string | null>(null);

  useEffect(() => {
    fetchCurrentProfilePicture();
  }, [userId]);

  const fetchCurrentProfilePicture = async () => {
    if (!userId) return;

    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('profile_picture')
        .eq('id', userId)
        .single();

      if (error) {
        console.error('Error fetching profile picture:', error);
        return;
      }

      if (data?.profile_picture) {
        setProfileImage(data.profile_picture);
        // Extract the file path for potential deletion
        const baseUrl = 'https://tghdxomcwphdmnapeuxs.supabase.co/storage/v1/object/public/profile-pictures/';
        if (data.profile_picture.includes(baseUrl)) {
          setPreviousImagePath(data.profile_picture.replace(baseUrl, ''));
        }
      }
    } catch (error) {
      console.error('Error fetching profile picture:', error);
    }
  };

  const requestPermissions = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('Permission required', 'Please allow photo access in your settings.');
      return false;
    }
    return true;
  };

  const pickImage = async () => {
    const hasPermission = await requestPermissions();
    if (!hasPermission) return;

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.8,
    });

    if (!result.canceled && result.assets?.[0]?.uri) {
      await uploadImage(result.assets[0].uri);
    }
  };

  const uploadImage = async (uri: string) => {
    if (!userId) return;

    setIsUploading(true);
    try {
      const fileExt = uri.split('.').pop()?.split('?')[0] || 'jpg';
      const fileName = `${userId}-${Date.now()}.${fileExt}`;
      const filePath = fileName;

      // Read the file as base64
      const base64 = await FileSystem.readAsStringAsync(uri, {
        encoding: FileSystem.EncodingType.Base64,
      });

      // Convert base64 to ArrayBuffer
      const arrayBuffer = decode(base64);

      // Upload to Supabase storage
      const { data, error } = await supabase.storage
        .from('profile-pictures')
        .upload(filePath, arrayBuffer, {
          cacheControl: '3600',
          upsert: true,
          contentType: `image/${fileExt}`,
        });

      if (error) {
        throw new Error(error.message);
      }

      // Get the public URL with cache-busting parameter
      const { data: { publicUrl } } = supabase.storage
        .from('profile-pictures')
        .getPublicUrl(filePath);
      
      // Add cache-busting parameter to ensure fresh image
      const publicUrlWithCacheBust = `${publicUrl}?t=${Date.now()}`;

      // Update the profile in the database
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ profile_picture: publicUrlWithCacheBust })
        .eq('id', userId);

      if (updateError) {
        throw new Error(updateError.message);
      }

      // Delete the previous image if it exists
      if (previousImagePath) {
        const { error: deleteError } = await supabase.storage
          .from('profile-pictures')
          .remove([previousImagePath]);

        if (deleteError) {
          console.warn('Failed to delete previous profile picture:', deleteError.message);
        } else {
          console.log('Previous profile picture deleted successfully');
        }
      }

      // Update local state
      setProfileImage(publicUrlWithCacheBust);
      setPreviousImagePath(filePath);
      
      // Notify parent component
      if (onImageUpdate) {
        onImageUpdate(publicUrlWithCacheBust);
      }

      // Add a delay to allow CDN propagation before stopping the loading indicator
      setTimeout(() => {
        // Success - no popup needed, just stop the loading indicator
        console.log('Profile picture updated successfully!');
        setIsUploading(false);
      }, 5000);
    } catch (error) {
      console.error('Upload error:', error);
      Alert.alert('Error', 'Failed to update profile picture. Please try again.');
      setIsUploading(false);
    }
  };

  return (
    <StyledView className="mb-6">
      <StyledView className="mb-3 px-2">
        <AppText className="text-sm font-medium text-gray-600">Profile Picture</AppText>
      </StyledView>
      
      <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden p-4 items-center">
        <StyledView className="w-20 h-20 bg-[#1FC9C3] rounded-full items-center justify-center mb-3 overflow-hidden">
          {profileImage ? (
            <StyledImage
              source={{ uri: profileImage }}
              className="w-full h-full"
              style={{ borderRadius: 40 }}
            />
          ) : (
            <AppText className="text-white font-bold text-2xl">
              {fullName ? fullName.charAt(0).toUpperCase() : 'U'}
            </AppText>
          )}
        </StyledView>
        
        {isUploading ? (
          <StyledView className="flex-row items-center justify-center">
            <ActivityIndicator size="small" color="#1FC9C3" style={{ marginRight: 8 }} />
            <AppText className="text-[#1FC9C3] font-medium">Uploading...</AppText>
          </StyledView>
        ) : (
          <Pressable 
            onPress={pickImage}
            style={({ pressed }) => [
              { opacity: pressed ? 0.7 : 1 }
            ]}
          >
            <AppText className="text-[#1FC9C3] font-medium text-center ">
              Change Photo
            </AppText>
          </Pressable>
        )}
      </StyledView>
    </StyledView>
  );
} 