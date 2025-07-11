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
  Animated,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useSafeAreaInsets, SafeAreaView } from 'react-native-safe-area-context';
import { supabase } from '../../../../lib/supabase';
import { styled } from 'nativewind';
import TopNavBar from '../../../components/navbar/Matchmaking';
import BottomNavBar from '../../../components/navbar/BottomNavBar';
import SecondaryNavBar, { SecondaryNavBarTab } from '../../../components/navbar/SecondaryNavBar';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';
import { categories } from '../../auth/onboarding/data/categories';
import SwipeCard from '../components/SwipeCard';
import AnimatedStackCard from '../components/AnimatedStackCard';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);
// const StyledSafeAreaView = styled(SafeAreaView);

const { height: SCREEN_HEIGHT } = Dimensions.get('window');
const CARD_HEIGHT = Math.round(SCREEN_HEIGHT * 0.7); // Increased card height

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

// Add CardContent component for consistent card UI
type CardContentProps = { emojis: string; text: string };
function CardContent({ emojis, text }: CardContentProps) {
  return (
    <View className="absolute top-0 left-0 right-0 bottom-0 items-center justify-center px-7 py-6 w-full h-full">
      <AppText className="text-white text-[36px] mb-4 text-center">{emojis}</AppText>
      <AppText className="text-white text-[22px] text-center leading-8">{text}</AppText>
    </View>
  );
}

export default function MatchmakingScreen() {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const route = useRoute<any>();
  const currentUser = route?.params?.currentUser;

  // Themed question cards
  const questions = [
    {
      id: 1,
      text: 'Are you craving spicy food today?',
      emojis: '🌶️🔥🥵',
      theme: 'spicy',
      color: '#FFB6B9', // light red
    },
    {
      id: 2,
      text: 'Looking for something sweet?',
      emojis: '🍰🍦🍫',
      theme: 'sweet',
      color: '#FFD93D', // yellow
    },
    {
      id: 3,
      text: 'Want a healthy meal?',
      emojis: '🥗🥒🥑',
      theme: 'healthy',
      color: '#B5EAD7', // mint/green
    },
    {
      id: 4,
      text: 'Craving something cheesy?',
      emojis: '🧀🍕🧈',
      theme: 'cheesy',
      color: '#C7CEEA', // light purple
    },
    {
      id: 5,
      text: 'How about a refreshing drink?',
      emojis: '🧋🥤🍹',
      theme: 'drink',
      color: COLORS.mint,
    },
  ];

  const [cardIndex, setCardIndex] = React.useState(0);
  const [swipeDirection, setSwipeDirection] = React.useState<null | 'left' | 'right'>(null);
  const [pendingRemoval, setPendingRemoval] = React.useState(false);
  const endMessageShown = React.useRef(false);

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

  // Show a message when all questions are done
  if (cardIndex === questions.length) {
    return (
      <StyledView className="flex-1 bg-[#FAF6F2] items-center justify-center">
        <TopNavBar onRefresh={() => setCardIndex(0)} />
        <AppText style={{ fontSize: 28, color: COLORS.text, marginTop: 60, textAlign: 'center' }}>
          Thanks for answering!
        </AppText>
      </StyledView>
    );
  }

  // Show the current card (and next card for stack effect)
  const current = questions[cardIndex];
  const next = questions[cardIndex + 1];

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar onRefresh={() => setCardIndex(0)} />
      <StyledView className="flex-1 items-center justify-center">
        <View className={`w-[85%] flex-1 justify-center items-center`} style={{ height: CARD_HEIGHT, display: 'flex', marginTop: 32 }}>
          {/* Render static previews for cards after the top card */}
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
          {/* Render the top swipeable card */}
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
              shadowOpacity: 0.10,
              shadowRadius: 16,
              elevation: 8,
            }}
          >
            <CardContent emojis={current.emojis} text={current.text} />
          </SwipeCard>
        </View>
      </StyledView>
    </StyledView>
  );
}
