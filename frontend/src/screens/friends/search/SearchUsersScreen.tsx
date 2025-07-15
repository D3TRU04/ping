import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  FlatList,
  TouchableOpacity,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  Image,
} from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { supabase } from '../../../../lib/supabase';
import { BottomNavBar } from '@/src/components/navbar';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';

type RootStackParamList = {
  publicProfileScreen: { userId: string };
  SearchUsersScreen: { currentUser: any };
};

type NavigationProp = StackNavigationProp<RootStackParamList, 'publicProfileScreen'>;

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTextInput = styled(TextInput);
const StyledTouchableOpacity = styled(TouchableOpacity);

const SearchUsersScreen = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<RouteProp<RootStackParamList, 'SearchUsersScreen'>>();
  const { currentUser } = route.params || {};

  // Fetch matching users as query updates
  useEffect(() => {
    // On mount, fetch all users if query is empty
    if (query.trim().length === 0) {
      fetchMatchingUsers('');
    }

    const delayDebounce = setTimeout(() => {
      fetchMatchingUsers(query);
    }, 300); // debounce for smoother typing

    return () => clearTimeout(delayDebounce);
  }, [query]);

  const fetchMatchingUsers = async (search: string) => {
    setLoading(true);
    let queryBuilder = supabase
      .from('profiles')
      .select('id, username, full_name, profile_picture')
      .neq('id', currentUser.id); // Exclude self

    if (search.trim().length > 0) {
      queryBuilder = queryBuilder.ilike('username', `${search}%`);
    }

    const { data, error } = await queryBuilder;
    if (!error && data) {
      setResults(data);
    }
    setLoading(false);
  };

  const handleUserPress = (user: any) => {
    navigation.navigate('ChatRoomScreen', {
      currentUser,
      otherUser: {
        id: user.id,
        name: user.full_name || user.username,
        avatar: user.profile_picture || null,
      },
    });
  };

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={{ flex: 1 }}
      >
        <StyledView className="flex-1 bg-white px-4 pt-6 pb-20">
          <StyledTextInput
            placeholder="Search by username"
            value={query}
            onChangeText={setQuery}
            className="border border-gray-300 px-4 py-2 rounded-full text-base bg-white"
            autoCapitalize="none"
            autoCorrect={false}
            placeholderTextColor="#9CA3AF"
          />


          {loading ? (
            <StyledView className="flex-1 items-center justify-center">
              <ActivityIndicator size="large" color="#1FC9C3" />
              <StyledText className="text-mint mt-4">Searching...</StyledText>
            </StyledView>
          ) : (
            <FlatList
              data={results}
              keyExtractor={(item) => item.id}
              ListEmptyComponent={() =>
                query.length > 0 && (
                  <StyledText className="text-center text-gray-400 mt-4">
                    No users found.
                  </StyledText>
                )
              }
              renderItem={({ item }) => (
                <StyledTouchableOpacity
                  onPress={() => handleUserPress(item)}
                  className="flex-row items-center p-2 border-b border-white"
                >


                  {/* Profile picture */}
                  <StyledView className="mr-3">
                    <Image
                      source={
                        item.profile_picture
                          ? { uri: item.profile_picture }
                          : require('../../../../src/assets/profilepic.png') // fallback image
                      }
                      className="w-10 h-10 rounded-full"
                      resizeMode="cover"
                    />
                  </StyledView>

                  <StyledView className="flex-1">
                    <StyledText className="text-xs font-semibold text-gray-800">
                      @{item.username}
                    </StyledText>
                    <StyledText className="text-xs text-gray-500">
                      {item.full_name}
                    </StyledText>
                  </StyledView>
                  <Icon name="chevron-right" size={20} color="#9CA3AF" />
                </StyledTouchableOpacity>
              )}
            />
          )}
        </StyledView>

        {/* Bottom Navigation */}
    <BottomNavBar
      currentUser={currentUser}
      style={{
        position: 'absolute',
        left: 0,
        right: 0,
        bottom: -33, // move down by 12px
      }}
    />
   
  </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

export default SearchUsersScreen;
