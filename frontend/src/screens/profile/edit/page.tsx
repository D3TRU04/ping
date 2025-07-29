import React, { useEffect, useState } from 'react';
import { View, Text, TextInput, Pressable, Image, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import { useNavigation } from '@react-navigation/native';
import * as ImagePicker from 'expo-image-picker';
import { supabase } from '../../../../lib/supabase';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import DateTimePicker from '@react-native-community/datetimepicker';
import { ActivityIndicator, Alert } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import AppText from '../../../components/AppText';
import { uploadProfilePicture } from '../../../utils/uploadProfilePictures';
import * as FileSystem from 'expo-file-system';
import { decode } from 'base64-arraybuffer';



const StyledSafeAreaView = styled(SafeAreaView);
const StyledImage = styled(Image);

// Helper to format date as MM/DD/YYYY (no Date object, just string manipulation)
function formatBirthday(dateStr: string): string {
  if (!dateStr) return '';
  // If already MM/DD/YYYY
  if (/^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/.test(dateStr)) return dateStr;
  // If YYYY-MM-DD
  if (/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/.test(dateStr)) {
    const [yyyy, mm, dd] = dateStr.split('-');
    return `${mm}/${dd}/${yyyy}`;
  }
  // If MM-DD-YYYY
  if (/^[0-9]{2}-[0-9]{2}-[0-9]{4}$/.test(dateStr)) {
    const [mm, dd, yyyy] = dateStr.split('-');
    return `${mm}/${dd}/${yyyy}`;
  }
  return dateStr;
}

// Helper to convert MM/DD/YYYY to YYYY-MM-DD for saving
function unformatBirthday(dateStr: string): string {
  if (!dateStr) return '';
  // If already YYYY-MM-DD
  if (/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/.test(dateStr)) return dateStr;
  // If MM/DD/YYYY
  if (/^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/.test(dateStr)) {
    const [mm, dd, yyyy] = dateStr.split('/');
    return `${yyyy}-${mm}-${dd}`;
  }
  // If MM-DD-YYYY
  if (/^[0-9]{2}-[0-9]{2}-[0-9]{4}$/.test(dateStr)) {
    const [mm, dd, yyyy] = dateStr.split('-');
    return `${yyyy}-${mm}-${dd}`;
  }
  return dateStr;
}

export default function EditAccountScreen() {
  const navigation = useNavigation();

  const [name, setName] = useState('');
  const [username, setUsername] = useState('');
  const [phone, setPhone] = useState('');
  const [bio, setBio] = useState('');
  const [links, setLinks] = useState('');
  const [pronouns, setPronouns] = useState('');
  const [location, setLocation] = useState('');
  const [avatarUri, setAvatarUri] = useState<string | null>(null);
  const [userId, setUserId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [usernameAvailable, setUsernameAvailable] = useState<boolean | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [birthday, setBirthday] = useState('');
  const [email, setEmail] = useState('');
  const [previousImagePath, setPreviousImagePath] = useState<string | null>(null);


  useEffect(() => {
    const fetchProfile = async () => {
      setLoading(true);
      setError(null);
      try {
        const { data: { user }, error: userError } = await supabase.auth.getUser();
        if (userError) throw userError;
        setUserId(user?.id || null);
        setName(user?.user_metadata?.full_name || '');
        setEmail(user?.email || '');
        const { data, error } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user?.id)
          .single();
        if (data) {
          setUsername(data.username || '');
          setPhone(data.phone_number || '');
          setBio(data.bio || '');
          setLinks(data.links || '');
          setPronouns(data.pronouns || '');
          setLocation(data.location || '');
          setAvatarUri(data.profile_picture || null);
          if (data?.profile_picture) {
            setAvatarUri(data.profile_picture);
            const baseUrl = 'https://tghdxomcwphdmnapeuxs.supabase.co/storage/v1/object/public/profile-pictures/';
            setPreviousImagePath(data.profile_picture.replace(baseUrl, ''));
          }
          setBirthday(formatBirthday(data.birthday || ''));
          if (data.username) checkUsername(data.username);
        } else if (error) {
          throw error;
        }
      } catch (err: any) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchProfile();
  }, []);


  /* request permission once when the screen opens 
    (rather than each time they press the upload button), */
  useEffect(() => {
  const requestMediaPermission = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('Permission required', 'Please allow photo access in your settings.');
    }
  };
  requestMediaPermission();
}, []);


  const checkUsername = async (uname: string) => {
    if (!uname || uname.length < 3) {
      setUsernameAvailable(null);
      return;
    }
    const { data, error } = await supabase
      .from('profiles')
      .select('username')
      .eq('username', uname)
      .neq('id', userId)
      .single();
    setUsernameAvailable(!data);
  };

  const [selectedAvatarUri, setSelectedAvatarUri] = useState<string | null>(null);


  const pickAvatar = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('Permission required', 'Please allow photo access.');
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1],
      quality: 1,
    });

    if (!result.canceled && result.assets?.[0]?.uri) {
      const selectedUri = result.assets[0].uri;

      // Capture previous image path for later deletion
      if (avatarUri?.includes('profile-pictures')) {
        const previousPath = avatarUri.split('/profile-pictures/')[1];
        setPreviousImagePath(previousPath);
      }

      setSelectedAvatarUri(selectedUri); // only preview
    }
  };




  const uploadAvatar = async (uri: string | null, userId: string | null) => {
    if (!uri || uri.startsWith('http') || !userId) return uri;

    try {
      const fileExt = uri.split('.').pop()?.split('?')[0] || 'jpg';
      const fileName = `${userId}-${Date.now()}.${fileExt}`;
      const filePath = fileName;

      const { data: { session }, error } = await supabase.auth.getSession();
      if (error || !session?.access_token) throw new Error('Authentication failed.');

      const formData = new FormData();
      formData.append('file', {
        uri,
        name: fileName,
        type: 'image/jpeg',
      } as any);

      const uploadUrl = `${process.env.EXPO_PUBLIC_SUPABASE_URL}/storage/v1/object/profile-pictures/${filePath}`;

      const res = await fetch(uploadUrl, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${session.access_token}`,
          'Content-Type': 'multipart/form-data',
        },
        body: formData,
      });

      if (!res.ok) throw new Error(await res.text());

      const { publicUrl } = supabase.storage.from('profile-pictures').getPublicUrl(filePath).data;
      return publicUrl;
    } catch (err) {
      console.error('Upload error:', err);
      if (err instanceof Error) setError(err.message);
      return null;
    }
  };

  const handleBack = async () => {
    setLoading(true);
    setError(null);
    try {
      if (!usernameAvailable && username !== '' && userId) {
        const { data: userProfile } = await supabase
          .from('profiles')
          .select('username')
          .eq('id', userId)
          .single();
        if (userProfile && userProfile.username === username) {
          // Username is unchanged and belongs to user, allow save
          // continue
        } else {
          setError('Username is not available.');
          setLoading(false);
          Alert.alert('Error', 'Username is not available.');
          return;
        }
      } else if (!usernameAvailable) {
        setError('Username is not available.');
        setLoading(false);
        Alert.alert('Error', 'Username is not available.');
        return;
      }
    
      const newAvatar = await uploadAvatar(selectedAvatarUri, userId);

      console.log('Attempting to delete previous image at:', previousImagePath);

      if (previousImagePath && selectedAvatarUri) {
        const { error: deleteError } = await supabase.storage
          .from('profile-pictures')
          .remove([previousImagePath]);

        if (deleteError) {
          console.warn('❌ Failed to delete previous profile picture:', deleteError.message);
        } else {
          console.log('✅ Previous profile picture deleted:', previousImagePath);
        }
      }



      // Save birthday in ISO format (YYYY-MM-DD)
      const birthdayFormatted = unformatBirthday(birthday);
      const [{ error: profileError }, { error: authError }] = await Promise.all([
        supabase
          .from('profiles')
          .update({
            username,
            phone_number: phone,
            bio,
            links,
            pronouns,
            location,
            profile_picture: newAvatar,
            full_name: name,
            birthday: birthdayFormatted,
          })
          .eq('id', userId),
        supabase.auth.updateUser({
          email,
          data: { full_name: name },
        }),
      ]);
      if (profileError || authError) {
        throw profileError || authError;
      } else {
        navigation.goBack();
      }
    } catch (err: any) {
      setError(err.message);
      Alert.alert('Error', err.message);
    } finally {
      setLoading(false);
    }
  };

  // Modern Top NavBar
  const TopNavBar = () => (
    <View
      className="w-full flex-row items-center justify-between px-4 pb-1"
      style={{
        paddingTop: 4,
        backgroundColor: 'white',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.08,
        shadowRadius: 2,
        elevation: Platform.OS === 'android' ? 2 : 0,
      }}
    >
      <View className="flex-row items-center min-w-[40px] bg-white">
        <Pressable onPress={handleBack} style={{ elevation: 2 }}>
          <Icon name="arrow-back" size={24} color="#1FC9C3" />
        </Pressable>
      </View>
      <AppText className="text-2xl font-semibold text-gray-900 text-center flex-1" style={{ fontFamily: 'Satoshi-Medium' }}>
        Edit Profile
      </AppText>
      <View className="min-w-[40px]" />
    </View>
  );

  return (
    <LinearGradient colors={["#FAF6F2", "#F5F5F5"]} style={{ flex: 1 }}>
      <StyledSafeAreaView className="flex-1 bg-white">
        <TopNavBar />
        <ScrollView contentContainerStyle={{ flexGrow: 1 }} showsVerticalScrollIndicator={false}>
          {/* Card Container */}
          <View className="mx-4 mt-6 mb-2 rounded-2xl shadow-lg p-6">
            {/* Profile Picture */}
            <View className="mb-3 mx-auto" style={{ width: 120, height: 120, borderRadius: 60, borderWidth: 4, borderColor: '#E0E7EF', overflow: 'hidden' }}>
              <StyledImage
                source={selectedAvatarUri ? { uri: selectedAvatarUri } : avatarUri ? { uri: avatarUri } : require('../../../../src/assets/profilepic.png')}
                className="w-full h-full rounded-full"
                style={{
                  shadowColor: '#000',
                  shadowOpacity: 0.1,
                  shadowRadius: 8,
                  shadowOffset: { width: 0, height: 2 },
                }}
              />
            </View>
            <Pressable onPress={pickAvatar} className="mb-6 items-center mt-2">
              <AppText className="text-sm text-[#00B4D8] mt-2">Change Profile Picture</AppText>
            </Pressable>
            {/* Form Fields */}
            <AppText className="mb-1 text-gray-700 font-semibold">Name</AppText>
            <TextInput
              value={name}
              onChangeText={setName}
              className="border p-3 rounded-xl bg-white mb-4 text-base"
              style={{ fontFamily: 'Satoshi-Medium' }}
            />
            <AppText className="mb-1 text-gray-700 font-semibold">Username</AppText>
            <TextInput
              value={username}
              onChangeText={(val) => {
                setUsername(val);
                checkUsername(val);
              }}
              className="border p-3 rounded-xl bg-white mb-1 text-base"
              style={{ fontFamily: 'Satoshi-Medium' }}
              autoCapitalize="none"
              autoCorrect={false}
            />
            {username && username.length > 2 && (
              <AppText className={usernameAvailable === null ? 'text-gray-400' : usernameAvailable ? 'text-green-600' : 'text-red-500'}>
                {usernameAvailable === null ? '' : usernameAvailable ? 'Username available' : 'Username taken'}
              </AppText>
            )}
            <AppText className="mb-1 text-gray-700 font-semibold mt-2">Phone Number</AppText>
            <TextInput
              value={phone}
              onChangeText={setPhone}
              className="border p-3 rounded-xl bg-white mb-4 text-base"
              style={{ fontFamily: 'Satoshi-Medium' }}
              keyboardType="phone-pad"
            />
            <AppText className="mb-1 text-gray-700 font-semibold">Bio</AppText>
            <TextInput
              value={bio}
              onChangeText={setBio}
              className="border p-3 rounded-xl bg-white mb-4 text-base"
              style={{ fontFamily: 'Satoshi-Medium' }}
              multiline
              numberOfLines={3}
              maxLength={160}
            />
            <AppText className="mb-1 text-gray-700 font-semibold">Links</AppText>
            <TextInput
              value={links}
              onChangeText={setLinks}
              className="border p-3 rounded-xl bg-white mb-4 text-base"
              style={{ fontFamily: 'Satoshi-Medium' }}
              placeholder="https://yourwebsite.com"
              autoCapitalize="none"
              autoCorrect={false}
            />
            <AppText className="mb-1 text-gray-700 font-semibold">Pronouns</AppText>
            <TextInput
              value={pronouns}
              onChangeText={setPronouns}
              className="border p-3 rounded-xl bg-white mb-4 text-base"
              style={{ fontFamily: 'Satoshi-Medium' }}
              placeholder="e.g. she/her, he/him, they/them"
              autoCapitalize="none"
              autoCorrect={false}
            />
            <AppText className="mb-1 text-gray-700 font-semibold">Location</AppText>
            <TextInput
              value={location}
              onChangeText={setLocation}
              className="border p-3 rounded-xl bg-white mb-6 text-base"
              style={{ fontFamily: 'Satoshi-Medium' }}
              placeholder="City, State or Country"
            />
            <AppText className="mb-1 text-gray-700 font-semibold">Birthday</AppText>
            <TextInput
              value={birthday}
              onChangeText={setBirthday}
              className="border p-3 rounded-xl bg-white mb-6 text-base"
              style={{ fontFamily: 'Satoshi-Medium' }}
              placeholder="MM/DD/YYYY"
            />
            <AppText className="mb-1 text-gray-700 font-semibold">Email</AppText>
            <TextInput
              value={email}
              onChangeText={setEmail}
              className="border p-3 rounded-xl bg-white mb-4 text-base"
              style={{ fontFamily: 'Satoshi-Medium' }}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />
            {error && <AppText className="text-red-500 mt-2">{error}</AppText>}
            {success && <AppText className="text-green-600 mt-2">{success}</AppText>}
          </View>
        </ScrollView>
      </StyledSafeAreaView>
    </LinearGradient>
  );
}
