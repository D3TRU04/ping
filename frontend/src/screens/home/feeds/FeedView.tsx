import React, { useRef } from 'react';
import {
  Animated,
  FlatList,
  RefreshControl,
  TouchableOpacity,
  View,
  Dimensions
} from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import ItemCard from './item-card/ItemCard';
import { COLORS } from '../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

const { height: SCREEN_HEIGHT } = Dimensions.get('window');
const CARD_HEIGHT = SCREEN_HEIGHT * 0.75;

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

interface FeedViewProps {
    items: FoodPlace[];
    liked: Set<string>;
    savedMap: Record<string, string[]>;
    refreshing: boolean;
    loading: boolean;
    onRefresh: () => void;
    erroredImages: Set<string>;
    setErroredImages: React.Dispatch<React.SetStateAction<Set<string>>>;
    showSaveToast: boolean;
    toastTranslateY: Animated.Value;
    setCurrentIndex: (index: number) => void;
    currentUserId: string;
    setLikedPlaces: React.Dispatch<React.SetStateAction<Set<string>>>;
    setSavedMap: React.Dispatch<React.SetStateAction<Record<string, string[]>>>;
    showToast: () => void;
}

export default function FeedView({
    items,
    liked,
    savedMap,
    refreshing,
    loading,
    onRefresh,
    erroredImages,
    setErroredImages,
    showSaveToast,
    toastTranslateY,
    setCurrentIndex,
    currentUserId,
    setLikedPlaces,
    setSavedMap,
    showToast,
}: FeedViewProps) {
    const renderItem = ({ item }: { item: FoodPlace }) => (
        <ItemCard
            item={item}
            isLiked={liked.has(item.place_id)}
            isSaved={(savedMap['all_saved'] || []).includes(item.place_id)}
            onImageError={() => setErroredImages(prev => new Set(prev).add(item.place_id))}
            imageFailed={erroredImages.has(item.place_id)}
            currentUserId={currentUserId}
            setLikedPlaces={setLikedPlaces}
            setSavedMap={setSavedMap}
            showToast={showToast}
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
            <AppText className="text-mint mt-4 text-lg">
                Finding amazing places for you...
            </AppText>
            </StyledView>
        ) : (
            <FlatList
            data={items}
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
