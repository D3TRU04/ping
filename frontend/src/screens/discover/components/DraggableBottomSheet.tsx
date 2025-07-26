import React, { useRef, useEffect } from 'react';
import { View, FlatList, ActivityIndicator, RefreshControl, Image, TouchableOpacity, Alert, Dimensions, Animated as RNAnimated, PanResponder } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { supabase } from '../../../../lib/supabase';
import { categories } from '../../auth/onboarding/data/categories';

const StyledView = styled(View);
const AnimatedView = RNAnimated.createAnimatedComponent(View);
// Remove StyledTouchableOpacity, use TouchableOpacity from react-native
const COLORS = {
  mint: '#1FC9C3',
};

interface DraggableBottomSheetProps {
  showFilters: boolean;
  setShowFilters: (show: boolean) => void;
  filters: any[];
  setFilters: React.Dispatch<React.SetStateAction<any[]>>;
  setSelectedCategory: (cat: string) => void;
  setSearchQuery: (query: string) => void;
  loading: boolean;
  setLoading: (loading: boolean) => void;
  refreshing: boolean;
  setRefreshing: (refreshing: boolean) => void;
  activeTab: string;
  followingUsers: any[];
  places: any[];
  setPlaces: React.Dispatch<React.SetStateAction<any[]>>;
  filteredPlaces: any[];
  setFilteredPlaces: React.Dispatch<React.SetStateAction<any[]>>;
  searchQuery: string;
  sheetCollapsedTop: number;
  navbarHeight: number;
  setIsSheetDown: (down: boolean) => void;
  setSelectedPlace: (place: any) => void;
}

