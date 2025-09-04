// home/for-you/page.tsx
import React, { useEffect, useState } from 'react';
import { View, Text } from 'react-native';
import { supabase } from '../../../../lib/supabase';
import FeedView from '../feeds/FeedView';
import { FoodPlace } from '../../../types/FoodPlace';

export default function ForYouPage({ currentUser, activeTab }: { currentUser: any; activeTab: string }) {
    const [contentData, setContentData] = useState<FoodPlace[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [likedPlaces, setLikedPlaces] = useState<Set<string>>(new Set());
    const [savedMap, setSavedMap] = useState<Record<string, string[]>>({});
    const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
    const [hasFetched, setHasFetched] = useState(false);
    const [loadingTimeout, setLoadingTimeout] = useState<NodeJS.Timeout | null>(null);

    // Fetch data from Supabase
    const fetchData = async (isRefresh = false) => {
        if (isRefresh) {
            setRefreshing(true);
        } else {
            setLoading(true);
            // Set a timeout to prevent infinite loading
            const timeout = setTimeout(() => {
                setLoading(false);
            }, 10000); // 10 second timeout
            setLoadingTimeout(timeout);
        }

        try {
            if (!currentUser?.id) {
                setContentData([]);
                return;
            }

            // Fetch user profile
            const { data: profileData, error: profileError } = await supabase
                .from('profiles')
                .select('category_preferences, liked, saved')
                .eq('id', currentUser.id)
                .single();

            if (profileError || !profileData) {
                setContentData([]);
                return;
            }

            const categoryPrefs = profileData.category_preferences || {};
            const liked = new Set<string>(profileData.liked || []);
            const saved = profileData.saved || {};

            setLikedPlaces(liked);
            setSavedMap(saved);

            // Fetch places for each category/subcategory
            const fetchedItems: FoodPlace[] = [];
            
            for (const [tableName, subcategories] of Object.entries(categoryPrefs)) {
                const subcategoryColumn = `${tableName}_subcategory`;

                for (const subcategory of subcategories as string[]) {
                    const { data, error } = await supabase
                        .from(tableName)
                        .select('*')
                        .ilike(subcategoryColumn, subcategory)
                        .order('place_id', { ascending: true })
                        .limit(5);

                    if (error || !data) continue;

                    const filtered = data.filter(
                        (item) => !liked.has(item.place_id)
                    );

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

            // Set content data
            if (fetchedItems.length > 0) {
                setContentData(fetchedItems);
            } else {
                setContentData([]);
            }
            
            setHasFetched(true);

        } catch (error) {
            console.error('Error fetching data:', error);
            setContentData([]);
        } finally {
            // Clear timeout if it exists
            if (loadingTimeout) {
                clearTimeout(loadingTimeout);
                setLoadingTimeout(null);
            }
            setLoading(false);
            setRefreshing(false);
        }
    };

    // Effect to fetch data on mount and when currentUser changes
    useEffect(() => {
        if (currentUser?.id) {
            // Always fetch data when user changes, but don't reset if we already have data
            if (contentData.length === 0) {
                fetchData();
            }
        } else {
            setContentData([]);
            setLoading(false);
            setHasFetched(false);
        }
    }, [currentUser?.id]);

    // Initial data fetch on mount
    useEffect(() => {
        if (currentUser?.id && contentData.length === 0 && !loading) {
            fetchData();
        }
    }, []); // Only run on mount

    // Cleanup effect
    useEffect(() => {
        return () => {
            // Clear any pending timeouts
            if (loadingTimeout) {
                clearTimeout(loadingTimeout);
            }
        };
    }, [loadingTimeout]);





    // Fallback render to prevent white screen
    if (!currentUser?.id) {
        return (
            <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 }}>
                <Text>Please log in to see your personalized feed</Text>
            </View>
        );
    }

    return (
        <View style={{ flex: 1, backgroundColor: '#FAF6F2' }}>
            <FeedView
                items={contentData}
                liked={likedPlaces}
                savedMap={savedMap}
                refreshing={refreshing}
                loading={loading}
                preloading={false}
                onRefresh={() => fetchData(true)}
                erroredImages={erroredImages}
                setErroredImages={setErroredImages}
                setCurrentIndex={() => {}}
                currentUserId={currentUser?.id}
                setLikedPlaces={setLikedPlaces}
                setSavedMap={setSavedMap}
            />
        </View>
    );
}
