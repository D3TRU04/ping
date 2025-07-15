// home/feeds/item-card/ItemCard.tsx
import React, { useState } from 'react';
import {
    Alert,
    Dimensions,
    View,
    Image,
    ScrollView,
    TouchableOpacity,
} from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';
import { categories } from '../../../auth/onboarding/data/categories';
import { supabase } from '../../../../../lib/supabase'; 

const StyledView = styled(View);
const StyledImage = styled(Image);
const StyledTouchableOpacity = styled(TouchableOpacity);

const DAY_ORDER = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const DAY_SHORT = {
    'Monday': 'Mon',
    'Tuesday': 'Tue',
    'Wednesday': 'Wed',
    'Thursday': 'Thu',
    'Friday': 'Fri',
    'Saturday': 'Sat',
    'Sunday': 'Sun',
};

function getDisplayNameFromValue(value: string): string {
    for (const cat of categories) {
        const match = cat.subcategories.find(sub => sub.value === value);
        if (match) return match.name;
    }
    return value;
}

function getPriceRangeText(priceRange?: number): string {
    if (!priceRange) return '';
    return '$'.repeat(priceRange);
}

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
        groups.push({
        start: parsed[start].day,
        end: parsed[end].day,
        time: parsed[start].time,
        });
        i = end + 1;
    }
    return groups;
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

    const handleShare = () => {
        Alert.alert(
            'Share Place',
            `Share ${item.name} with friends?`,
            [
                { text: 'Cancel', style: 'cancel' },
                { text: 'Share', onPress: () => console.log('Share:', item.name) }
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

            if (error) return console.error('Error fetching profile:', error.message);

            const liked = data?.liked || [];
            const updatedLiked = liked.includes(item.place_id)
            ? liked.filter((id: string) => id !== item.place_id)
            : [...liked, item.place_id];

            const { error: updateError } = await supabase
            .from('profiles')
            .update({ liked: updatedLiked })
            .eq('id', currentUserId);

            if (updateError) return console.error('Error updating liked places:', updateError.message);

            setLikedPlaces(prev => {
            const updated = new Set(prev);
            updated.has(item.place_id) ? updated.delete(item.place_id) : updated.add(item.place_id);
            return updated;
            });
        } catch (err) {
            console.error('Unexpected error in toggleLike:', err);
        }
        };

        const toggleSave = async () => {
        try {
            const { data, error } = await supabase
            .from('profiles')
            .select('saved')
            .eq('id', currentUserId)
            .single();

            if (error) return console.error('Error fetching saved list:', error.message);

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

            if (updateError) return console.error('Error updating saved:', updateError.message);

            setSavedMap(updatedSaved);

            if (!isAlreadySaved) {
            showToast(); // delegate to parent to animate
            }
        } catch (err) {
            console.error('Unexpected error in toggleSave:', err);
        }
        };

    return (
        <StyledView
        className="bg-white rounded-3xl mx-4 mb-6 overflow-hidden"
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
            <StyledView className="relative">
                {item.image_url && !imageFailed ? (
                <StyledImage
                    source={{ uri: item.image_url }}
                    className="w-full h-80"
                    resizeMode="cover"
                    onError={onImageError}
                />
                ) : (
                <StyledView className="w-full h-80 bg-gradient-to-br from-gray-200 to-gray-300 justify-center items-center">
                    <Icon name="restaurant" size={48} color="#9CA3AF" />
                    <AppText className="text-gray-500 mt-2">No image available</AppText>
                </StyledView>
                )}

                {/* Top Right Buttons */}
                <StyledView className="absolute top-4 right-4 flex-row">
                    <View style={{ marginRight: 4 }}>
                        <IconButton
                            icon={isSaved ? 'bookmark' : 'bookmark-border'}
                            onPress={toggleSave} // ✅ internal handler
                        />
                    </View>
                    <View style={{ marginRight: 4 }}>
                        <IconButton icon="share" onPress={handleShare} />
                    </View>
                    <IconButton
                        icon={isLiked ? 'favorite' : 'favorite-border'}
                        color={isLiked ? '#FF5C5C' : COLORS.mint}
                        onPress={toggleLike} // ✅ internal handler
                    />
                </StyledView>

                {/* Category Badge */}
                <StyledView className="absolute top-4 left-4">
                <StyledView className="bg-white/90 px-3 py-1 rounded-full">
                    <AppText className="text-sm text-gray-800">
                    {getDisplayNameFromValue(item.subtopic || '')}
                    </AppText>
                </StyledView>
                </StyledView>
            </StyledView>

            {/* Info Section */}
            <StyledView className="flex-1 flex-col px-6 pt-4 min-h-0 overflow-hidden">
                <ScrollView
                style={{ flexGrow: 0 }}
                contentContainerStyle={{ paddingBottom: 8 }}
                showsVerticalScrollIndicator={false}
                >
                    <StyledView className="flex-row items-center mb-4">
                        <AppText className={`flex-1 mr-2 ${item.name.length > 28 ? 'text-lg' : 'text-2xl'} text-gray-900`}>
                        {item.name}
                        </AppText>
                        <StyledView className="flex-row items-center">
                            <Icon name="star" size={16} color="#FFD700" />
                            <AppText className="text-sm text-gray-700 ml-1">
                                {item.rating?.toFixed(1) || 'N/A'}
                            </AppText>
                        </StyledView>
                    </StyledView>

                    {!!item.price_range && (
                        <StyledView className="mb-4">
                            <AppText className="text-sm text-gray-600">{getPriceRangeText(item.price_range)}</AppText>
                        </StyledView>
                    )}

                    {item.hours.length > 0 && (
                        <StyledView className="mb-4">
                            <StyledView className="bg-gray-100 rounded-xl px-3 py-2 flex-row items-start">
                                <Icon name="schedule" size={16} color={COLORS.mint} style={{ marginTop: 2 }} />
                                <StyledView className="ml-2 flex-1">
                                {groupHours(item.hours).map((group, idx) => (
                                    <AppText key={idx} className="text-sm text-gray-800 mb-1">
                                        <AppText className="font-bold">
                                            {group.start === group.end
                                            ? DAY_SHORT[group.start as keyof typeof DAY_SHORT]
                                            : `${DAY_SHORT[group.start as keyof typeof DAY_SHORT]}–${DAY_SHORT[group.end as keyof typeof DAY_SHORT]}`
                                            }
                                            :
                                        </AppText> {group.time}
                                    </AppText>
                                ))}
                                </StyledView>
                            </StyledView>
                        </StyledView>
                    )}

                    <StyledView className="mb-4">
                        <AppText className="text-gray-700 leading-5">
                            {item.description}
                        </AppText>
                    </StyledView>
                </ScrollView>

                {/* Footer Buttons */}
                <StyledView className="flex-row space-x-3 mt-auto pb-4">
                    <StyledTouchableOpacity
                        className="flex-1 bg-gray-100 py-3 rounded-2xl items-center"
                        onPress={() => console.log('Get directions to:', item.name)}
                    >
                        <StyledView className="flex-row items-center">
                        <Icon name="directions" size={16} color={COLORS.mint} />
                        <AppText className="text-sm text-gray-700 ml-2">Directions</AppText>
                        </StyledView>
                    </StyledTouchableOpacity>

                    <StyledTouchableOpacity
                        className="flex-1 bg-mint py-3 rounded-2xl items-center"
                        onPress={() => console.log('Call:', item.name)}
                    >
                        <StyledView className="flex-row items-center">
                        <Icon name="phone" size={16} color="white" />
                        <AppText className="text-sm text-white ml-2">Call</AppText>
                        </StyledView>
                    </StyledTouchableOpacity>
                </StyledView>
            </StyledView>
        </StyledView>
    );
}

function IconButton({
    icon,
    onPress,
    color = COLORS.mint,
}: {
    icon: string;
    onPress: () => void;
    color?: string;
}) {
    return (
        <StyledTouchableOpacity
        onPress={onPress}
        className="w-10 h-10 bg-white/90 rounded-full items-center justify-center"
        style={{
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 0.1,
            shadowRadius: 4,
            elevation: 3,
        }}
        >
        <Icon name={icon as any} size={20} color={color} />
        </StyledTouchableOpacity>
    );
}
