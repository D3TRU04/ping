import React, { useState, useEffect, useRef } from 'react';
import {
  Animated,
  Easing,
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
import SecondaryNavBar, { SecondaryNavBarTab } from '../../components/navbar/SecondaryNavBar';
import AppText from '../../components/AppText';
import ItemCard from './feeds/item-card/ItemCard';
import { COLORS } from '../../theme/colors';
import { categories } from '../auth/onboarding/data/categories';

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
  Settings: undefined;
  SearchUsersScreen: undefined;
  OtherUserProfileScreen: { userId: string };
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
  const [likedPlaces, setLikedPlaces] = useState<Set<string>>(new Set());
  const [savedMap, setSavedMap] = useState<Record<string, string[]>>({});
  const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
  const [, setCurrentIndex] = useState(0);
  const [expandedDesc, setExpandedDesc] = useState<{ [key: string]: boolean }>({});
  const [activeTab, setActiveTab] = useState<SecondaryNavBarTab>('forYou');
  const [showSaveToast, setShowSaveToast] = useState(false);
  const toastTranslateY = useRef(new Animated.Value(100)).current; // start off-screen

  const handleTabChange = (tab: SecondaryNavBarTab) => {
    setActiveTab(tab);
    // TODO: Implement different data fetching logic based on tab
    console.log('Tab changed to:', tab);
  };

  const fetchData = async (isRefresh = false) => {
    if (isRefresh) {
      setRefreshing(true);
    } else {
      setLoading(true);
    }

    try {
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('category_preferences, liked, saved')
        .eq('id', currentUser?.id)
        .single();

      if (profileError) {
        console.error('Error fetching preferences:', profileError.message);
        return;
      }

      const foodPrefs: string[] = profileData?.category_preferences?.['food_drinks'] || [];
      const liked: Set<string> = new Set(profileData?.liked || []);
      setLikedPlaces(liked); // update local state

      const saved: Record<string, string[]> = profileData?.saved || {};
      const allSaved = new Set(saved["all_saved"] || []);
      setSavedMap(saved); // update local state

      const { data: foodData, error: foodError } = await supabase
        .from('food_places')
        .select('*')
        .limit(20);

      if (foodError) {
        console.error('Error fetching food places:', foodError.message);
        Alert.alert('Error', 'Failed to load places. Please try again.');
        return;
      }

      const filtered = (foodData || []).filter((item) =>
        (!foodPrefs.length || foodPrefs.includes(item.subtopic)) &&
        !liked.has(item.place_id) &&
        !allSaved.has(item.place_id)
      );

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

  const toggleLike = async (placeId: string) => {
    try {
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('liked')
        .eq('id', currentUser?.id)
        .single();

      if (profileError) {
        console.error('Error fetching profile:', profileError.message);
        return;
      }

      const currentLiked: string[] = profileData?.liked || [];

      const updatedLiked = currentLiked.includes(placeId)
        ? currentLiked.filter((id) => id !== placeId)
        : [...currentLiked, placeId];

      const { error: updateError } = await supabase
        .from('profiles')
        .update({ liked: updatedLiked })
        .eq('id', currentUser?.id);

      if (updateError) {
        console.error('Error updating liked places:', updateError.message);
        return;
      }

      setLikedPlaces((prev) => {
        const updated = new Set(prev);
        if (updated.has(placeId)) {
          updated.delete(placeId);
        } else {
          updated.add(placeId);
        }
        return updated;
      });
    } catch (err) {
      console.error('Unexpected error in toggleLike:', err);
    }
  };

  const toggleSave = async (placeId: string) => {
    try {
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('saved')
        .eq('id', currentUser?.id)
        .single();

      if (profileError) {
        console.error('Error fetching saved list:', profileError.message);
        return;
      }

      const currentSaved = profileData?.saved || {};
      const allSavedList: string[] = currentSaved["all_saved"] || [];

      const isAlreadySaved = allSavedList.includes(placeId);

      const updatedList = isAlreadySaved
        ? allSavedList.filter(id => id !== placeId)  // unsave
        : [...allSavedList, placeId];               // save

      const updatedSaved = {
        ...currentSaved,
        all_saved: updatedList
      };

      const { error: updateError } = await supabase
        .from('profiles')
        .update({ saved: updatedSaved })
        .eq('id', currentUser?.id);

      if (updateError) {
        console.error('Error updating saved:', updateError.message);
        return;
      }

      setSavedMap(updatedSaved);

      // ✅ Only show toast if this was a *save* operation
      if (!isAlreadySaved) {
        setShowSaveToast(true);

        // Slide in
        Animated.timing(toastTranslateY, {
          toValue: 0,
          duration: 500,
          easing: Easing.out(Easing.ease),
          useNativeDriver: true,
        }).start();

        // After 3 seconds, slide out and then hide
        setTimeout(() => {
          Animated.timing(toastTranslateY, {
            toValue: 100,
            duration: 500,
            easing: Easing.in(Easing.ease),
            useNativeDriver: true,
          }).start(() => setShowSaveToast(false)); // hide toast after animation
        }, 3000);
      }

    } catch (err) {
      console.error('Unexpected error in toggleSave:', err);
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

  const renderItem = ({ item }: { item: FoodPlace; index: number }) => (
    <ItemCard
      item={item}
      isLiked={likedPlaces.has(item.place_id)}
      isSaved={(savedMap["all_saved"] || []).includes(item.place_id)}
      expanded={expandedDesc[item.place_id]}
      onLike={() => toggleLike(item.place_id)}
      onSave={() => toggleSave(item.place_id)}
      onShare={() => handleShare(item)}
      onToggleDescription={() => toggleDescription(item.place_id)}
      onImageError={() => setErroredImages(prev => new Set(prev).add(item.place_id))}
      imageFailed={erroredImages.has(item.place_id)}
    />
  );

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
      <SecondaryNavBar activeTab={activeTab} onTabChange={handleTabChange} />

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

      {showSaveToast && (
        <Animated.View
          className="absolute bottom-20 left-4 right-4 bg-white px-4 py-3 rounded-xl flex-row justify-between items-center"
          style={{
            transform: [{ translateY: toastTranslateY }],
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 4 },
            shadowOpacity: 0.1,
            shadowRadius: 8,
            elevation: 5,
          }}
        >
          <AppText className="text-green-700 font-semibold">✓ Saved</AppText>
          <TouchableOpacity onPress={() => console.log('Manage tapped')}>
            <AppText className="text-mint font-semibold">Manage &gt;</AppText>
          </TouchableOpacity>
        </Animated.View>
      )}

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
