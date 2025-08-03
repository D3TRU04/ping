// home/for-you/page.tsx
import React, { useEffect, useRef, useState, useCallback } from 'react';
import { Alert } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { supabase } from '../../../../lib/supabase';
import FeedView from '../feeds/FeedView';
import { FoodPlace } from '../../../types/FoodPlace';

const RECENTLY_SHOWN_STORAGE_KEY = 'recentlyShownPlaceIds';
const OFFSETS_STORAGE_KEY = 'subcategoryOffsets';
const MAX_RECENTLY_SHOWN = 500;
const FETCH_LIMIT_PER_TYPE = 2;
const THRESHOLD_PRELOAD = 6;

export default function ForYouPage({ currentUser }: { currentUser: any }) {
    const [contentData, setContentData] = useState<FoodPlace[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [preloading, setPreloading] = useState(false);

    const [likedPlaces, setLikedPlaces] = useState<Set<string>>(new Set());
    const [savedMap, setSavedMap] = useState<Record<string, string[]>>({});
    const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
    const [currentIndex, setCurrentIndex] = useState(0);

    const recentlyShownSet = useRef<Set<string>>(new Set());
    const subcategoryOffsets = useRef<Record<string, number>>({});

    // Utility: Shuffle array
    const shuffleArray = <T,>(array: T[]): T[] => {
        const copy = [...array];
        for (let i = copy.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [copy[i], copy[j]] = [copy[j], copy[i]];
        }
        return copy;
    };

    // Load recently shown from AsyncStorage
    const loadRecentlyShownFromStorage = useCallback(async () => {
        try {
            const [shownRaw, offsetsRaw] = await Promise.all([
                AsyncStorage.getItem(RECENTLY_SHOWN_STORAGE_KEY),
                AsyncStorage.getItem(OFFSETS_STORAGE_KEY),
            ]);
            if (shownRaw) {
                const parsed = JSON.parse(shownRaw);
                recentlyShownSet.current = new Set(parsed);
                console.log('🧠 Loaded from AsyncStorage:', parsed);
            } else {
                recentlyShownSet.current = new Set();
                console.log('🧠 No stored data found in AsyncStorage.');
            }
            if (offsetsRaw) {
                subcategoryOffsets.current = JSON.parse(offsetsRaw);
                console.log('🧠 Loaded offsets from AsyncStorage:', subcategoryOffsets.current);
            } else {
                subcategoryOffsets.current = {};
                console.log('🧠 No offsets found in AsyncStorage.');
            }
        } catch (e) {
            recentlyShownSet.current = new Set();
            subcategoryOffsets.current = {};
            console.error('Failed to load AsyncStorage:', e);
        }
    }, []);

    // Save recently shown to AsyncStorage
    const saveRecentlyShownToStorage = useCallback(async () => {
        try {
            const trimmed = Array.from(recentlyShownSet.current).slice(-MAX_RECENTLY_SHOWN);
            await AsyncStorage.setItem(RECENTLY_SHOWN_STORAGE_KEY, JSON.stringify(trimmed));
            await AsyncStorage.setItem(OFFSETS_STORAGE_KEY, JSON.stringify(subcategoryOffsets.current));
            console.log('📦 Saved to AsyncStorage:', trimmed, subcategoryOffsets.current);
        } catch (e) {
            console.error('Failed to save AsyncStorage:', e);
        }
    }, []);

    // Fetch data from Supabase
    const fetchData = useCallback(
        async (mode: 'init' | 'refresh' | 'preload' = 'init') => {
            if (mode === 'refresh') setRefreshing(true);
            else if (mode === 'preload') setPreloading(true);
            else setLoading(true);

            try {
                // Defensive: Always clear loading if user is missing
                if (!currentUser?.id) {
                    setLoading(false);
                    setRefreshing(false);
                    setPreloading(false);
                    return;
                }

                // Fetch user profile
                const { data: profileData, error: profileError } = await supabase
                    .from('profiles')
                    .select('category_preferences, liked, saved')
                    .eq('id', currentUser.id)
                    .single();

                if (profileError || !profileData) {
                    Alert.alert('Error', 'Unable to fetch user profile.');
                    setLoading(false);
                    setRefreshing(false);
                    setPreloading(false);
                    return;
                }

                const categoryPrefs = profileData.category_preferences || {};
                const liked = new Set<string>(profileData.liked || []);
                const saved = profileData.saved || {};
                const allSaved = new Set(saved['all_saved'] || []);

                setLikedPlaces(liked);
                setSavedMap(saved);

                const fetchedItems: FoodPlace[] = [];

                // Fetch for each category/subcategory
                for (const [tableName, subcategories] of Object.entries(categoryPrefs)) {
                    const subcategoryColumn = `${tableName}_subcategory`;

                    for (const subcategory of subcategories as string[]) {
                        const offsetKey = `${tableName}:${subcategory}`;
                        const offset = subcategoryOffsets.current[offsetKey] ?? 0;
                        subcategoryOffsets.current[offsetKey] = offset + FETCH_LIMIT_PER_TYPE;

                        // Fetch data from the table
                        const { data: tableData, error: tableError } = await supabase
                            .from(tableName)
                            .select('*')
                            .eq(subcategoryColumn, subcategory)
                            .range(offset, offset + FETCH_LIMIT_PER_TYPE - 1);

                        if (tableError) {
                            console.error(`Error fetching from ${tableName}:`, tableError);
                            continue;
                        }

                        if (tableData && tableData.length > 0) {
                            // Filter out recently shown items
                            const filtered = tableData.filter((item: any) => 
                                !recentlyShownSet.current.has(item.place_id)
                            );

                            // Add to recently shown set
                            for (const item of filtered) {
                                recentlyShownSet.current.add(item.place_id);
                            }

                            fetchedItems.push(
                                ...filtered.map((item: any) => ({
                                    ...item,
                                    image_url: item.image_url?.trim() || null,
                                    description: item.description || 'No description available',
                                    hours: item.hours || [],
                                }))
                            );
                        }
                    }
                }

                await saveRecentlyShownToStorage();

                // Update state with fetched data
                setContentData(fetchedItems);
                setLoading(false);
                setRefreshing(false);
                setPreloading(false);
            } catch (error) {
                console.error('Error fetching data:', error);
                Alert.alert('Error', 'Failed to load content. Please try again.');
                setLoading(false);
                setRefreshing(false);
                setPreloading(false);
            }
        },
        [currentUser?.id, saveRecentlyShownToStorage]
    );

    // Handle refresh
    const handleRefresh = useCallback(() => {
        fetchData('refresh');
    }, [fetchData]);

    // Preload if low on content
    const preloadIfLow = useCallback((index: number) => {
        if (contentData.length - index <= THRESHOLD_PRELOAD) {
            fetchData('preload');
        }
    }, [contentData.length, fetchData]);

    // Initial data load
    useEffect(() => {
        loadRecentlyShownFromStorage().then(() => {
            fetchData('init');
        });
    }, [loadRecentlyShownFromStorage, fetchData]);

    return (
        <FeedView
            items={contentData}
            liked={likedPlaces}
            savedMap={savedMap}
            refreshing={refreshing}
            loading={loading}
            preloading={preloading}
            onRefresh={handleRefresh}
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
