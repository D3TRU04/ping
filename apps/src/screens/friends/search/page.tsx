import React, { useState, useEffect, useRef } from 'react';
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
  Animated,
} from 'react-native';
import { useNavigation, useRoute, RouteProp, useFocusEffect } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { supabase } from '../../../../lib/supabase';
import BottomNavBar from '../../../components/BottomNavBar';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AsyncStorage from '@react-native-async-storage/async-storage';
import AppText from '../../../components/AppText';

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
  const [recentSearches, setRecentSearches] = useState<any[]>([]);
  const [loadingRecentSearches, setLoadingRecentSearches] = useState(true);
  const [showResults, setShowResults] = useState(false);

  // Animation refs
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(20)).current;
  const listOpacity = useRef(new Animated.Value(0)).current;

  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<RouteProp<RootStackParamList, 'SearchUsersScreen'>>();
  const { currentUser } = route.params || {};

  // Load recent searches from storage on mount
  useEffect(() => {
    loadRecentSearches();
  }, []);

  // Reset search state when returning to the screen
  useFocusEffect(
    React.useCallback(() => {
      // Reset animation state when screen comes into focus, but don't clear search query
      fadeAnim.setValue(1);
      slideAnim.setValue(0);
      listOpacity.setValue(1);
      setShowResults(true); // Always show results if they exist
      
      // If there's an existing query, refetch the results
      if (query && query.trim().length > 0) {
        fetchMatchingUsers(query);
      }
    }, []) // Removed query dependency to prevent reloading on every character
  );

  // Reset animation state when component mounts or query changes
  useEffect(() => {
    if (!query || query.trim().length === 0) {
      // Reset animations when search is cleared
      fadeAnim.setValue(1);
      slideAnim.setValue(0);
      listOpacity.setValue(1);
      setShowResults(false);
    }
  }, [query]);

  // Fetch matching users as query updates
  useEffect(() => {
    // On mount, fetch all users if query is empty
    if (!query || query.trim().length === 0) {
      fetchMatchingUsers('');
    }

    const delayDebounce = setTimeout(() => {
      fetchMatchingUsers(query || '');
    }, 300); // debounce for smoother typing

    return () => clearTimeout(delayDebounce);
  }, [query, currentUser]);

  const loadRecentSearches = async () => {
    try {
      setLoadingRecentSearches(true);
      const recent = await AsyncStorage.getItem('recentSearches');
      if (recent) {
        const parsedRecent = JSON.parse(recent);
        setRecentSearches(parsedRecent);
      }
    } catch (error) {
      // Handle error silently
    } finally {
      setLoadingRecentSearches(false);
    }
  };

  const saveRecentSearch = async (userData: any) => {
    try {
      if (!userData || !userData.id) return;

      // Remove duplicate if exists and add to front
      const updatedRecent = [
        userData,
        ...recentSearches.filter(user => user.id !== userData.id)
      ].slice(0, 5);
      
      setRecentSearches(updatedRecent);
      await AsyncStorage.setItem('recentSearches', JSON.stringify(updatedRecent));
    } catch (error) {
      // Handle error silently
    }
  };

  const clearRecentSearches = async () => {
    try {
      setRecentSearches([]);
      await AsyncStorage.removeItem('recentSearches');
    } catch (error) {
      // Handle error silently
    }
  };

  const removeRecentSearch = async (userId: string) => {
    try {
      const updatedRecent = recentSearches.filter(user => user.id !== userId);
      setRecentSearches(updatedRecent);
      await AsyncStorage.setItem('recentSearches', JSON.stringify(updatedRecent));
    } catch (error) {
      // Handle error silently
    }
  };

  const fetchMatchingUsers = async (search: string) => {
    setLoading(true);
    let queryBuilder = supabase
      .from('profiles')
      .select('id, username, full_name, profile_picture');
    
    // Only exclude current user if currentUser exists
    if (currentUser?.id) {
      queryBuilder = queryBuilder.neq('id', currentUser.id);
    }

    if (search && search.trim().length > 0) {
      queryBuilder = queryBuilder.ilike('username', `${search}%`);
    }

    const { data, error } = await queryBuilder;
    if (!error && data) {
      const previousResultsLength = results.length;
      setResults(data);
      
      // Only animate if the number of results actually changed
      if (data.length > 0) {
        if (previousResultsLength === 0) {
          // Only animate in if we're going from 0 to some results
          animateResultsIn();
        } else {
          // Just ensure visibility without animation
          fadeAnim.setValue(1);
          slideAnim.setValue(0);
          listOpacity.setValue(1);
          setShowResults(true);
        }
      } else {
        if (previousResultsLength > 0) {
          // Only animate out if we're going from some results to 0
          animateResultsOut();
        }
      }
    }
    setLoading(false);
  };

  const handleUserPress = (user: any) => {
    // Save the user to recent searches when their profile is viewed
    saveRecentSearch(user);
    navigation.navigate('publicProfileScreen', {
      userId: user.id,
      fromScreen: 'SearchUsersScreen'
    });
  };

  const handleRecentSearchPress = (user: any) => {
    // Navigate directly to the user's profile
    navigation.navigate('publicProfileScreen', {
      userId: user.id,
      fromScreen: 'SearchUsersScreen'
    });
  };

  const animateResultsIn = () => {
    setShowResults(true);
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(listOpacity, {
        toValue: 1,
        duration: 250,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const animateResultsOut = () => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 0,
        duration: 200,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 20,
        duration: 200,
        useNativeDriver: true,
      }),
      Animated.timing(listOpacity, {
        toValue: 0,
        duration: 150,
        useNativeDriver: true,
      }),
    ]).start(() => {
      setShowResults(false);
    });
  };

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={{ flex: 1 }}
      >
        <StyledView className="flex-1 bg-white px-4 pt-4 pb-20">
          <StyledView className="flex-row items-center mb-6">
            <StyledTouchableOpacity
              onPress={() => navigation.goBack()}
              className="mr-3 p-1"
            >
              <Icon name="arrow-back" size={24} color="#1FC9C3" />
            </StyledTouchableOpacity>
            <StyledTextInput
              placeholder="Search by username"
              value={query}
              onChangeText={setQuery}
              className="flex-1 border border-gray-300 px-4 py-3 rounded-full text-base bg-white"
              autoCapitalize="none"
              autoCorrect={false}
              placeholderTextColor="#9CA3AF"
              style={{ 
                textAlignVertical: 'center',
                lineHeight: 20,
                paddingVertical: 12
              }}
            />
          </StyledView>


          {loading ? (
            <StyledView className="flex-1 items-center justify-center">
              <ActivityIndicator size="large" color="#1FC9C3" />
              <AppText className="text-mint mt-4">Searching...</AppText>
            </StyledView>
          ) : (
            <Animated.View 
              style={{
                flex: 1,
                opacity: (!query || query.trim().length === 0) ? 1 : (results.length > 0 || showResults ? 1 : listOpacity),
                transform: [{ translateY: (!query || query.trim().length === 0) ? 0 : (results.length > 0 || showResults ? 0 : slideAnim) }],
              }}
            >
              <FlatList
                data={!query || query.trim().length === 0 ? [] : results}
                keyExtractor={(item) => item.id}
                ListEmptyComponent={() => {
                  if (!query || query.trim().length === 0) {
                    // Show loading state while recent searches are being loaded
                    if (loadingRecentSearches) {
                      return (
                        <StyledView className="flex-1 items-center justify-center mt-20">
                          <ActivityIndicator size="large" color="#1FC9C3" />
                          <AppText className="text-mint mt-4">Loading...</AppText>
                        </StyledView>
                      );
                    }
                    
                    // Show recent searches when search bar is empty
                    return (
                      <StyledView className="flex-1 px-2">
                        {recentSearches.length > 0 ? (
                          <StyledView className="mb-6">
                            <StyledView className="flex-row items-center justify-between mb-6">
                              <AppText className="text-lg text-gray-800">
                                Recents
                              </AppText>
                              <StyledTouchableOpacity
                                onPress={clearRecentSearches}
                                className="p-2"
                              >
                                <AppText className="text-sm" style={{ color: '#1FC9C3' }}>
                                  Clear All
                                </AppText>
                              </StyledTouchableOpacity>
                            </StyledView>
                            {recentSearches.map((user, index) => (
                              <StyledTouchableOpacity
                                key={index}
                                onPress={() => handleRecentSearchPress(user)}
                                className="flex-row items-center p-4 mb-3"
                              >
                                <StyledView className="w-10 h-10 bg-gray-100 rounded-full items-center justify-center mr-4">
                                  <Image
                                    source={{ uri: user.profile_picture }}
                                    className="w-full h-full rounded-full"
                                    resizeMode="cover"
                                  />
                                </StyledView>
                                <StyledView className="flex-1">
                                  <AppText className="text-base text-gray-800">
                                    @{user.username}
                                  </AppText>
                                  <AppText className="text-sm text-gray-500">
                                    {user.full_name}
                                  </AppText>
                                </StyledView>
                                <StyledTouchableOpacity
                                  onPress={() => removeRecentSearch(user.id)}
                                  className="p-2"
                                >
                                  <Icon name="close" size={16} color="#9CA3AF" />
                                </StyledTouchableOpacity>
                              </StyledTouchableOpacity>
                            ))}
                          </StyledView>
                        ) : (
                          <StyledView className="items-center justify-center mt-16">
                            <StyledView className="w-16 h-16 bg-gray-100 rounded-full items-center justify-center mb-4">
                              <Icon name="search" size={32} color="#D1D5DB" />
                            </StyledView>
                            <AppText className="text-center text-gray-400 text-base">
                              Search for users by username
                            </AppText>
                            <AppText className="text-center text-gray-300 text-sm mt-1">
                              Your recent searches will appear here
                            </AppText>
                          </StyledView>
                        )}
                      </StyledView>
                    );
                  } else {
                    // Show "No users found" when there's a search query but no results
                    return (
                      <StyledView className="flex-1 items-center justify-center mt-20">
                        <AppText className="text-center text-gray-400 text-base">
                          No users found.
                        </AppText>
                      </StyledView>
                    );
                  }
                }}
                renderItem={({ item, index }) => (
                  <Animated.View
                    style={{
                      opacity: fadeAnim,
                      transform: [{ translateY: slideAnim }],
                    }}
                  >
                    <StyledTouchableOpacity
                      onPress={() => handleUserPress(item)}
                      className="flex-row items-center p-4 mx-1 mb-2 border-b border-gray-100 rounded-lg bg-white"
                      style={{
                        shadowColor: '#000',
                        shadowOffset: { width: 0, height: 1 },
                        shadowOpacity: 0.05,
                        shadowRadius: 2,
                        elevation: 1,
                      }}
                    >
                      <StyledView className="w-10 h-10 bg-gray-100 rounded-full items-center justify-center mr-4">
                        <Image
                          source={{ uri: item.profile_picture }}
                          className="w-full h-full rounded-full"
                          resizeMode="cover"
                        />
                      </StyledView>
                      <StyledView className="flex-1">
                        <AppText className="text-base text-gray-800">
                          @{item.username}
                        </AppText>
                        <AppText className="text-sm text-gray-500">
                          {item.full_name}
                        </AppText>
                      </StyledView>
                      <Icon name="chevron-right" size={20} color="#9CA3AF" />
                    </StyledTouchableOpacity>
                  </Animated.View>
                )}
              />
            </Animated.View>
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
