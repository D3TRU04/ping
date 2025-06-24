// ✅ NEW HomeScreen.tsx with subcategory name-mapping
import React, { useState, useEffect } from 'react';
import {
  View,
  Image,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Dimensions,
  RefreshControl,
  Alert,
  ScrollView,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useSafeAreaInsets, SafeAreaView } from 'react-native-safe-area-context';
import { supabase } from '../../../lib/supabase';
import { styled } from 'nativewind';
import TopNavBar from '../../components/navbar/Home';
import BottomNavBar from '../../components/navbar/BottomNavBar';
import AppText from '../../components/AppText';
import { COLORS } from '../../theme/colors';
import { categories } from '../auth/onboarding/data'; // 📦 Importing categories config

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);
// const StyledSafeAreaView = styled(SafeAreaView);

const { height: SCREEN_HEIGHT } = Dimensions.get('window');
const CARD_HEIGHT = SCREEN_HEIGHT * 0.75;

// 🧭 Navigation type setup
type RootStackParamList = {
  Home: undefined;
  Profile: undefined;
  ProfileScreen: undefined;
  Notifications: undefined;
  Discover: undefined;
};
type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

// 📄 Food place structure
interface FoodPlace {
  place_id: string;
  name: string;
  image_url?: string;
  description?: string;
  type_of_food?: string;
  subtopic?: string;
  rating?: number;
  price_range?: number;
  hours: string[];
  address?: string;
  phone?: string;
}

// 🧠 Helper to map stored value (e.g., "Thai & Southeast Asian Cuisine") to display name (e.g., "Thai")
const getDisplayNameFromValue = (value: string): string => {
  for (const cat of categories) {
    const match = cat.subcategories.find(sub => sub.value === value);
    if (match) return match.name;
  }
  return value; // fallback if not found
};

const getPriceRangeText = (priceRange?: number): string => {
  if (!priceRange) return '';
  return '$'.repeat(priceRange);
};

// Add this helper function above the HomeScreen component
const DAY_ORDER = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];
const DAY_SHORT = {
  'Monday': 'Mon',
  'Tuesday': 'Tue',
  'Wednesday': 'Wed',
  'Thursday': 'Thu',
  'Friday': 'Fri',
  'Saturday': 'Sat',
  'Sunday': 'Sun',
};
function groupHours(hoursArr: string[]) {
  // Parse into [{day, time}]
  const parsed = hoursArr.map(h => {
    const [day, ...rest] = h.split(':');
    return { day: day.trim(), time: rest.join(':').trim() };
  });
  // Sort by day order
  parsed.sort((a, b) => DAY_ORDER.indexOf(a.day) - DAY_ORDER.indexOf(b.day));
  // Group consecutive days with same time
  const groups = [];
  let i = 0;
  while (i < parsed.length) {
    let start = i;
    let end = i;
    while (
      end + 1 < parsed.length &&
      parsed[end + 1].time === parsed[start].time &&
      DAY_ORDER.indexOf(parsed[end + 1].day) === DAY_ORDER.indexOf(parsed[end].day) + 1
    ) {
      end++;
    }
    groups.push({
      start: parsed[start].day,
      end: parsed[end].day,
      time: parsed[start].time,
    });
    i = end + 1;
  }
  return groups;
}

