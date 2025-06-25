import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Dimensions,
  RefreshControl,
  Alert,
} from 'react-native';
import { styled } from 'nativewind';
import TopNavBar from '../../components/navbar/Discover';
import BottomNavBar from '../../components/navbar/BottomNavBar';
import AppText from '../../components/AppText';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { COLORS } from '../../theme/colors';
import { supabase } from '../../../lib/supabase';
import { categories } from '../auth/onboarding/data';
import MapView, { Marker, Callout } from 'react-native-maps';

const StyledView = styled(View);
const StyledTextInput = styled(TextInput);
const StyledTouchableOpacity = styled(TouchableOpacity);

const { width: SCREEN_WIDTH } = Dimensions.get('window');

interface Place {
  place_id: string;
  name: string;
  image_url?: string;
  description?: string;
  type_of_food?: string;
  subtopic?: string;
  rating?: number;
  price_range?: number;
  hours: string[];
  address?: string;
  latitude?: number;
  longitude?: number;
}

interface FilterOption {
  id: string;
  name: string;
  value: string;
  selected: boolean;
}

// Add this above the component for a modern map style (optional)
const modernMapStyle = [
  { elementType: 'geometry', stylers: [{ color: '#F5F5F5' }] },
  { elementType: 'labels.icon', stylers: [{ visibility: 'off' }] },
  { elementType: 'labels.text.fill', stylers: [{ color: '#616161' }] },
  { elementType: 'labels.text.stroke', stylers: [{ color: '#F5F5F5' }] },
  {
    featureType: 'administrative.land_parcel',
    elementType: 'labels.text.fill',
    stylers: [{ color: '#bdbdbd' }],
  },
  {
    featureType: 'poi',
    elementType: 'geometry',
    stylers: [{ color: '#eeeeee' }],
  },
  {
    featureType: 'poi',
    elementType: 'labels.text.fill',
    stylers: [{ color: '#757575' }],
  },
  {
    featureType: 'poi.park',
    elementType: 'geometry',
    stylers: [{ color: '#e5e5e5' }],
  },
  {
    featureType: 'poi.park',
    elementType: 'labels.text.fill',
    stylers: [{ color: '#9e9e9e' }],
  },
  {
    featureType: 'road',
    elementType: 'geometry',
    stylers: [{ color: '#ffffff' }],
  },
  {
    featureType: 'road.arterial',
    elementType: 'labels.text.fill',
    stylers: [{ color: '#757575' }],
  },
  {
    featureType: 'road.highway',
    elementType: 'geometry',
    stylers: [{ color: '#dadada' }],
  },
  {
    featureType: 'road.highway',
    elementType: 'labels.text.fill',
    stylers: [{ color: '#616161' }],
  },
  {
    featureType: 'road.local',
    elementType: 'labels.text.fill',
    stylers: [{ color: '#9e9e9e' }],
  },
  {
    featureType: 'transit.line',
    elementType: 'geometry',
    stylers: [{ color: '#e5e5e5' }],
  },
  {
    featureType: 'transit.station',
    elementType: 'geometry',
    stylers: [{ color: '#eeeeee' }],
  },
  {
    featureType: 'water',
    elementType: 'geometry',
    stylers: [{ color: '#c9c9c9' }],
  },
  {
    featureType: 'water',
    elementType: 'labels.text.fill',
    stylers: [{ color: '#9e9e9e' }],
  },
];

