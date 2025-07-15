// home/today/page.tsx
import React, { useState } from 'react';
import { Alert } from 'react-native';
import { supabase } from '../../../../lib/supabase';
import MatchmakingFlow from './components/MatchmakingFlow';
import FeedView from '../feeds/FeedView';
import { FoodPlace } from '../../../types/FoodPlace';

export default function TodayPage({ currentUser }: { currentUser: any }) {
    const [todayFeedItems, setTodayFeedItems] = useState<FoodPlace[] | null>(null);
    const [loading, setLoading] = useState(false);
    const [refreshing, setRefreshing] = useState(false);
    const [likedPlaces, setLikedPlaces] = useState<Set<string>>(new Set());
    const [savedMap, setSavedMap] = useState<Record<string, string[]>>({});
    const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
    const [currentIndex, setCurrentIndex] = useState(0);

    const fetchData = async (isRefresh = false) => {
        isRefresh ? setRefreshing(true) : setLoading(true);
        try {
        const { data: profileData } = await supabase
            .from('profiles')
            .select('liked, saved')
            .eq('id', currentUser?.id)
            .single();

        const liked = new Set<string>(profileData?.liked || []);
        const saved = profileData?.saved || {};
        const allSaved = new Set(saved['all_saved'] || []);

        setLikedPlaces(liked);
        setSavedMap(saved);

        const { data: foodData } = await supabase
            .from('food_places')
            .select('*')
            .limit(20);

        const filtered = (foodData ?? []).filter(
            item =>
            !liked.has(item.place_id) &&
            !allSaved.has(item.place_id)
        );

        const cleanedItems = filtered.map(item => ({
            ...item,
            image_url: item.image_url?.trim() || null,
            description: item.description || 'No description available',
            hours: item.hours || [],
        }));

        setTodayFeedItems(cleanedItems);
        } catch (e) {
        Alert.alert('Error', 'Something went wrong.');
        } finally {
        setLoading(false);
        setRefreshing(false);
        }
    };

    if (!todayFeedItems) {
        return (
        <MatchmakingFlow
            onFinished={() => {
            fetchData();
            }}
        />
        );
    }

    return (
        <FeedView
        items={todayFeedItems}
        liked={likedPlaces}
        savedMap={savedMap}
        refreshing={refreshing}
        loading={loading}
        onRefresh={() => fetchData(true)}
        erroredImages={erroredImages}
        setErroredImages={setErroredImages}
        setCurrentIndex={setCurrentIndex}
        currentUserId={currentUser?.id}
        setLikedPlaces={setLikedPlaces}
        setSavedMap={setSavedMap}
        />
    );
}
