import React, { useEffect, useState } from 'react';
import { View, Dimensions } from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';
import SwipeCard from './components/SwipeCard';
import AnimatedStackCard from './components/AnimatedStackCard';
import { COLORS } from '../../../theme/colors';
import { FoodPlace } from '../../../types/FoodPlace';
import { supabase } from '../../../../lib/supabase';

const StyledView = styled(View);

const { height: SCREEN_HEIGHT } = Dimensions.get('window');
const CARD_HEIGHT = Math.round(SCREEN_HEIGHT * 0.60);

type RootStackParamList = {
  Home: undefined;
  MatchmakingScreen: undefined;
};

type NavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

type Props = {
  currentUser: any;
  onFinished?: (recommendedItems: FoodPlace[]) => void;
};

type CardContentProps = { emojis: string; text: string };

function CardContent({ emojis, text }: CardContentProps) {
  return (
    <View className="absolute top-0 left-0 right-0 bottom-0 items-center justify-center px-7 py-6 w-full h-full">
      <AppText className="text-white text-[36px] mb-4 text-center">{emojis}</AppText>
      <AppText className="text-white text-[22px] text-center leading-8">{text}</AppText>
    </View>
  );
}

export default function MatchmakingScreen({ currentUser, onFinished }: Props) {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<any>();

  const questions = [
    { id: 1, text: 'Are you craving spicy food today?', emojis: '🌶️🔥🥵', theme: 'spicy', color: '#FFB6B9' },
    { id: 2, text: 'Looking for something sweet?', emojis: '🍰🍦🍫', theme: 'sweet', color: '#FFD93D' },
    { id: 3, text: 'Want a healthy meal?', emojis: '🥗🥒🥑', theme: 'healthy', color: '#B5EAD7' },
    { id: 4, text: 'Craving something cheesy?', emojis: '🧀🍕🧈', theme: 'cheesy', color: '#C7CEEA' },
    { id: 5, text: 'How about a refreshing drink?', emojis: '🧋🥤🍹', theme: 'drink', color: COLORS.mint },
  ];

  const [cardIndex, setCardIndex] = useState(0);
  const [swipeDirection, setSwipeDirection] = useState<null | 'left' | 'right'>(null);
  const [pendingRemoval, setPendingRemoval] = useState(false);

  const handleSwipeLeft = () => {
    if (!pendingRemoval) {
      setSwipeDirection('left');
      setPendingRemoval(true);
    }
  };

  const handleSwipeRight = () => {
    if (!pendingRemoval) {
      setSwipeDirection('right');
      setPendingRemoval(true);
    }
  };

  const handleSwipedOut = () => {
    setSwipeDirection(null);
    setPendingRemoval(false);
    setCardIndex((prev) => prev + 1);
  };

  const fetchTodayRecommendations = async (): Promise<FoodPlace[]> => {
    try {
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('category_preferences, liked, saved')
        .eq('id', currentUser?.id)
        .single();

      if (profileError) {
        console.error('Error fetching profile data:', profileError.message);
        return [];
      }

      const foodPrefs = profileData?.category_preferences?.['food_drinks'] || [];
      const liked = new Set<string>(profileData?.liked || []);
      const saved = profileData?.saved || {};
      const allSaved = new Set(saved['all_saved'] || []);

      const { data: foodData, error: foodError } = await supabase
        .from('food_places')
        .select('*')
        .limit(20);

      if (foodError) {
        console.error('Error fetching food_places:', foodError.message);
        return [];
      }

      const filtered = (foodData || []).filter(item =>
        (!foodPrefs.length || foodPrefs.includes(item.subtopic)) &&
        !liked.has(item.place_id) &&
        !allSaved.has(item.place_id)
      );

      return filtered.map(item => ({
        ...item,
        image_url: item.image_url?.trim() || null,
        description: item.description || 'No description available',
        hours: item.hours || [],
      }));
    } catch (e) {
      console.error('Unexpected error fetching recommendations:', e);
      return [];
    }
  };

  useEffect(() => {
    if (cardIndex === questions.length) {
      if (onFinished) {
        fetchTodayRecommendations().then(onFinished);
      } else {
        navigation.navigate('Home');
      }
    }
  }, [cardIndex]);

  if (cardIndex === questions.length) return null;

  const current = questions[cardIndex];

  return (
    <StyledView className="flex-1 items-center justify-center bg-[#FAF6F2]">
      <View
        className="w-[85%] flex-1 justify-center items-center"
        style={{ height: CARD_HEIGHT }}
      >
        {questions.slice(cardIndex + 1).map((q, i) => (
          <AnimatedStackCard
            key={q.id}
            top={16 * (i + 1)}
            zIndex={10 - (i + 1)}
            color={q.color}
            height={CARD_HEIGHT}
          >
            <CardContent emojis={q.emojis} text={q.text} />
          </AnimatedStackCard>
        ))}
        <SwipeCard
          key={current.id}
          backgroundColor={current.color}
          swipeDirection={swipeDirection}
          onSwipedOut={handleSwipedOut}
          onSwipeLeft={pendingRemoval ? undefined : handleSwipeLeft}
          onSwipeRight={pendingRemoval ? undefined : handleSwipeRight}
          pendingRemoval={pendingRemoval}
          style={{
            position: 'absolute',
            left: 0,
            width: '100%',
            height: CARD_HEIGHT,
            zIndex: 10,
            borderRadius: 32,
            backgroundColor: current.color,
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 4 },
            shadowOpacity: 0.1,
            shadowRadius: 16,
            elevation: 8,
          }}
        >
          <CardContent emojis={current.emojis} text={current.text} />
        </SwipeCard>
      </View>
    </StyledView>
  );
}
