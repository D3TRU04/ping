import React, { useEffect, useState } from 'react';
import { Alert } from 'react-native';
import { supabase } from '../../../../lib/supabase';
import FeedView from '../feeds/FeedView';
import { FoodPlace } from '../../../types/FoodPlace';

export default function ForYouPage({ currentUser }: { currentUser: any }) {
  const [contentData, setContentData] = useState<FoodPlace[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [likedPlaces, setLikedPlaces] = useState<Set<string>>(new Set());
  const [savedMap, setSavedMap] = useState<Record<string, string[]>>({});
  const [erroredImages, setErroredImages] = useState<Set<string>>(new Set());
  const [currentIndex, setCurrentIndex] = useState(0);

  const fetchData = async (isRefresh = false) => {
    isRefresh ? setRefreshing(true) : setLoading(true);
    try {
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('category_preferences, liked, saved')
        .eq('id', currentUser?.id)
        .single();

      if (profileError) return;

      const foodPrefs = profileData?.category_preferences?.['food_drinks'] || [];
      const liked = new Set<string>(profileData?.liked || []);
      const saved = profileData?.saved || {};
      const allSaved = new Set(saved['all_saved'] || []);

      setLikedPlaces(liked);
      setSavedMap(saved);

      const { data: foodData } = await supabase
        .from('food_places')
        .select('*')
        .limit(20);

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
      Alert.alert('Error', 'Something went wrong.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    if (currentUser?.id) fetchData();
  }, [currentUser?.id]);

  return (
    <FeedView
      items={contentData}
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