export default function HomeScreen() {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const route = useRoute<any>();
  const currentUser = route?.params?.currentUser;
  // const insets = useSafeAreaInsets();

  const [contentData, setContentData] = useState<FoodPlace[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [savedPlaces, setSavedPlaces] = useState<Set<string>>(new Set());
  const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
  const [, setCurrentIndex] = useState(0);
  const [expandedDesc, setExpandedDesc] = useState<{ [key: string]: boolean }>({});

  const fetchData = async (isRefresh = false) => {
    if (isRefresh) {
      setRefreshing(true);
    } else {
      setLoading(true);
    }

    try {
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('category_preferences')
        .eq('id', currentUser?.id)
        .single();

      if (profileError) {
        console.error('Error fetching preferences:', profileError.message);
        return;
      }

      const foodPrefs: string[] = profileData?.category_preferences?.['food_drinks'] || [];

      const { data: foodData, error: foodError } = await supabase
        .from('food_places')
        .select('*')
        .limit(20);

      if (foodError) {
        console.error('Error fetching food places:', foodError.message);
        Alert.alert('Error', 'Failed to load places. Please try again.');
        return;
      }

      const filtered = foodPrefs.length === 0
        ? foodData || []
        : (foodData || []).filter((item) => foodPrefs.includes(item.subtopic));

      const transformed = filtered.map((item) => ({
        ...item,
        image_url: item.image_url?.trim() || null,
        description: item.description || 'No description available',
        hours: item.hours || [],
      }));

      setContentData(transformed);
    } catch (e) {
      console.error('Unexpected error:', e);
      Alert.alert('Error', 'Something went wrong. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    if (currentUser?.id) {
      fetchData();
    }
  }, [currentUser?.id]);

  const onRefresh = () => {
    fetchData(true);
  };

  const toggleSave = async (placeId: string) => {
    try {
      const newSavedPlaces = new Set(savedPlaces);
      if (newSavedPlaces.has(placeId)) {
        newSavedPlaces.delete(placeId);
      } else {
        newSavedPlaces.add(placeId);
      }
      setSavedPlaces(newSavedPlaces);

      // Save to user's profile
      const { error } = await supabase
        .from('profiles')
        .update({ 
          saved_places: Array.from(newSavedPlaces) 
        })
        .eq('id', currentUser?.id);

      if (error) {
        console.error('Error saving place:', error);
      }
    } catch (error) {
      console.error('Error toggling save:', error);
    }
  };

  const handleShare = (place: FoodPlace) => {
    Alert.alert(
      'Share Place',
      `Share ${place.name} with friends?`,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Share', onPress: () => console.log('Share:', place.name) }
      ]
    );
  };

  const toggleDescription = (placeId: string) => {
    setExpandedDesc((prev) => ({ ...prev, [placeId]: !prev[placeId] }));
  };

  const renderItem = ({ item, index }: { item: FoodPlace; index: number }) => {
    const isSaved = savedPlaces.has(item.place_id);
    const imageFailed = erroredImages.has(item.place_id);

    return (
      <StyledView
        className="bg-white rounded-3xl mx-4 mb-6 overflow-hidden"
        style={[
          { 
            height: CARD_HEIGHT,
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 8 },
            shadowOpacity: 0.12,
            shadowRadius: 16,
            elevation: 8,
          }
        ]}
      >
        {/* Image Section */}
        <StyledView className="relative">
          {item.image_url && !imageFailed ? (
            <StyledImage
              source={{ uri: item.image_url }}
              className="w-full h-80"
              resizeMode="cover"
              onError={() => setErroredImages(prev => new Set(prev).add(item.place_id))}
            />
          ) : (
            <StyledView className="w-full h-80 bg-gradient-to-br from-gray-200 to-gray-300 justify-center items-center">
              <Icon name="restaurant" size={48} color="#9CA3AF" />
              <AppText className="text-gray-500 mt-2">No image available</AppText>
            </StyledView>
          )}

          {/* Action Buttons */}
          <StyledView className="absolute top-4 right-4 flex-row space-x-2">
            <StyledTouchableOpacity
              onPress={() => handleShare(item)}
              className="w-10 h-10 bg-white/90 rounded-full items-center justify-center"
              style={{
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.1,
                shadowRadius: 4,
                elevation: 3,
              }}
            >
              <Icon name="share" size={20} color={COLORS.mint} />
            </StyledTouchableOpacity>

            <StyledTouchableOpacity
              onPress={() => toggleSave(item.place_id)}
              className="w-10 h-10 bg-white/90 rounded-full items-center justify-center"
              style={{
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.1,
                shadowRadius: 4,
                elevation: 3,
              }}
            >
              <Icon
                name={isSaved ? 'favorite' : 'favorite-border'}
                size={20}
                color={isSaved ? '#FF5C5C' : COLORS.mint}
              />
            </StyledTouchableOpacity>
          </StyledView>

          {/* Category Badge */}
          <StyledView className="absolute top-4 left-4">
            <StyledView className="bg-white/90 px-3 py-1 rounded-full">
              <AppText className="text-sm text-gray-800">
                {getDisplayNameFromValue(item.subtopic || '')}
              </AppText>
            </StyledView>
          </StyledView>
        </StyledView>

        {/* Content Section */}
        <StyledView className="flex-1 flex-col px-6 pt-4 min-h-0 overflow-hidden">
          <ScrollView
            style={{ flexGrow: 0 }}
            contentContainerStyle={{ paddingBottom: 8 }}
            showsVerticalScrollIndicator={false}
          >
            {/* Title and Rating */}
            <StyledView className="flex-row items-center mb-4">
              <AppText className={`flex-1 mr-2 ${item.name.length > 28 ? 'text-lg' : 'text-2xl'} text-gray-900`}>
                {item.name}
              </AppText>
              <StyledView className="flex-row items-center">
                <Icon name="star" size={16} color="#FFD700" />
                <AppText className="text-sm text-gray-700 ml-1">
                  {item.rating?.toFixed(1) || 'N/A'}
                </AppText>
              </StyledView>
            </StyledView>

            {/* Price Range */}
            {item.price_range && (
              <StyledView className="mb-4">
                <AppText className="text-sm text-gray-600">
                  {getPriceRangeText(item.price_range)}
                </AppText>
              </StyledView>
            )}

            {/* Hours Section */}
            {item.hours.length > 0 && (
              <StyledView className="mb-4">
                <StyledView className="bg-gray-100 rounded-xl px-3 py-2 flex-row items-start">
                  <Icon name="schedule" size={16} color={COLORS.mint} style={{ marginTop: 2 }} />
                  <StyledView className="ml-2 flex-1">
                    {groupHours(item.hours).map((group, idx) => (
                      <AppText key={idx} className="text-sm text-gray-800 mb-1">
                        <AppText className="font-bold">
                          {group.start === group.end
                            ? DAY_SHORT[group.start as keyof typeof DAY_SHORT]
                            : `${DAY_SHORT[group.start as keyof typeof DAY_SHORT]}–${DAY_SHORT[group.end as keyof typeof DAY_SHORT]}`
                          }
                          :
                        </AppText> {group.time}
                      </AppText>
                    ))}
                  </StyledView>
                </StyledView>
              </StyledView>
            )}

            {/* Description */}
            <StyledView className="mb-4">
              <AppText className="text-gray-700 leading-5" numberOfLines={expandedDesc[item.place_id] ? undefined : 3}>
                {item.description}
              </AppText>
              {item.description && item.description.length > 80 && (
                <TouchableOpacity onPress={() => toggleDescription(item.place_id)}>
                  <AppText className="text-mint mt-1 text-sm font-semibold">
                    {expandedDesc[item.place_id] ? 'Show less' : 'Show more'}
                  </AppText>
                </TouchableOpacity>
              )}
            </StyledView>
          </ScrollView>

          {/* Action Buttons */}
          <StyledView className="flex-row space-x-3 mt-auto pb-4">
            <StyledTouchableOpacity
              className="flex-1 bg-gray-100 py-3 rounded-2xl items-center"
              onPress={() => console.log('Get directions to:', item.name)}
            >
              <StyledView className="flex-row items-center">
                <Icon name="directions" size={16} color={COLORS.mint} />
                <AppText className="text-sm text-gray-700 ml-2">
                  Directions
                </AppText>
              </StyledView>
            </StyledTouchableOpacity>

            <StyledTouchableOpacity
              className="flex-1 bg-mint py-3 rounded-2xl items-center"
              onPress={() => console.log('Call:', item.name)}
            >
              <StyledView className="flex-row items-center">
                <Icon name="phone" size={16} color="white" />
                <AppText className="text-sm text-white ml-2">
                  Call
                </AppText>
              </StyledView>
            </StyledTouchableOpacity>
          </StyledView>
        </StyledView>
      </StyledView>
    );
  };

  const renderEmptyState = () => (
    <StyledView className="flex-1 justify-center items-center px-8">
      <Icon name="restaurant" size={80} color={COLORS.mint} />
      <AppText className="text-2xl text-gray-900 mt-4 text-center">
        No places found
      </AppText>
      <AppText className="text-gray-600 text-center mt-2 leading-6">
        We couldn't find any places matching your preferences. Try updating your interests in your profile.
      </AppText>
      <StyledTouchableOpacity
        className="bg-mint px-6 py-3 rounded-2xl mt-6"
        onPress={() => navigation.navigate('ProfileScreen')}
      >
        <AppText className="text-white">Update Preferences</AppText>
      </StyledTouchableOpacity>
    </StyledView>
  );

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar currentUser={currentUser} />

      {loading ? (
        <StyledView className="flex-1 justify-center items-center">
          <ActivityIndicator size="large" color={COLORS.mint} />
          <AppText className="text-mint mt-4 text-lg">
            Finding amazing places for you...
          </AppText>
        </StyledView>
      ) : (
        <FlatList
          data={contentData}
          renderItem={renderItem}
          keyExtractor={(item) => item.place_id}
          pagingEnabled
          snapToInterval={CARD_HEIGHT + 24}
          snapToAlignment="start"
          decelerationRate="fast"
          showsVerticalScrollIndicator={false}
          bounces={true}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              tintColor={COLORS.mint}
              colors={[COLORS.mint]}
            />
          }
          ListEmptyComponent={renderEmptyState}
          contentContainerStyle={{ 
            paddingBottom: 120,
            paddingTop: 20,
          }}
          onMomentumScrollEnd={(event) => {
            const index = Math.round(event.nativeEvent.contentOffset.y / (CARD_HEIGHT + 24));
            setCurrentIndex(index);
          }}
        />
      )}

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
