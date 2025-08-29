// home/for-you/page.tsx
import React, { useEffect, useState } from 'react';
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

    // Fetch data from Supabase
    const fetchData = async (isRefresh = false) => {
        if (isRefresh) {
            setRefreshing(true);
        } else {
            setLoading(true);
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

        } catch (error) {
            console.error('Error fetching data:', error);
            setContentData([]);
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    };

    // Effect to fetch data on mount and when currentUser changes
    useEffect(() => {
        if (currentUser?.id) {
            fetchData();
        } else {
            setContentData([]);
            setLoading(false);
        }
    }, [currentUser?.id]);

    // Reset component state when it becomes active (for tab switching)
    useEffect(() => {
        if (activeTab === 'forYou') {
            setLoading(true);
            setContentData([]);
            if (currentUser?.id) {
                fetchData();
            }
        }
    }, [activeTab]);



    return (
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
    );
}
