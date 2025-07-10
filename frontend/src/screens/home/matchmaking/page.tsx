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
import { supabase } from '../../../../lib/supabase';
import { styled } from 'nativewind';
import TopNavBar from '../../../components/navbar/Home';
import BottomNavBar from '../../../components/navbar/BottomNavBar';
import SecondaryNavBar, { SecondaryNavBarTab } from '../../../components/navbar/SecondaryNavBar';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';
import { categories } from '../../auth/onboarding/data/categories';
import SwipeCard from '../components/SwipeCard';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);
// const StyledSafeAreaView = styled(SafeAreaView);

const { height: SCREEN_HEIGHT } = Dimensions.get('window');
const CARD_HEIGHT = 420;

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

  // Debug: log cardIndex and current/next
  useEffect(() => {
    console.log('Rendering cardIndex:', cardIndex, 'Current:', questions[cardIndex]?.id, 'Next:', questions[cardIndex + 1]?.id);
    // No return value needed
  }, [cardIndex]);

  const handleSwipeLeft = () => {
    if (!pendingRemoval) {
      console.log('[DEBUG] handleSwipeLeft called. pendingRemoval:', pendingRemoval, 'cardIndex:', cardIndex, 'swipeDirection:', swipeDirection);
      console.log('Swipe left triggered on cardIndex:', cardIndex, 'id:', questions[cardIndex]?.id);
      setSwipeDirection('left');
      setPendingRemoval(true);
    }
  };
  const handleSwipeRight = () => {
    if (!pendingRemoval) {
      console.log('[DEBUG] handleSwipeRight called. pendingRemoval:', pendingRemoval, 'cardIndex:', cardIndex, 'swipeDirection:', swipeDirection);
      console.log('Swipe right triggered on cardIndex:', cardIndex, 'id:', questions[cardIndex]?.id);
      setSwipeDirection('right');
      setPendingRemoval(true);
    }
  };

  const handleSwipedOut = () => {
    console.log('[DEBUG] handleSwipedOut called. cardIndex:', cardIndex, 'swipeDirection:', swipeDirection, 'pendingRemoval:', pendingRemoval);
    console.log('Swiped out animation complete for cardIndex:', cardIndex, 'id:', questions[cardIndex]?.id);
    setSwipeDirection(null);
    setPendingRemoval(false);
    setCardIndex((prev) => prev + 1);
  };

  // Show a message when all questions are done
  if (cardIndex === questions.length) {
    return (
      <StyledView className="flex-1 bg-[#FAF6F2] items-center justify-center">
        <TopNavBar currentUser={currentUser} />
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
      <TopNavBar currentUser={currentUser} />
      <StyledView className="flex-1 items-center justify-center">
        <View className="w-[85%] h-[420px] items-center justify-center relative">
          {/* Render static previews for cards after the top card */}
          {questions.slice(cardIndex + 1).map((q, i) => (
            <View
              key={q.id}
              className="absolute left-0 right-0 rounded-3xl shadow-lg w-full h-[420px]"
              style={{
                top: 16 * (i + 1),
                backgroundColor: q.color,
                zIndex: 10 - (i + 1),
                borderRadius: 32,
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 4 },
                shadowOpacity: 0.10,
                shadowRadius: 16,
                elevation: 8,
              }}
            >
              <CardContent emojis={q.emojis} text={q.text} />
            </View>
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
