// home/feeds/FeedView.tsx
import React from 'react';
import { View, TouchableOpacity, FlatList, RefreshControl } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import ItemCard from './item-card/ItemCard';
import { COLORS } from '../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

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
    preloading: boolean;
    onRefresh: () => void;
    erroredImages: Set<string>;
    setErroredImages: React.Dispatch<React.SetStateAction<Set<string>>>;
    setCurrentIndex: (index: number) => void;
    currentUserId: string;
    setLikedPlaces: React.Dispatch<React.SetStateAction<Set<string>>>;
    setSavedMap: React.Dispatch<React.SetStateAction<Record<string, string[]>>>;
}

export default function FeedView({
    items,
    liked,
    savedMap,
    refreshing,
    loading,
    preloading,
    onRefresh,
    erroredImages,
    setErroredImages,
    setCurrentIndex,
    currentUserId,
    setLikedPlaces,
    setSavedMap,
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
            showToast={() => {}}
        />
    );

    const renderEmptyState = () => (
        <StyledView className="flex-1 justify-center items-center px-8 py-20">
            <Icon name="restaurant" size={80} color={COLORS.mint} />
            <AppText className="text-xl text-gray-900 mt-4 text-center font-semibold">
                No places found
            </AppText>
            <AppText className="text-gray-600 text-center mt-2 leading-6">
                We couldn't find any places matching your preferences. Try updating your interests in your profile.
            </AppText>
            <StyledTouchableOpacity
                onPress={() => {}}
                className="bg-mint px-6 py-3 rounded-2xl mt-6"
            >
                <AppText className="text-white font-semibold">Update Preferences</AppText>
            </StyledTouchableOpacity>
        </StyledView>
    );

    if (loading) {
        return (
            <StyledView className="flex-1 justify-center items-center">
                <AppText className="text-mint mt-4 text-lg">
                    Finding amazing places for you...
                </AppText>
            </StyledView>
        );
    }

    if (!items || items.length === 0) {
        return renderEmptyState();
    }

    return (
        <FlatList
            data={items}
            renderItem={renderItem}
            keyExtractor={item => item.place_id}
            showsVerticalScrollIndicator={false}
            refreshControl={
                <RefreshControl
                    refreshing={refreshing}
                    onRefresh={onRefresh}
                    tintColor={COLORS.mint}
                    colors={[COLORS.mint]}
                />
            }
            contentContainerStyle={{ 
                paddingVertical: 16,
                paddingBottom: 120 
            }}
        />
    );
}
