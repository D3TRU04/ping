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

export default function ForYouPage({ currentUser }: { currentUser: any }) {
  const [contentData, setContentData] = useState<FoodPlace[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
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

  const saveRecentlyShownToStorage = async () => {
    const trimmed = Array.from(recentlyShownSet.current).slice(-MAX_RECENTLY_SHOWN);
    await AsyncStorage.setItem(RECENTLY_SHOWN_STORAGE_KEY, JSON.stringify(trimmed));
  };

  const fetchData = async (isRefresh = false) => {
    isRefresh ? setRefreshing(true) : setLoading(true);
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
            .order('place_id', { ascending: true }) // ✅ fixed
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
      setContentData((prev) => [...prev, ...fetchedItems]);
    } catch (e) {
      Alert.alert('Error', 'Something went wrong.');
      console.error(e);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const preloadIfLow = (index: number) => {
    const remaining = contentData.length - index;
    console.log(`Checking if preload needed. Index: ${index}, remaining: ${remaining}`);
    if (!loading && remaining < 3) {
      console.log('Preloading more data...');
      fetchData();
    }
  };

  useEffect(() => {
    if (!currentUser?.id || !loading) return;

    loadRecentlyShownFromStorage().then(() => {
      fetchData();
    });
  }, [currentUser?.id, loading]);

  return (
    <FeedView
      items={contentData}
      liked={likedPlaces}
      savedMap={savedMap}
      refreshing={refreshing}
      loading={loading}
      onRefresh={() => {
        console.log('Refreshing...');
        recentlyShownSet.current.clear();
        subcategoryOffsets.current = {};
        AsyncStorage.removeItem(RECENTLY_SHOWN_STORAGE_KEY);
        setContentData([]);
        fetchData(true);
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
