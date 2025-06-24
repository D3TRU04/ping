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

type RootStackParamList = {
  Home: undefined;
  Profile: undefined;
  Notifications: undefined;
  Survey: undefined;
};

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

type FoodPlace = {
  place_id: string;
  name: string;
  image_url?: string;
  description?: string;
  type_of_food?: string;
  subtopic?: string;
  rating?: number;
  price_range?: number;
  hours: string[];
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

  const CARD_HEIGHT = SCREEN_HEIGHT - insets.top - insets.bottom - 95;

  useEffect(() => {
    async function fetchFeed() {
      setLoading(true);

      const {
        data: { user },
        error: userError,
      } = await supabase.auth.getUser();

      if (userError || !user) {
        console.error('Error getting user:', userError?.message);
        setLoading(false);
        return;
      }

      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('saved')
        .eq('id', user.id)
        .single();

      if (profileError) {
        console.error('Error fetching profile:', profileError.message);
        setLoading(false);
        return;
      }

      const saved = new Set(profileData?.saved || []);
      setSavedPlaces(saved); // So heart buttons still work

      const { data: allPlaces, error: placesError } = await supabase
        .from('food_places')
        .select('place_id, name, image_url, description, type_of_food, subtopic, rating, price_range, hours');

      if (placesError) {
        console.error('Error fetching food places:', placesError.message);
        setLoading(false);
        return;
      }

      // Filter out saved places
      const filtered = allPlaces.filter((item) => !saved.has(item.place_id));

      const transformed = filtered.map((item) => ({
        place_id: item.place_id,
        name: item.name,
        image_url: item.image_url?.trim() || null,
        description: item.description || ' ',
        type_of_food: item.type_of_food || '',
        subtopic: item.subtopic || '',
        rating: item.rating || null,
        price_range: item.price_range || null,
        hours: item.hours || [],
      }));

      setContentData(transformed);
      setLoading(false);
    }

    fetchFeed();
  }, []);

  const toggleSave = async (placeId: string) => {
  try {
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      console.error('Error getting user:', userError?.message);
      return;
    }

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('saved')
      .eq('id', user.id)
      .single();

    if (profileError) {
      console.error('Error fetching profile:', profileError.message);
      return;
    }

    const currentSaved: string[] = profileData?.saved || [];

    const updatedSaved = currentSaved.includes(placeId)
      ? currentSaved.filter((id) => id !== placeId)
      : [...currentSaved, placeId];

    const { error: updateError } = await supabase
      .from('profiles')
      .update({ saved: updatedSaved })
      .eq('id', user.id);

    if (updateError) {
      console.error('Error updating saved list:', updateError.message);
      return;
    }

    // Reflect changes locally for UI
    setSavedPlaces((prev) => {
      const updated = new Set(prev);
      if (updated.has(placeId)) {
        updated.delete(placeId);
      } else {
        updated.add(placeId);
      }
      return updated;
    });
  } catch (err) {
    console.error('Unexpected error in toggleSave:', err);
  }
};

  const toggleHours = (placeId: string) => {
    setExpandedHours((prev) => {
      const updated = new Set(prev);
      if (updated.has(placeId)) {
        updated.delete(placeId);
      } else {
        updated.add(placeId);
      }
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
        {/* Save button */}
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

        {/* Image or fallback */}
        {item.image_url && !imageFailed ? (
          <StyledImage
            source={{ uri: item.image_url }}
            className="w-full h-64"
            resizeMode="cover"
            onError={() =>
              setErroredImages((prev) => new Set(prev).add(item.place_id))
            }
          />
        ) : (
          <StyledView className="w-full h-64 bg-gray-200 justify-center items-center">
            <StyledText className="text-sm text-gray-500 font-system">Image not available</StyledText>
          </StyledView>
        )}

        {/* Details */}
        <StyledView className="px-4 pt-3 pb-4">
          <NameDisplay 
            name={item.name} 
          />
          <TagDisplay
            subtopic={item.subtopic}
            typeOfFood={item.type_of_food}
          />
          <RatingDisplay
            rating={item.rating}
            priceRange={item.price_range}
          />
          <HoursDisplay
            isExpanded={isExpanded}
            hours={item.hours}
            onToggle={() => toggleHours(item.place_id)}
          />
          <DescriptionDisplay 
            description={item.description ?? ''}
          />
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
