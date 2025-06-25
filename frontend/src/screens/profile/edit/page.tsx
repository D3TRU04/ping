import React, { useEffect, useState } from 'react';
import { View, Text, TextInput, Pressable, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import { useNavigation } from '@react-navigation/native';
import * as ImagePicker from 'expo-image-picker';
import { supabase } from '../../../../lib/supabase';
import { MaterialIcons as Icon } from '@expo/vector-icons';

const StyledSafeAreaView = styled(SafeAreaView);

export default function EditAccountScreen() {
  const navigation = useNavigation();

  const [name, setName] = useState('');
  const [username, setUsername] = useState('');
  const [birthday, setBirthday] = useState('');
  const [avatarUri, setAvatarUri] = useState<string | null>(null);
  const [userId, setUserId] = useState<string | null>(null);

  useEffect(() => {
    const fetchProfile = async () => {
      const {
        data: { user },
        error: userError,
      } = await supabase.auth.getUser();

      if (userError) {
        console.error('Failed to fetch user:', userError.message);
        return;
      }

      setUserId(user?.id || null);
      setName(user?.user_metadata?.full_name || '');

      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user?.id)
        .single();

      if (data) {
        setUsername(data.username || '');
        setBirthday(data.birthday || '');
        setAvatarUri(data.profile_picture || null);
      } else if (error) {
        console.error(error.message);
      }
    };

    fetchProfile();
  }, []);

  const pickAvatar = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1],
      quality: 1,
    });

    if (!result.canceled) {
      setAvatarUri(result.assets[0].uri);
    }
  };

  const uploadAvatar = async () => {
    if (!avatarUri || avatarUri.startsWith('http')) return avatarUri;

    const file = await fetch(avatarUri).then((res) => res.blob());
    const filePath = `avatars/${Date.now()}.jpg`;

    const { error } = await supabase.storage
      .from('avatars')
      .upload(filePath, file, { contentType: 'image/jpeg' });

    if (!error) {
      const { data } = supabase.storage.from('avatars').getPublicUrl(filePath);
      return data.publicUrl;
    } else {
      console.error('Upload failed:', error.message);
      return null;
    }
  };

  const handleSave = async () => {
    const newAvatar = await uploadAvatar();

    const [{ error: profileError }, { error: authError }] = await Promise.all([
      supabase
        .from('profiles')
        .update({
          username,
          birthday,
          profile_picture: newAvatar,
        })
        .eq('id', userId),

      supabase.auth.updateUser({
        data: { full_name: name },
      }),
    ]);

    if (profileError || authError) {
      console.error('Update failed:', profileError || authError);
    } else {
      alert('Profile updated!');
      navigation.goBack();
    }
  };

  return (
    <StyledSafeAreaView className="flex-1 p-6 bg-[#FAF6F2]">
      {/* ✅ Back Button */}
      <Pressable onPress={() => navigation.goBack()} className="mb-4">
        <View className="flex-row items-center">
          <Icon name="arrow-back" size={24} color="#4B5563" />
          <Text className="ml-2 text-base text-gray-800">Back to Settings</Text>
        </View>
      </Pressable>

      <Pressable onPress={pickAvatar} className="mb-4 items-center">
        {avatarUri ? (
          <Image source={{ uri: avatarUri }} className="w-24 h-24 rounded-full" />
        ) : (
          <View className="w-24 h-24 bg-gray-300 rounded-full justify-center items-center">
            <Text className="text-gray-600">Add Avatar</Text>
          </View>
        )}
      </Pressable>

      <Text className="mb-1 text-gray-700">Name</Text>
      <TextInput
        value={name}
        onChangeText={setName}
        className="border p-2 rounded bg-white mb-4"
        style={{ fontFamily: 'Satoshi-Medium' }}
      />

      <Text className="mb-1 text-gray-700">Username</Text>
      <TextInput
        value={username}
        onChangeText={setUsername}
        className="border p-2 rounded bg-white mb-4"
        style={{ fontFamily: 'Satoshi-Medium' }}
      />

      <Text className="mb-1 text-gray-700">Birthday</Text>
      <TextInput
        value={birthday}
        onChangeText={setBirthday}
        className="border p-2 rounded bg-white mb-6"
        style={{ fontFamily: 'Satoshi-Medium' }}
      />

      <Pressable onPress={handleSave} className="bg-blue-500 py-3 rounded">
        <Text className="text-white text-center font-semibold">Save Changes</Text>
      </Pressable>
    </StyledSafeAreaView>
  );
}
