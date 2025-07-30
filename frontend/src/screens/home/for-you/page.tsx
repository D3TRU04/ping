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

                // Debug logs
                console.log('categoryPrefs:', categoryPrefs);
                console.log('liked:', Array.from(liked));
                console.log('allSaved:', Array.from(allSaved));
                console.log('recentlyShownSet:', Array.from(recentlyShownSet.current));

                const fetchedItems: FoodPlace[] = [];

                // Fetch for each category/subcategory
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
                        if (error) {
                            console.error('Supabase error:', error);
                            continue;
                        }
                        if (!data || data.length === 0) continue;

                        subcategoryOffsets.current[offsetKey] = offset + FETCH_LIMIT_PER_TYPE;

                        // Filter out already liked, saved, or recently shown
                        const filtered = data.filter(
                            (item) =>
                                !liked.has(item.place_id) &&
                                !allSaved.has(item.place_id) &&
                                !recentlyShownSet.current.has(item.place_id)
                        );

                        console.log(`After filtering: ${filtered.length} items remain.`);

                        // Add to recently shown set
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

                // Shuffle and update content
                const shuffled = shuffleArray(fetchedItems);

                setContentData((prev) => {
                    // On refresh/init, replace; on preload, append
                    if (mode === 'preload') return [...prev, ...shuffled];
                    return shuffled;
                });
            } catch (e) {
                Alert.alert('Error', 'Something went wrong.');
                console.error(e);
            } finally {
                setLoading(false);
                setRefreshing(false);
                setPreloading(false);
            }
        },
        [currentUser, saveRecentlyShownToStorage]
    );

    // Preload more if near end
    const preloadIfLow = useCallback(
        (index: number) => {
            const remaining = contentData.length - index;
            console.log(`Checking if preload needed. Index: ${index}, remaining: ${remaining}`);
            if (!loading && !refreshing && !preloading && remaining < THRESHOLD_PRELOAD) {
                console.log('Preloading more data...');
                fetchData('preload');
            }
        },
        [contentData.length, loading, refreshing, preloading, fetchData]
    );

    // Initial load
    useEffect(() => {
        let isMounted = true;
        if (!currentUser?.id) {
            setLoading(true); 
            return;
        }
        (async () => {
            await loadRecentlyShownFromStorage();
            if (isMounted) await fetchData('init');
        })();
        return () => {
            isMounted = false;
        };
    }, [currentUser?.id, loadRecentlyShownFromStorage, fetchData]);

    // Refresh handler
    const handleRefresh = useCallback(() => {
        console.log('Refreshing...');
        recentlyShownSet.current.clear();
        subcategoryOffsets.current = {};
        AsyncStorage.multiRemove([RECENTLY_SHOWN_STORAGE_KEY, OFFSETS_STORAGE_KEY]);
        setContentData([]);
        fetchData('refresh');
    }, [fetchData]);

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
