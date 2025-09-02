// home/today/page.tsx
import React, { useEffect, useRef, useState } from 'react';
import { Alert } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { supabase } from '../../../../lib/supabase';
import FeedView from '../feeds/FeedView';
import { FoodPlace } from '../../../types/FoodPlace';
import MatchmakingFlow from './components/MatchmakingFlow';

const RECENTLY_SHOWN_STORAGE_KEY = 'recentlyShownPlaceIds';
const MAX_RECENTLY_SHOWN = 500;
const FETCH_LIMIT_PER_TYPE = 2;

export default function TodayPage({ currentUser }: { currentUser: any }) {
    const [todayFeedItems, setTodayFeedItems] = useState<FoodPlace[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [likedPlaces, setLikedPlaces] = useState<Set<string>>(new Set());
    const [savedMap, setSavedMap] = useState<Record<string, string[]>>({});
    const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
    const [currentIndex, setCurrentIndex] = useState(0);

    const recentlyShownSet = useRef<Set<string>>(new Set());

    const loadRecentlyShownFromStorage = async () => {
        const stored = await AsyncStorage.getItem(RECENTLY_SHOWN_STORAGE_KEY);
        if (stored) {
        recentlyShownSet.current = new Set(JSON.parse(stored));
        }
    };

    const saveRecentlyShownToStorage = async () => {
        const trimmed = Array.from(recentlyShownSet.current).slice(-MAX_RECENTLY_SHOWN);
        await AsyncStorage.setItem(RECENTLY_SHOWN_STORAGE_KEY, JSON.stringify(trimmed));
    };

    const fetchData = async (isRefresh = false) => {
        isRefresh ? setRefreshing(true) : setLoading(true);

        try {
        const { data: profileData } = await supabase
            .from('profiles')
            .select('category_preferences, liked, saved')
            .eq('id', currentUser?.id)
            .single();

        const categoryPrefs = profileData?.category_preferences || {};
        const liked = new Set<string>(profileData?.liked || []);
        const saved = profileData?.saved || {};
        const allSaved = new Set(saved['all_saved'] || []);

        setLikedPlaces(liked);
        setSavedMap(saved);

        const fetchedItems: FoodPlace[] = [];

        for (const [tableName, subcategories] of Object.entries(categoryPrefs)) {
            const subcategoryColumn = `${tableName}_subcategory`;

            for (const subcategory of subcategories as string[]) {
            const { data, error } = await supabase
                .from(tableName)
                .select('*')
                .ilike(subcategoryColumn, subcategory)
                .order('place_id', { ascending: true })
                .range(0, FETCH_LIMIT_PER_TYPE - 1); // hardcoded range for now

            if (error || !data) continue;

            const filtered = data.filter(
                (item) =>
                !liked.has(item.place_id) &&
                !allSaved.has(item.place_id) &&
                !recentlyShownSet.current.has(item.place_id)
            );

            for (const item of filtered) {
                recentlyShownSet.current.add(item.place_id);
            }

            fetchedItems.push(
                ...filtered.map((item) => ({
                ...item,
                image_url: item.image_url?.trim() || null,
                description: item.description || 'No description available',
                hours: item.hours || [],
                // Map coordinate fields - use lat/lng if available, fallback to latitude/longitude
                longitude: item.lng || item.longitude || 0,
                latitude: item.lat || item.latitude || 0,
                }))
            );
            }
        }

        await saveRecentlyShownToStorage();
        setTodayFeedItems(fetchedItems);
        } catch (e) {
        Alert.alert('Error', 'Something went wrong.');
        } finally {
        setLoading(false);
        setRefreshing(false);
        }
    };

    useEffect(() => {
        if (!currentUser?.id) return;
        loadRecentlyShownFromStorage().then(() => {
        fetchData();
        });
    }, [currentUser?.id]);

    if (!todayFeedItems || todayFeedItems.length === 0) {
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
        preloading={false} // not needed for now
        onRefresh={() => {
            recentlyShownSet.current.clear();
            AsyncStorage.removeItem(RECENTLY_SHOWN_STORAGE_KEY);
            fetchData(true);
        }}
        erroredImages={erroredImages}
        setErroredImages={setErroredImages}
        setCurrentIndex={setCurrentIndex}
        currentUserId={currentUser?.id}
        setLikedPlaces={setLikedPlaces}
        setSavedMap={setSavedMap}
        />
    );
}
