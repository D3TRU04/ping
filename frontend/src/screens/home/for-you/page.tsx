// home/for-you/page.tsx
import React, { useEffect, useRef, useState } from 'react';
import { Alert } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { supabase } from '../../../../lib/supabase';
import FeedView from '../feeds/FeedView';
import { FoodPlace } from '../../../types/FoodPlace';

const RECENTLY_SHOWN_STORAGE_KEY = 'recentlyShownPlaceIds';
const MAX_RECENTLY_SHOWN = 500;
const FETCH_LIMIT_PER_TYPE = 2;
const THRESHOLD_PRELOAD = 6;

export default function ForYouPage({ currentUser }: { currentUser: any }) {
    const [contentData, setContentData] = useState<FoodPlace[]>([]);
    const [loading, setLoading] = useState(true);        // full-screen spinner
    const [refreshing, setRefreshing] = useState(false); // pull-to-refresh
    const [preloading, setPreloading] = useState(false); // background scroll-load

    const [likedPlaces, setLikedPlaces] = useState<Set<string>>(new Set());
    const [savedMap, setSavedMap] = useState<Record<string, string[]>>({});
    const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
    const [currentIndex, setCurrentIndex] = useState(0);

    const recentlyShownSet = useRef<Set<string>>(new Set());
    const subcategoryOffsets = useRef<Record<string, number>>({});

    const loadRecentlyShownFromStorage = async () => {
        const stored = await AsyncStorage.getItem(RECENTLY_SHOWN_STORAGE_KEY);
        if (stored) {
        recentlyShownSet.current = new Set(JSON.parse(stored));
        }
    };

    const shuffleArray = <T,>(array: T[]): T[] => {
        const copy = [...array];
        for (let i = copy.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [copy[i], copy[j]] = [copy[j], copy[i]];
        }
        return copy;
    };

    const saveRecentlyShownToStorage = async () => {
        const trimmed = Array.from(recentlyShownSet.current).slice(-MAX_RECENTLY_SHOWN);
        await AsyncStorage.setItem(RECENTLY_SHOWN_STORAGE_KEY, JSON.stringify(trimmed));
    };

    const fetchData = async (mode: 'init' | 'refresh' | 'preload' = 'init') => {
        if (mode === 'refresh') setRefreshing(true);
        else if (mode === 'preload') setPreloading(true);
        else setLoading(true);

        try {
        const { data: profileData, error: profileError } = await supabase
            .from('profiles')
            .select('category_preferences, liked, saved')
            .eq('id', currentUser?.id)
            .single();

        if (profileError || !profileData) {
            Alert.alert('Error', 'Unable to fetch user profile.');
            return;
        }

        const categoryPrefs = profileData.category_preferences || {};
        const liked = new Set<string>(profileData.liked || []);
        const saved = profileData.saved || {};
        const allSaved = new Set(saved['all_saved'] || []);

        setLikedPlaces(liked);
        setSavedMap(saved);

        const fetchedItems: FoodPlace[] = [];

        for (const [tableName, subcategories] of Object.entries(categoryPrefs)) {
            const subcategoryColumn = `${tableName}_subcategory`;

            for (const subcategory of subcategories as string[]) {
            const offsetKey = `${tableName}:${subcategory}`;
            const offset = subcategoryOffsets.current[offsetKey] ?? 0;

            const { data, error } = await supabase
                .from(tableName)
                .select('*')
                .ilike(subcategoryColumn, subcategory)
                .order('place_id', { ascending: true })
                .range(offset, offset + FETCH_LIMIT_PER_TYPE - 1);

            console.log(`Fetched ${data?.length || 0} from ${tableName} where ${subcategoryColumn} ilike '${subcategory}' at offset ${offset}`);

            if (error || !data) continue;

            subcategoryOffsets.current[offsetKey] = offset + FETCH_LIMIT_PER_TYPE;

            const filtered = data.filter(
                (item) =>
                !liked.has(item.place_id) &&
                !allSaved.has(item.place_id) &&
                !recentlyShownSet.current.has(item.place_id)
            );

            console.log(`After filtering: ${filtered.length} items remain.`);

            for (const item of filtered) {
                recentlyShownSet.current.add(item.place_id);
            }

            fetchedItems.push(
                ...filtered.map((item) => ({
                ...item,
                image_url: item.image_url?.trim() || null,
                description: item.description || 'No description available',
                hours: item.hours || [],
                }))
            );
            }
        }

        await saveRecentlyShownToStorage();
        const shuffled = shuffleArray(fetchedItems);
        setContentData((prev) => [...prev, ...shuffled]);
        } catch (e) {
        Alert.alert('Error', 'Something went wrong.');
        console.error(e);
        } finally {
        setLoading(false);
        setRefreshing(false);
        setPreloading(false);
        }
    };

    const preloadIfLow = (index: number) => {
        const remaining = contentData.length - index;
        console.log(`Checking if preload needed. Index: ${index}, remaining: ${remaining}`);
        if (!loading && !refreshing && !preloading && remaining < THRESHOLD_PRELOAD) {
        console.log('Preloading more data...');
        fetchData('preload');
        }
    };

    useEffect(() => {
        if (!currentUser?.id) return;

        // Optionally clear stale shown set on app launch
        recentlyShownSet.current.clear();
        AsyncStorage.removeItem(RECENTLY_SHOWN_STORAGE_KEY); // clear cache

        loadRecentlyShownFromStorage().then(() => {
            fetchData('init');
        });
    }, [currentUser?.id]);

    return (
    <FeedView
        items={contentData}
        liked={likedPlaces}
        savedMap={savedMap}
        refreshing={refreshing}
        loading={loading} // ✅ for full-screen spinner on initial load
        preloading={preloading} // ✅ new prop for subtle bottom loader
        onRefresh={() => {
        console.log('Refreshing...');
        recentlyShownSet.current.clear();
        subcategoryOffsets.current = {};
        AsyncStorage.removeItem(RECENTLY_SHOWN_STORAGE_KEY);
        setContentData([]);
        fetchData('refresh');
        }}
        erroredImages={erroredImages}
        setErroredImages={setErroredImages}
        setCurrentIndex={(index) => {
        setCurrentIndex(index);
        preloadIfLow(index);
        }}
        currentUserId={currentUser?.id}
        setLikedPlaces={setLikedPlaces}
        setSavedMap={setSavedMap}
    />
    );
}
