// home/feeds/item-card/ItemCard.tsx
import React, { useState } from 'react';
import {
    Alert,
    Dimensions,
    View,
} from 'react-native';
import { styled } from 'nativewind';
import { supabase } from '../../../../../lib/supabase'; 
import ImageSection from './components/ImageSection';
import InfoSection from './components/InfoSection';

const StyledView = styled(View);

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

interface ItemCardProps {
    item: FoodPlace;
    isLiked: boolean;
    isSaved: boolean;
    onImageError: () => void;
    imageFailed: boolean;

    currentUserId: string;
    setLikedPlaces: React.Dispatch<React.SetStateAction<Set<string>>>;
    setSavedMap: React.Dispatch<React.SetStateAction<Record<string, string[]>>>;
    showToast: () => void;
}

export default function ItemCard({
    item,
    isLiked,
    isSaved,
    onImageError,
    imageFailed,
    currentUserId,
    setLikedPlaces,
    setSavedMap,
    showToast,
}: ItemCardProps) {
    const CARD_HEIGHT = Dimensions.get('window').height * 0.70;
    const [expandedHours, setExpandedHours] = useState(false);

    const handleShare = () => {
        Alert.alert(
            'Share Place',
            `Share ${item.name} with friends?`,
            [
                { text: 'Cancel', style: 'cancel' },
                { text: 'Share', onPress: () => {} }
            ]
        );
    };

    const toggleLike = async () => {
        try {
            const { data, error } = await supabase
            .from('profiles')
            .select('liked')
            .eq('id', currentUserId)
            .single();

            if (error) {
                // Handle error silently
                return;
            }

            const liked = data?.liked || [];
            const updatedLiked = liked.includes(item.place_id)
            ? liked.filter((id: string) => id !== item.place_id)
            : [...liked, item.place_id];

            const { error: updateError } = await supabase
            .from('profiles')
            .update({ liked: updatedLiked })
            .eq('id', currentUserId);

            if (updateError) {
                // Handle error silently
                return;
            }

            setLikedPlaces(prev => {
            const updated = new Set(prev);
            updated.has(item.place_id) ? updated.delete(item.place_id) : updated.add(item.place_id);
            return updated;
            });
        } catch (err) {
            // console.error('Unexpected error in toggleLike:', err);
        }
    };

    const toggleSave = async () => {
        try {
            const { data, error } = await supabase
            .from('profiles')
            .select('saved')
            .eq('id', currentUserId)
            .single();

            if (error) {
                // Handle error silently
                return;
            }

            const currentSaved = data?.saved || {};
            const allSavedList = currentSaved['all_saved'] || [];
            const isAlreadySaved = allSavedList.includes(item.place_id);
            const updatedList = isAlreadySaved
            ? allSavedList.filter((id: string) => id !== item.place_id)
            : [...allSavedList, item.place_id];

            const updatedSaved = { ...currentSaved, all_saved: updatedList };

            const { error: updateError } = await supabase
            .from('profiles')
            .update({ saved: updatedSaved })
            .eq('id', currentUserId);

            if (updateError) {
                // Handle error silently
                return;
            }

            setSavedMap(updatedSaved);

            if (!isAlreadySaved) {
                showToast(); // delegate to parent to animate
            }
        } catch (err) {
            // console.error('Unexpected error in toggleSave:', err);
        }
    };

    return (
        <StyledView
        className="bg-white rounded-3xl mx-3 mb-6 overflow-hidden"
        style={{
            height: CARD_HEIGHT,
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 8 },
            shadowOpacity: 0.12,
            shadowRadius: 16,
            elevation: 8,
        }}
        >
            {/* Image Section */}
            <ImageSection
                imageUrl={item.image_url}
                imageFailed={imageFailed}
                onImageError={onImageError}
                subtopic={item.subtopic}
                isLiked={isLiked}
                isSaved={isSaved}
                onLike={toggleLike}
                onSave={toggleSave}
                onShare={handleShare}
            />

            {/* Info Section */}
            <InfoSection
                name={item.name}
                rating={item.rating}
                priceRange={item.price_range}
                hours={item.hours}
                description={item.description}
                expandedHours={expandedHours}
                onToggleHours={() => setExpandedHours(prev => !prev)}
                onDirections={() => {}}
                onCall={() => {}}
            />
        </StyledView>
    );
};
