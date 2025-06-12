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
import { supabase } from '../../lib/supabase';
import { styled } from 'nativewind';
import TopNavBar from '../components/TopNavBar';
import BottomNavBar from '../components/BottomNavBar';

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

const getTodayHours = (hours: string[]) => {
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const today = days[new Date().getDay()];
  const todayLine = hours.find((line) => line.startsWith(today));
  if (!todayLine || todayLine.toLowerCase().includes('closed')) return 'Closed';

  const timeRange = todayLine.split(': ')[1];
  if (!timeRange) return todayLine;

  const [rawOpen, rawClose] = timeRange.split(' – '); // \u2009 narrow space
  const now = new Date();

  const parseTime = (str: string, fallbackAMPM?: string): Date => {
    const ampmMatch = str.match(/(AM|PM)/i);
    let timeStr = str.trim();

    if (!ampmMatch && fallbackAMPM) {
      timeStr += ` ${fallbackAMPM}`; // Add fallback AM/PM
    }

    const [time, modifier] = timeStr.split(/\s+/);
    const [hours, minutes] = time.split(':').map(Number);
    let hrs = hours;
    if (modifier?.toUpperCase() === 'PM' && hours < 12) hrs += 12;
    if (modifier?.toUpperCase() === 'AM' && hours === 12) hrs = 0;
    const parsed = new Date(now);
    parsed.setHours(hrs, minutes || 0, 0, 0);
    return parsed;
  };

  const closeAMPM = rawClose.match(/AM|PM/i)?.[0];
  const openTime = parseTime(rawOpen, closeAMPM);
  const closeTime = parseTime(rawClose);

  const msUntilOpen = openTime.getTime() - now.getTime();
  const msUntilClose = closeTime.getTime() - now.getTime();

  if (msUntilOpen > 0 && msUntilOpen <= 60 * 60 * 1000) {
    return `Opens soon at ${rawOpen}`;
  }

  if (msUntilClose > 0 && msUntilClose <= 60 * 60 * 1000) {
    return `Closes soon at ${rawClose}`;
  }

  if (now >= openTime && now < closeTime) {
    return `Open now, until ${rawClose}`;
  }

  return todayLine;
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

  const CARD_HEIGHT = SCREEN_HEIGHT - insets.top - insets.bottom - 105;

  useEffect(() => {
    async function fetchFoodPlaces() {
      const { data, error } = await supabase
        .from('food_places')
        .select('place_id, name, image_url, description, type_of_food, subtopic, rating, price_range, hours');

      if (error) {
        console.error('Error fetching food places:', error.message);
      } else if (data) {
        const transformed = data.map((item) => ({
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
      }
      setLoading(false);
    }
    fetchFoodPlaces();
  }, []);

  const toggleSave = (placeId: string) => {
    setSavedPlaces((prev) => {
      const updated = new Set(prev);
      if (updated.has(placeId)) {
        updated.delete(placeId);
      } else {
        updated.add(placeId);
      }
      return updated;
    });
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
          <StyledText className="text-lg font-bold text-gray-900 mb-1 text-center font-system">
            {item.name}
          </StyledText>
          <StyledView className="flex-row justify-center gap-2 mb-1">
            {item.subtopic ? (
              <StyledView className="bg-[#FFA726]/20 rounded-full px-2 py-0.5">
                <StyledText className="text-xs text-[#FFA726] font-bold font-system">{item.subtopic}</StyledText>
              </StyledView>
            ) : null}
            {item.type_of_food ? (
              <StyledView className="bg-[#FFA726]/10 rounded-full px-2 py-0.5">
                <StyledText className="text-xs text-[#FFA726] font-system">{item.type_of_food}</StyledText>
              </StyledView>
            ) : null}
          </StyledView>
          <StyledView className="flex-row justify-center gap-2 mb-1">
            <StyledText className="text-xs text-yellow-500 font-bold">{item.rating ? `⭐ ${item.rating.toFixed(1)}` : '⭐ N/A'}</StyledText>
            <StyledText className="text-xs text-gray-500">{item.price_range ? '💲'.repeat(item.price_range) : ''}</StyledText>
          </StyledView>

          <StyledTouchableOpacity
            onPress={() => toggleHours(item.place_id)}
            className="flex-row items-center justify-center gap-2 mt-2 mb-1"
          >
            <Icon name="access-time" size={18} color="gray" />
            <StyledText className="text-xs text-gray-700 font-system">
              {item.hours?.length > 0 ? getTodayHours(item.hours) ?? "Today's hours not found" : 'Hours not available'}
            </StyledText>
          </StyledTouchableOpacity>

          {isExpanded && item.hours?.length > 0 && (
            <StyledView className="mt-1">
              {item.hours.map((line, index) => (
                <StyledText
                  key={index}
                  className="text-xs text-gray-500 text-center font-system"
                >
                  {line}
                </StyledText>
              ))}
            </StyledView>
          )}

          <StyledText className="text-sm text-gray-500 text-center mt-2 font-system">
            {item.description}
          </StyledText>
        </StyledView>
      </StyledView>
    );
  };

  return (
    <StyledSafeAreaView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar currentUser={currentUser} />

      {loading ? (
        <StyledView className="flex-1 justify-center items-center">
          <ActivityIndicator size="large" color="#FFA726" />
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
    </StyledSafeAreaView>
  );
}
