import React, { useEffect, useRef, useState } from 'react';
import { Alert, Animated, Easing } from 'react-native';
import { supabase } from '../../../../lib/supabase';
import FeedView from '../feeds/FeedView';
import { FoodPlace } from '../../../types/FoodPlace';
import { categories } from '../../auth/onboarding/data/categories';

export default function ForYouPage({ currentUser }: { currentUser: any }) {
    const [contentData, setContentData] = useState<FoodPlace[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [likedPlaces, setLikedPlaces] = useState<Set<string>>(new Set());
    const [savedMap, setSavedMap] = useState<Record<string, string[]>>({});
    const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
    const [expandedDesc, setExpandedDesc] = useState<{ [key: string]: boolean }>({});
    const [currentIndex, setCurrentIndex] = useState(0);
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

    const showToast = () => {
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

    return (
        <FeedView
        items={contentData}
        liked={likedPlaces}
        savedMap={savedMap}
        refreshing={refreshing}
        loading={loading}
        onRefresh={onRefresh}
        onShare={handleShare}
        expandedDesc={expandedDesc}
        toggleDescription={toggleDescription}
        erroredImages={erroredImages}
        setErroredImages={setErroredImages}
        showSaveToast={showSaveToast}
        toastTranslateY={toastTranslateY}
        setCurrentIndex={setCurrentIndex}
        currentUserId={currentUser?.id}
        setLikedPlaces={setLikedPlaces}
        setSavedMap={setSavedMap}
        showToast={showToast}
        />
    );
}