export default function DiscoverScreen({ route }: { route: any }) {
  const currentUser = route?.params?.currentUser;
  const [searchQuery, setSearchQuery] = useState('');
  const [places, setPlaces] = useState<Place[]>([]);
  const [filteredPlaces, setFilteredPlaces] = useState<Place[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState<FilterOption[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');

  useEffect(() => {
    fetchPlaces();
    initializeFilters();
  }, []);

  useEffect(() => {
    filterPlaces();
  }, [searchQuery, filters, selectedCategory, places]);

  const initializeFilters = () => {
    const foodCategories = categories.find(cat => cat.id === 'food-drink');
    const filterOptions: FilterOption[] = foodCategories?.subcategories
      .filter(sub => sub.value) // Only include subcategories with values
      .map(sub => ({
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
        console.error('Error fetching places:', error);
        Alert.alert('Error', 'Failed to load places. Please try again.');
        return;
      }

      const transformedPlaces = data?.map(place => ({
        ...place,
        image_url: place.image_url?.trim() || null,
        description: place.description || 'No description available',
        hours: place.hours || [],
        latitude: place.latitude || undefined,
        longitude: place.longitude || undefined,
      })) || [];

      setPlaces(transformedPlaces);
    } catch (error) {
      console.error('Error fetching places:', error);
      Alert.alert('Error', 'Something went wrong. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const filterPlaces = () => {
    let filtered = [...places];

    // Filter by search query
    if (searchQuery.trim()) {
      filtered = filtered.filter(place =>
        place.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        place.description?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        place.type_of_food?.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }

    // Filter by selected category
    if (selectedCategory !== 'all') {
      filtered = filtered.filter(place => place.subtopic === selectedCategory);
    }

    // Filter by selected filters
    const selectedFilters = filters.filter(f => f.selected);
    if (selectedFilters.length > 0) {
      filtered = filtered.filter(place =>
        selectedFilters.some(filter => place.subtopic === filter.value)
      );
    }

    setFilteredPlaces(filtered);
  };

  const toggleFilter = (filterId: string) => {
    setFilters(prev => prev.map(filter =>
      filter.id === filterId ? { ...filter, selected: !filter.selected } : filter
    ));
  };

  const clearFilters = () => {
    setFilters(prev => prev.map(filter => ({ ...filter, selected: false })));
    setSelectedCategory('all');
    setSearchQuery('');
  };

  const onRefresh = () => {
    fetchPlaces(true);
  };

  const renderPlaceCard = ({ item }: { item: Place }) => (
    <StyledTouchableOpacity
      className="bg-white rounded-2xl mb-4 overflow-hidden"
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
        elevation: 4,
      }}
    >
      <StyledView className="relative">
        {item.image_url ? (
          <StyledView className="w-full h-48">
            <StyledView className="w-full h-full bg-gray-200 justify-center items-center">
              <Icon name="restaurant" size={32} color="#9CA3AF" />
              <AppText className="text-gray-500 mt-2">Image loading...</AppText>
            </StyledView>
          </StyledView>
        ) : (
          <StyledView className="w-full h-48 bg-gradient-to-br from-gray-200 to-gray-300 justify-center items-center">
            <Icon name="restaurant" size={32} color="#9CA3AF" />
            <AppText className="text-gray-500 mt-2">No image available</AppText>
          </StyledView>
        )}

        <StyledView className="absolute top-3 right-3">
          <StyledView className="bg-white/90 px-2 py-1 rounded-full">
            <AppText className="text-xs text-gray-800">
              {item.subtopic || 'Food'}
            </AppText>
          </StyledView>
        </StyledView>
      </StyledView>

      <StyledView className="p-4">
        <StyledView className="flex-row justify-between items-start mb-2">
          <AppText className="text-lg text-gray-900 flex-1 mr-2">
            {item.name}
          </AppText>
          <StyledView className="flex-row items-center">
            <Icon name="star" size={14} color="#FFD700" />
            <AppText className="text-sm text-gray-700 ml-1">
              {item.rating?.toFixed(1) || 'N/A'}
            </AppText>
          </StyledView>
        </StyledView>

        {item.price_range && (
          <StyledView className="mb-2">
            <AppText className="text-sm text-gray-600">
              {'$'.repeat(item.price_range)}
            </AppText>
          </StyledView>
        )}

        <AppText className="text-gray-700 text-sm leading-5 mb-3" numberOfLines={2}>
          {item.description}
        </AppText>

        <StyledView className="flex-row space-x-2">
          <StyledTouchableOpacity
            className="flex-1 bg-gray-100 py-2 rounded-xl items-center"
            onPress={() => console.log('Get directions to:', item.name)}
          >
            <StyledView className="flex-row items-center">
              <Icon name="directions" size={14} color={COLORS.mint} />
              <AppText className="text-xs text-gray-700 ml-1">
                Directions
              </AppText>
            </StyledView>
          </StyledTouchableOpacity>

          <StyledTouchableOpacity
            className="flex-1 bg-mint py-2 rounded-xl items-center"
            onPress={() => console.log('Save:', item.name)}
          >
            <StyledView className="flex-row items-center">
              <Icon name="favorite-border" size={14} color="white" />
              <AppText className="text-xs text-white ml-1">
                Save
              </AppText>
            </StyledView>
          </StyledTouchableOpacity>
        </StyledView>
      </StyledView>
    </StyledTouchableOpacity>
  );

  const renderFilterChip = ({ item }: { item: FilterOption }) => (
    <StyledTouchableOpacity
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
    </StyledTouchableOpacity>
  );

  const renderEmptyState = () => (
    <StyledView className="flex-1 justify-center items-center px-8">
      <Icon name="search-off" size={80} color={COLORS.mint} />
      <AppText className="text-xl text-gray-900 mt-4 text-center">
        No places found
      </AppText>
      <AppText className="text-gray-600 text-center mt-2 leading-6">
        Try adjusting your search or filters to find more places.
      </AppText>
      <StyledTouchableOpacity
        className="bg-mint px-6 py-3 rounded-2xl mt-6"
        onPress={clearFilters}
      >
        <AppText className="text-white">Clear Filters</AppText>
      </StyledTouchableOpacity>
    </StyledView>
  );

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar currentUser={currentUser} />

      {/* Map Feature */}
      <StyledView
        className="w-full"
        style={{
          height: SCREEN_WIDTH * 0.8,
          borderRadius: 28,
          overflow: 'hidden',
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 6 },
          shadowOpacity: 0.12,
          shadowRadius: 16,
          elevation: 8,
          marginTop: 12,
          marginBottom: 12,
        }}
      >
        <MapView
          style={{ flex: 1 }}
          initialRegion={{
            latitude: 30.2672, // Austin, TX as default
            longitude: -97.7431,
            latitudeDelta: 0.08,
            longitudeDelta: 0.08,
          }}
          showsUserLocation
          showsMyLocationButton
          showsCompass
          customMapStyle={modernMapStyle}
        >
          {filteredPlaces.map((place, idx) => (
            <Marker
              key={place.place_id || idx}
              coordinate={{
                latitude: place.latitude || 30.2672 + 0.01 * (idx % 5),
                longitude: place.longitude || -97.7431 + 0.01 * (idx % 5),
              }}
              title={place.name}
              description={place.description}
            >
              <StyledView className="bg-mint border-2 border-white rounded-full w-8 h-8 items-center justify-center shadow-md">
                <Icon name="restaurant" size={16} color="white" />
              </StyledView>
              <Callout tooltip>
                <StyledView className="bg-white rounded-2xl px-4 py-3 shadow-lg border border-mint max-w-xs">
                  <AppText className="text-base font-bold text-gray-900 mb-1">{place.name}</AppText>
                  <StyledView className="flex-row items-center mb-1">
                    <Icon name="star" size={14} color="#FFD700" />
                    <AppText className="text-xs text-gray-700 ml-1">{place.rating?.toFixed(1) || 'N/A'}</AppText>
                  </StyledView>
                  <AppText className="text-xs text-gray-500" numberOfLines={2}>{place.description}</AppText>
                </StyledView>
              </Callout>
            </Marker>
          ))}
        </MapView>
        {/* Optional: Add a gradient overlay at the bottom for modern look */}
        {/*
        <LinearGradient
          colors={['transparent', 'rgba(250,246,242,0.8)']}
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            bottom: 0,
            height: 40,
            borderBottomLeftRadius: 28,
            borderBottomRightRadius: 28,
          }}
        />
        */}
      </StyledView>

      {/* Search and Filter Header */}
      <StyledView className="px-4 pt-4 pb-2">
        <StyledView className="flex-row items-center space-x-3 mb-4">
          <StyledView className="flex-1 relative">
            <StyledTextInput
              className="bg-white px-4 py-3 rounded-2xl text-gray-900"
              placeholder="Search places, cuisines..."
              placeholderTextColor="#9CA3AF"
              value={searchQuery}
              onChangeText={setSearchQuery}
              style={{
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.1,
                shadowRadius: 4,
                elevation: 2,
              }}
            />
            <StyledView className="absolute right-3 top-3">
              <Icon name="search" size={20} color={COLORS.mint} />
            </StyledView>
          </StyledView>

          <StyledTouchableOpacity
            onPress={() => setShowFilters(!showFilters)}
            className={`w-12 h-12 rounded-2xl items-center justify-center ${
              showFilters ? 'bg-mint' : 'bg-white'
            }`}
            style={{
              shadowColor: '#000',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: 0.1,
              shadowRadius: 4,
              elevation: 2,
            }}
          >
            <Icon 
              name="tune" 
              size={20} 
              color={showFilters ? 'white' : COLORS.mint} 
            />
          </StyledTouchableOpacity>
        </StyledView>

        {/* Filters Section */}
        {showFilters && (
          <StyledView className="bg-white rounded-2xl p-4 mb-4">
            <StyledView className="flex-row justify-between items-center mb-3">
              <AppText className="text-lg text-gray-900">
                Filters
              </AppText>
              <StyledTouchableOpacity onPress={clearFilters}>
                <AppText className="text-mint">Clear All</AppText>
              </StyledTouchableOpacity>
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
        )}
      </StyledView>

      {/* Content */}
      {loading ? (
        <StyledView className="flex-1 justify-center items-center">
          <ActivityIndicator size="large" color={COLORS.mint} />
          <AppText className="text-mint mt-4 text-lg">
            Discovering amazing places...
          </AppText>
        </StyledView>
      ) : (
        <FlatList
          data={filteredPlaces}
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
          contentContainerStyle={{ 
            paddingHorizontal: 16,
            paddingBottom: 120,
          }}
        />
      )}

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