const DraggableBottomSheet: React.FC<DraggableBottomSheetProps> = ({
  showFilters,
  setShowFilters,
  filters,
  setFilters,
  setSelectedCategory,
  setSearchQuery,
  loading,
  setLoading,
  refreshing,
  setRefreshing,
  activeTab,
  followingUsers,
  places,
  setPlaces,
  filteredPlaces,
  setFilteredPlaces,
  searchQuery,
  sheetCollapsedTop,
  navbarHeight,
  setIsSheetDown,
  setSelectedPlace,
}) => {
  // Animation and pan responder logic
  const sheetTop = useRef(new RNAnimated.Value(sheetCollapsedTop)).current;
  const sheetTopValue = useRef(sheetCollapsedTop);

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: () => {
        sheetTop.setOffset(sheetTopValue.current);
        sheetTop.setValue(0);
      },
      onPanResponderMove: RNAnimated.event([
        null, { dy: sheetTop }
      ], { useNativeDriver: false }),
      onPanResponderRelease: (_, gestureState) => {
        sheetTop.flattenOffset();
        const sheetExpandedTop = navbarHeight + 10;
        let toValue;
        if (gestureState.dy < -50) {
          toValue = sheetExpandedTop;
        } else if (gestureState.dy > 50) {
          toValue = sheetCollapsedTop;
        } else {
          const currentTop = sheetTopValue.current;
          toValue = Math.abs(currentTop - sheetExpandedTop) < Math.abs(currentTop - sheetCollapsedTop)
            ? sheetExpandedTop
            : sheetCollapsedTop;
        }
        RNAnimated.spring(sheetTop, {
          toValue,
          useNativeDriver: false,
          tension: 100,
          friction: 12,
        }).start();
        setIsSheetDown(toValue === sheetCollapsedTop);
        if (toValue !== sheetCollapsedTop) {
          setSelectedPlace(null);
        }
      },
    })
  ).current;

  useEffect(() => {
    const id = sheetTop.addListener(({ value }) => {
      sheetTopValue.current = value;
    });
    return () => sheetTop.removeListener(id);
  }, [sheetTop]);

  const toggleFilter = (filterId: string) => {
    setFilters((prev: any[]) => prev.map(filter =>
      filter.id === filterId ? { ...filter, selected: !filter.selected } : filter
    ));
  };

  const clearFilters = () => {
    setFilters((prev: any[]) => prev.map(filter => ({ ...filter, selected: false })));
    setSelectedCategory('all');
    setSearchQuery('');
  };

  const onRefresh = () => {
    fetchPlaces(true);
  };

  const initializeFilters = () => {
    const foodCategories = categories.find(cat => cat.id === 'food-drink');
    const filterOptions = foodCategories?.subcategories
      .filter((sub: any) => sub.value)
      .map((sub: any) => ({
        id: sub.value!,
        name: sub.name,
        value: sub.value!,
        selected: false,
      })) || [];
    setFilters(filterOptions);
  };

  const fetchPlaces = async (isRefresh = false) => {
    if (isRefresh) {
      setRefreshing(true);
    } else {
      setLoading(true);
    }
    try {
      const { data, error } = await supabase
        .from('food_places')
        .select('*')
        .limit(50);
      if (error) {
        Alert.alert('Error', 'Failed to load places. Please try again.');
        return;
      }
      const transformedPlaces = data?.map((place: any) => {
        const latitude = place.lat || place.latitude;
        const longitude = place.lng || place.longitude;
        return {
          ...place,
          image_url: place.image_url?.trim() || null,
          description: place.description || 'No description available',
          hours: place.hours || [],
          latitude: latitude,
          longitude: longitude,
          lat: latitude,
          lng: longitude,
        };
      }) || [];
      setPlaces(transformedPlaces);
    } catch (error) {
      Alert.alert('Error', 'Something went wrong. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const filterPlaces = () => {
    let filtered = [...places];
    if (searchQuery.trim()) {
      filtered = filtered.filter(place =>
        place.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        place.description?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        place.type_of_food?.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }
    if (filters.some(f => f.selected)) {
      const selectedFilters = filters.filter(f => f.selected);
      filtered = filtered.filter(place =>
        selectedFilters.some(filter => place.subtopic === filter.value)
      );
    }
    setFilteredPlaces(filtered);
  };

  useEffect(() => {
    initializeFilters();
    fetchPlaces();
  }, []);

  useEffect(() => {
    filterPlaces();
  }, [searchQuery, filters, places]);

  const renderFollowingUser = ({ item }: { item: any }) => (
    <TouchableOpacity className="flex-row items-center py-3 border-b border-gray-200">
      <Image
        source={item.profile_picture ? { uri: item.profile_picture } : require('../../../assets/profilepic.png')}
        className="w-12 h-12 rounded-full mr-3"
      />
      <View>
        <AppText className="text-base font-bold">{item.full_name}</AppText>
        <AppText className="text-sm text-gray-500">@{item.username}</AppText>
      </View>
    </TouchableOpacity>
  );

  const renderPlaceCard = ({ item }: { item: any }) => (
    <TouchableOpacity
      style={{
        backgroundColor: 'white',
        borderRadius: 16,
        marginBottom: 16,
        overflow: 'hidden',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
        elevation: 4,
      }}
    >
      {/* ... Place card content ... */}
      <AppText>{item.name}</AppText>
    </TouchableOpacity>
  );

  const renderFilterChip = ({ item }: { item: any }) => (
    <TouchableOpacity
      onPress={() => toggleFilter(item.id)}
      className={`px-4 py-2 rounded-full mr-2 mb-2 ${
        item.selected ? 'bg-mint' : 'bg-gray-200'
      }`}
    >
      <AppText
        className={`text-sm ${
          item.selected ? 'text-white' : 'text-gray-700'
        }`}
      >
        {item.name}
      </AppText>
    </TouchableOpacity>
  );

  const renderEmptyState = () => (
    <StyledView className="flex-1 justify-center items-center px-8 mt-10">
      <Icon name="search-off" size={80} color={COLORS.mint} />
      <AppText className="text-xl text-gray-900 mt-4 text-center">
        No places found
      </AppText>
      <AppText className="text-gray-600 text-center mt-2 leading-6">
        Try adjusting your search or filters to find more places.
      </AppText>
      <TouchableOpacity
        className="bg-mint px-6 py-3 rounded-2xl mt-6"
        onPress={clearFilters}
      >
        <AppText className="text-white">Clear Filters</AppText>
      </TouchableOpacity>
    </StyledView>
  );

  return (
    <AnimatedView
      style={[
        {
          position: 'absolute',
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'white',
          borderTopLeftRadius: 20,
          borderTopRightRadius: 20,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: -4 },
          shadowOpacity: 0.15,
          shadowRadius: 12,
          elevation: 8,
          zIndex: 30,
        },
        { top: sheetTop },
      ]}
    >
      {/* Drag Handle and Header - Only this area is draggable */}
      <StyledView {...panResponder.panHandlers}>
        <StyledView className="w-10 h-1 bg-gray-300 rounded-full self-center mt-2 mb-4" />
        {/* Content Header */}
        <StyledView className="px-4 pb-4">
          <StyledView className="flex-row justify-between items-center mb-4">
            <AppText className="text-xl font-bold text-gray-900">
              Discover Places
            </AppText>
            <TouchableOpacity
              onPress={() => setShowFilters(!showFilters)}
              className={`px-3 py-2 rounded-full flex-row items-center ${showFilters ? 'bg-mint' : 'bg-gray-100'}`}
            >
              <Icon
                name="tune"
                size={16}
                color={showFilters ? 'white' : '#6B7280'}
              />
              <AppText className={`text-base font-semibold ml-1 ${showFilters ? 'text-white' : 'text-gray-600'}`}>Filters</AppText>
            </TouchableOpacity>
          </StyledView>
        </StyledView>
      </StyledView>

      {/* Filters Section */}
      {showFilters && (
        <>
          {/* Overlay to close filter UI when clicking outside */}
          <TouchableOpacity
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.01)', // nearly transparent
              zIndex: 1,
            }}
            activeOpacity={1}
            onPress={() => setShowFilters(false)}
          />
          <StyledView className="px-4 pb-4" style={{ zIndex: 2 }}>
            <StyledView className="bg-gray-50 rounded-2xl p-4 border border-gray-200">
              <StyledView className="flex-row justify-between items-center mb-3">
                <AppText className="text-lg font-semibold text-gray-900">
                  Filter by Category
                </AppText>
                <TouchableOpacity onPress={clearFilters}>
                  <AppText className="text-base font-semibold text-mint">Clear All</AppText>
                </TouchableOpacity>
              </StyledView>
              <FlatList
                data={filters}
                renderItem={renderFilterChip}
                keyExtractor={(item) => item.id}
                horizontal={false}
                numColumns={2}
                showsVerticalScrollIndicator={false}
                contentContainerStyle={{ paddingBottom: 8 }}
              />
            </StyledView>
          </StyledView>
        </>
      )}

      {/* Places List */}
      <StyledView className="flex-1">
        {loading ? (
          <StyledView className="flex-1 justify-center items-center">
            <ActivityIndicator size="large" color={COLORS.mint} />
            <AppText className="text-mint mt-4 text-lg font-semibold">
              Discovering amazing places...
            </AppText>
          </StyledView>
        ) : activeTab === 'following' ? (
          <FlatList
            data={followingUsers}
            renderItem={renderFollowingUser}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={{ paddingBottom: 120, paddingHorizontal: 16 }}
            style={{ flex: 1 }}
          />
        ) : (
          <FlatList
            data={filteredPlaces.slice(0, 10)}
            renderItem={renderPlaceCard}
            keyExtractor={(item) => item.place_id}
            showsVerticalScrollIndicator={false}
            refreshControl={
              <RefreshControl
                refreshing={refreshing}
                onRefresh={onRefresh}
                tintColor={COLORS.mint}
                colors={[COLORS.mint]}
              />
            }
            ListEmptyComponent={renderEmptyState}
            contentContainerStyle={{ paddingBottom: 120, paddingHorizontal: 16 }}
            style={{ flex: 1 }}
          />
        )}
      </StyledView>
    </AnimatedView>
  );
};

export default DraggableBottomSheet; 