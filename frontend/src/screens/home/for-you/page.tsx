import React, { useEffect, useRef, useState } from 'react';
import {
  Animated,
  Easing,
  Alert,
  Dimensions,
  FlatList,
  RefreshControl,
  TouchableOpacity,
  View,
  ActivityIndicator
} from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { supabase } from '../../../../lib/supabase';
import ItemCard from '../feeds/item-card/ItemCard';
import { COLORS } from '../../../theme/colors';
import { categories } from '../../auth/onboarding/data/categories';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

const { height: SCREEN_HEIGHT } = Dimensions.get('window');
const CARD_HEIGHT = SCREEN_HEIGHT * 0.75;

const DAY_ORDER = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const DAY_SHORT = {
  Monday: 'Mon',
  Tuesday: 'Tue',
  Wednesday: 'Wed',
  Thursday: 'Thu',
  Friday: 'Fri',
  Saturday: 'Sat',
  Sunday: 'Sun',
};

function groupHours(hoursArr: string[]) {
  const parsed = hoursArr.map(h => {
    const [day, ...rest] = h.split(':');
    return { day: day.trim(), time: rest.join(':').trim() };
  });
  parsed.sort((a, b) => DAY_ORDER.indexOf(a.day) - DAY_ORDER.indexOf(b.day));

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
    groups.push({ start: parsed[start].day, end: parsed[end].day, time: parsed[start].time });
    i = end + 1;
  }
  return groups;
}

function getDisplayNameFromValue(value: string): string {
  for (const cat of categories) {
    const match = cat.subcategories.find(sub => sub.value === value);
    if (match) return match.name;
  }
  return value;
}

function getPriceRangeText(priceRange?: number): string {
  return priceRange ? '$'.repeat(priceRange) : '';
}

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

export default function ForYouPage({ currentUser }: { currentUser: any }) {
  const [contentData, setContentData] = useState<FoodPlace[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [likedPlaces, setLikedPlaces] = useState<Set<string>>(new Set());
  const [savedMap, setSavedMap] = useState<Record<string, string[]>>({});
  const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
  const [expandedDesc, setExpandedDesc] = useState<{ [key: string]: boolean }>({});
  const [, setCurrentIndex] = useState(0);
  const [showSaveToast, setShowSaveToast] = useState(false);
  const toastTranslateY = useRef(new Animated.Value(100)).current;

  const fetchData = async (isRefresh = false) => {
    isRefresh ? setRefreshing(true) : setLoading(true);
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

        const foodPrefs = profileData?.category_preferences?.['food_drinks'] || [];
        const liked = new Set<string>(profileData?.liked || []);
        const saved = profileData?.saved || {};
        const allSaved = new Set(saved['all_saved'] || []);

        setLikedPlaces(liked);
        setSavedMap(saved);

        const { data: foodData, error: foodError } = await supabase
            .from('food_places')
            .select('*')
            .limit(20);

        if (foodError) {
            console.error('Error fetching food places:', foodError.message);
            Alert.alert('Error', 'Failed to load places. Please try again.');
            return;
        }

        const filtered = (foodData || []).filter(item =>
            (!foodPrefs.length || foodPrefs.includes(item.subtopic)) &&
            !liked.has(item.place_id) &&
            !allSaved.has(item.place_id)
        );

        setContentData(filtered.map(item => ({
            ...item,
            image_url: item.image_url?.trim() || null,
            description: item.description || 'No description available',
            hours: item.hours || [],
        })));
    } catch (e) {
        console.error('Unexpected error:', e);
        Alert.alert('Error', 'Something went wrong. Please try again.');
    } finally {
        setLoading(false);
        setRefreshing(false);
    }
  };

  useEffect(() => {
    if (currentUser?.id) fetchData();
  }, [currentUser?.id]);

  const onRefresh = () => fetchData(true);

  const toggleLike = async (placeId: string) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('liked')
        .eq('id', currentUser?.id)
        .single();

      if (error) return console.error('Error fetching profile:', error.message);

      const liked = data?.liked || [];
      const updatedLiked = liked.includes(placeId)
        ? liked.filter((id: string) => id !== placeId)
        : [...liked, placeId];

      const { error: updateError } = await supabase
        .from('profiles')
        .update({ liked: updatedLiked })
        .eq('id', currentUser?.id);

      if (updateError) return console.error('Error updating liked places:', updateError.message);

      setLikedPlaces(prev => {
        const updated = new Set(prev);
        updated.has(placeId) ? updated.delete(placeId) : updated.add(placeId);
        return updated;
      });
    } catch (err) {
      console.error('Unexpected error in toggleLike:', err);
    }
  };

  const toggleSave = async (placeId: string) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('saved')
        .eq('id', currentUser?.id)
        .single();

      if (error) return console.error('Error fetching saved list:', error.message);

      const currentSaved = data?.saved || {};
      const allSavedList = currentSaved['all_saved'] || [];
      const isAlreadySaved = allSavedList.includes(placeId);
      const updatedList = isAlreadySaved
        ? allSavedList.filter((id: string) => id !== placeId)
        : [...allSavedList, placeId];

      const updatedSaved = { ...currentSaved, all_saved: updatedList };
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ saved: updatedSaved })
        .eq('id', currentUser?.id);

      if (updateError) return console.error('Error updating saved:', updateError.message);

      setSavedMap(updatedSaved);

      if (!isAlreadySaved) {
        setShowSaveToast(true);
        Animated.timing(toastTranslateY, {
          toValue: 0,
          duration: 500,
          easing: Easing.out(Easing.ease),
          useNativeDriver: true,
        }).start();

        setTimeout(() => {
          Animated.timing(toastTranslateY, {
            toValue: 100,
            duration: 500,
            easing: Easing.in(Easing.ease),
            useNativeDriver: true,
          }).start(() => setShowSaveToast(false));
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
    setExpandedDesc(prev => ({ ...prev, [placeId]: !prev[placeId] }));
  };

  const renderItem = ({ item }: { item: FoodPlace; index: number }) => (
    <ItemCard
      item={item}
      isLiked={likedPlaces.has(item.place_id)}
      isSaved={(savedMap['all_saved'] || []).includes(item.place_id)}
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
        onPress={() => console.log('Go to profile')}
      >
        <AppText className="text-white">Update Preferences</AppText>
      </StyledTouchableOpacity>
    </StyledView>
  );

  return (
    <StyledView className="flex-1">
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
          keyExtractor={item => item.place_id}
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
          contentContainerStyle={{ paddingTop: 20, paddingBottom: 120 }}
          onMomentumScrollEnd={event => {
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
    </StyledView>
  );
}
