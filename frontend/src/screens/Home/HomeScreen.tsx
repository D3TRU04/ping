// ✅ NEW HomeScreen.tsx with subcategory name-mapping
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  Image,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Dimensions,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useSafeAreaInsets, SafeAreaView } from 'react-native-safe-area-context';
import { supabase } from '../../../lib/supabase';
import { styled } from 'nativewind';
import TopNavBar from '../../components/TopNavBar';
import BottomNavBar from '../../components/BottomNavBar';
import HoursDisplay from './components/HoursDisplay';
import RatingDisplay from './components/RatingDisplay';
import TagDisplay from './components/TagDisplay';
import NameDisplay from './components/NameDisplay';
import DescriptionDisplay from './components/DescriptionDisplay';
import { COLORS } from '../../theme/colors';
import { categories } from '../Auth/onboarding/data'; // 📦 Importing categories config

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);
const StyledSafeAreaView = styled(SafeAreaView);

const ORANGE = '#FFA726';
const FEED_CARD_SHADOW = {
  shadowColor: '#000',
  shadowOffset: { width: 0, height: 2 },
  shadowOpacity: 0.06,
  shadowRadius: 8,
  elevation: 2,
};

const { height: SCREEN_HEIGHT } = Dimensions.get('window');

// 🧭 Navigation type setup
const CARD_HEIGHT = SCREEN_HEIGHT - 95;
type RootStackParamList = {
  Home: undefined;
  Profile: undefined;
  Notifications: undefined;
  Survey: undefined;
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
}

// 🧠 Helper to map stored value (e.g., "Thai & Southeast Asian Cuisine") to display name (e.g., "Thai")
const getDisplayNameFromValue = (value: string): string => {
  for (const cat of categories) {
    const match = cat.subcategories.find(sub => sub.value === value);
    if (match) return match.name;
  }
  return value; // fallback if not found
};

export default function HomeScreen() {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const route = useRoute<any>();
  const currentUser = route?.params?.currentUser;
  const insets = useSafeAreaInsets();

  const [contentData, setContentData] = useState<FoodPlace[]>([]);
  const [loading, setLoading] = useState(true);
  const [savedPlaces, setSavedPlaces] = useState<Set<string>>(new Set());
  const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
  const [expandedHours, setExpandedHours] = useState<Set<string>>(new Set());

  useEffect(() => {
    async function fetchData() {
      setLoading(true);

      try {
        // 📦 Step 1: Get user food subcategory prefs from Supabase
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

        // 📦 Step 2: Get food places
        const { data: foodData, error: foodError } = await supabase
          .from('food_places')
          .select('*');

        if (foodError) {
          console.error('Error fetching food places:', foodError.message);
          return;
        }

        // 🔍 Step 3: Filter by user subcategory values
        const filtered = foodPrefs.length === 0
          ? foodData || []
          : (foodData || []).filter((item) => foodPrefs.includes(item.subtopic));

        // 🧹 Step 4: Clean up
        const transformed = filtered.map((item) => ({
          ...item,
          image_url: item.image_url?.trim() || null,
          description: item.description || ' ',
          hours: item.hours || [],
        }));

        setContentData(transformed);
      } catch (e) {
        console.error('Unexpected error:', e);
      } finally {
        setLoading(false);
      }
    }

    if (currentUser?.id) fetchData();
  }, [currentUser?.id]);

  const toggleSave = (placeId: string) => {
    setSavedPlaces(prev => {
      const updated = new Set(prev);
      updated.has(placeId) ? updated.delete(placeId) : updated.add(placeId);
      return updated;
    });
  };

  const toggleHours = (placeId: string) => {
    setExpandedHours(prev => {
      const updated = new Set(prev);
      updated.has(placeId) ? updated.delete(placeId) : updated.add(placeId);
      return updated;
    });
  };

  const renderItem = ({ item }: { item: FoodPlace }) => {
    const isSaved = savedPlaces.has(item.place_id);
    const isExpanded = expandedHours.has(item.place_id);
    const imageFailed = erroredImages.has(item.place_id);

    return (
      <StyledView
        className="bg-white"
        style={[{ height: CARD_HEIGHT, position: 'relative' }, FEED_CARD_SHADOW]}
      >
        <TouchableOpacity
          onPress={() => toggleSave(item.place_id)}
          style={{
            position: 'absolute',
            top: 12,
            right: 12,
            zIndex: 10,
            backgroundColor: 'white',
            borderRadius: 20,
            padding: 6,
          }}
        >
          <Icon
            name={isSaved ? 'favorite' : 'favorite-border'}
            size={24}
            color={isSaved ? ORANGE : 'gray'}
          />
        </TouchableOpacity>

        {item.image_url && !imageFailed ? (
          <StyledImage
            source={{ uri: item.image_url }}
            className="w-full h-64"
            resizeMode="cover"
            onError={() => setErroredImages(prev => new Set(prev).add(item.place_id))}
          />
        ) : (
          <StyledView className="w-full h-64 bg-gray-200 justify-center items-center">
            <StyledText className="text-sm text-gray-500">Image not available</StyledText>
          </StyledView>
        )}

        <StyledView className="px-4 pt-3 pb-4">
          <NameDisplay name={item.name} />
          <TagDisplay
            subtopic={getDisplayNameFromValue(item.subtopic || '')}
            typeOfFood={item.type_of_food}
          />
          <RatingDisplay rating={item.rating} priceRange={item.price_range} />
          <HoursDisplay isExpanded={isExpanded} hours={item.hours} onToggle={() => toggleHours(item.place_id)} />
          <DescriptionDisplay description={item.description ?? ''} />
        </StyledView>
      </StyledView>
    );
  };

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <StyledView className="flex-1">
        <TopNavBar currentUser={currentUser} />

        {loading ? (
          <StyledView className="flex-1 justify-center items-center">
            <ActivityIndicator size="large" color={COLORS.orange} />
            <StyledText className="text-[#FFA726] mt-2">Loading places...</StyledText>
          </StyledView>
        ) : (
          <FlatList
            data={contentData}
            renderItem={renderItem}
            keyExtractor={(item) => item.place_id}
            pagingEnabled
            snapToInterval={CARD_HEIGHT}
            snapToAlignment="start"
            decelerationRate="fast"
            showsVerticalScrollIndicator={false}
            bounces={false}
            getItemLayout={(_, index) => ({
              length: CARD_HEIGHT,
              offset: CARD_HEIGHT * index,
              index,
            })}
            contentContainerStyle={{ paddingBottom: 120 }}
          />
        )}

        <BottomNavBar currentUser={currentUser} />
      </StyledView>
    </StyledView>
  );
}
