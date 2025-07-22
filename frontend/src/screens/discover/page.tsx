import React, { useState, useEffect, useRef } from 'react';
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
  LayoutAnimation,
  Platform,
  UIManager,
  Image,
  PanResponder,
  Animated as RNAnimated,
} from 'react-native';
import { styled } from 'nativewind';
import DiscoverTopNavBar from './components/Discover';
import BottomNavBar from '../../components/BottomNavBar';
import AppText from '../../components/AppText';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { COLORS } from '../../theme/colors';
import { supabase } from '../../../lib/supabase';
import { categories } from '../auth/onboarding/data/categories';
import MapView, { Marker, Callout } from 'react-native-maps';
import { useSafeAreaInsets } from 'react-native-safe-area-context';


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
  lat?: number;
  lng?: number;
  latitude?: number;
  longitude?: number;
}

interface FilterOption {
  id: string;
  name: string;
  value: string;
  selected: boolean;
}

// Function to map subtopic to main category
const getCategoryFromSubtopic = (subtopic: string): string => {
  if (!subtopic) return 'food-drink'; // Default to food-drink
  
  const subtopicLower = subtopic.toLowerCase();
  
  // Food & Drink category
  if (subtopicLower.includes('restaurant') || 
      subtopicLower.includes('cafe') || 
      subtopicLower.includes('coffee') || 
      subtopicLower.includes('food') || 
      subtopicLower.includes('cuisine') || 
      subtopicLower.includes('pizza') || 
      subtopicLower.includes('burger') || 
      subtopicLower.includes('steak') || 
      subtopicLower.includes('seafood') || 
      subtopicLower.includes('italian') || 
      subtopicLower.includes('mexican') || 
      subtopicLower.includes('chinese') || 
      subtopicLower.includes('japanese') || 
      subtopicLower.includes('thai') || 
      subtopicLower.includes('korean') || 
      subtopicLower.includes('indian') || 
      subtopicLower.includes('vegetarian') || 
      subtopicLower.includes('vegan') || 
      subtopicLower.includes('breakfast') || 
      subtopicLower.includes('brunch') || 
      subtopicLower.includes('diner') || 
      subtopicLower.includes('sandwich') || 
      subtopicLower.includes('hot dog') || 
      subtopicLower.includes('bagel') || 
      subtopicLower.includes('pancake') || 
      subtopicLower.includes('waffle') || 
      subtopicLower.includes('dessert') || 
      subtopicLower.includes('bar') || 
      subtopicLower.includes('brewery') || 
      subtopicLower.includes('wine')) {
    return 'food-drink';
  }
  
  // Recreation & Fitness category
  if (subtopicLower.includes('gym') || 
      subtopicLower.includes('fitness') || 
      subtopicLower.includes('workout') || 
      subtopicLower.includes('crossfit') || 
      subtopicLower.includes('dance') || 
      subtopicLower.includes('pilates') || 
      subtopicLower.includes('yoga') || 
      subtopicLower.includes('hiit') || 
      subtopicLower.includes('bootcamp') || 
      subtopicLower.includes('basketball') || 
      subtopicLower.includes('soccer') || 
      subtopicLower.includes('tennis') || 
      subtopicLower.includes('volleyball') || 
      subtopicLower.includes('boxing') || 
      subtopicLower.includes('kickboxing') || 
      subtopicLower.includes('archery') || 
      subtopicLower.includes('climbing') || 
      subtopicLower.includes('golf') || 
      subtopicLower.includes('bowling') || 
      subtopicLower.includes('spa') || 
      subtopicLower.includes('massage') || 
      subtopicLower.includes('sauna')) {
    return 'recreation-fitness';
  }
  
  // Social & Nightlife category
  if (subtopicLower.includes('nightclub') || 
      subtopicLower.includes('club') || 
      subtopicLower.includes('lounge') || 
      subtopicLower.includes('speakeasy') || 
      subtopicLower.includes('cocktail') || 
      subtopicLower.includes('tapas') || 
      subtopicLower.includes('dive bar') || 
      subtopicLower.includes('rooftop') || 
      subtopicLower.includes('comedy') || 
      subtopicLower.includes('karaoke') || 
      subtopicLower.includes('jazz') || 
      subtopicLower.includes('piano') || 
      subtopicLower.includes('live music') || 
      subtopicLower.includes('dancing') || 
      subtopicLower.includes('latin') || 
      subtopicLower.includes('silent disco') || 
      subtopicLower.includes('pool') || 
      subtopicLower.includes('billiards') || 
      subtopicLower.includes('arcade') || 
      subtopicLower.includes('barcade')) {
    return 'social-nightlife';
  }
  
  // Shopping category
  if (subtopicLower.includes('thrift') || 
      subtopicLower.includes('vintage') || 
      subtopicLower.includes('antique') || 
      subtopicLower.includes('flea market') || 
      subtopicLower.includes('consignment') || 
      subtopicLower.includes('jewelry') || 
      subtopicLower.includes('boutique') || 
      subtopicLower.includes('designer') || 
      subtopicLower.includes('fashion') || 
      subtopicLower.includes('leather') || 
      subtopicLower.includes('plant') || 
      subtopicLower.includes('crystal') || 
      subtopicLower.includes('spiritual') || 
      subtopicLower.includes('handmade') || 
      subtopicLower.includes('artisan') || 
      subtopicLower.includes('pottery') || 
      subtopicLower.includes('ceramics') || 
      subtopicLower.includes('record') || 
      subtopicLower.includes('bookstore') || 
      subtopicLower.includes('comic') || 
      subtopicLower.includes('poster') || 
      subtopicLower.includes('pop-up') || 
      subtopicLower.includes('market') || 
      subtopicLower.includes('fair')) {
    return 'shopping-markets';
  }
  
  // Nature & Outdoors category
  if (subtopicLower.includes('hiking') || 
      subtopicLower.includes('lake') || 
      subtopicLower.includes('river') || 
      subtopicLower.includes('park') || 
      subtopicLower.includes('garden') || 
      subtopicLower.includes('scenic') || 
      subtopicLower.includes('viewpoint') || 
      subtopicLower.includes('paintball') || 
      subtopicLower.includes('shooting') || 
      subtopicLower.includes('obstacle') || 
      subtopicLower.includes('kayaking') || 
      subtopicLower.includes('canoeing') || 
      subtopicLower.includes('ziplining') || 
      subtopicLower.includes('atv') || 
      subtopicLower.includes('off-road') || 
      subtopicLower.includes('amusement') || 
      subtopicLower.includes('concert') || 
      subtopicLower.includes('festival') || 
      subtopicLower.includes('carnival') || 
      subtopicLower.includes('zoo') || 
      subtopicLower.includes('aquarium') || 
      subtopicLower.includes('petting zoo') || 
      subtopicLower.includes('farm')) {
    return 'nature-outdoors';
  }
  
  // Indoor Adventure category
  if (subtopicLower.includes('vr arcade') || 
      subtopicLower.includes('laser tag') || 
      subtopicLower.includes('nerf') || 
      subtopicLower.includes('escape room') || 
      subtopicLower.includes('go-kart') || 
      subtopicLower.includes('mini-golf') || 
      subtopicLower.includes('haunted house') || 
      subtopicLower.includes('immersive') || 
      subtopicLower.includes('theater') || 
      subtopicLower.includes('fantasy') || 
      subtopicLower.includes('tavern') || 
      subtopicLower.includes('convention') || 
      subtopicLower.includes('digital art') || 
      subtopicLower.includes('exhibit') || 
      subtopicLower.includes('projection') || 
      subtopicLower.includes('light show') || 
      subtopicLower.includes('sound show') || 
      subtopicLower.includes('movie theater') || 
      subtopicLower.includes('cinema')) {
    return 'indoor-adventure';
  }
  
  // Creative Arts category
  if (subtopicLower.includes('pottery') || 
      subtopicLower.includes('ceramics') || 
      subtopicLower.includes('sip and paint') || 
      subtopicLower.includes('printmaking') || 
      subtopicLower.includes('art studio') || 
      subtopicLower.includes('candle') || 
      subtopicLower.includes('soap') || 
      subtopicLower.includes('jewelry making') || 
      subtopicLower.includes('knitting') || 
      subtopicLower.includes('sewing') || 
      subtopicLower.includes('makerspace') || 
      subtopicLower.includes('diy') || 
      subtopicLower.includes('woodworking') || 
      subtopicLower.includes('leather craft') || 
      subtopicLower.includes('upcycling') || 
      subtopicLower.includes('embroidery') || 
      subtopicLower.includes('weaving') || 
      subtopicLower.includes('poetry') || 
      subtopicLower.includes('writing') || 
      subtopicLower.includes('storytelling') || 
      subtopicLower.includes('gallery') || 
      subtopicLower.includes('art tour') || 
      subtopicLower.includes('art lecture') || 
      subtopicLower.includes('art film') || 
      subtopicLower.includes('museum')) {
    return 'creative-arts';
  }
  
  // Sight-Seeing category
  if (subtopicLower.includes('museum') || 
      subtopicLower.includes('historical') || 
      subtopicLower.includes('monument') || 
      subtopicLower.includes('statue') || 
      subtopicLower.includes('church') || 
      subtopicLower.includes('temple') || 
      subtopicLower.includes('mosque') || 
      subtopicLower.includes('synagogue') || 
      subtopicLower.includes('landmark') || 
      subtopicLower.includes('castle') || 
      subtopicLower.includes('palace') || 
      subtopicLower.includes('bridge') || 
      subtopicLower.includes('observation') || 
      subtopicLower.includes('deck') || 
      subtopicLower.includes('square')) {
    return 'sight-seeing';
  }
  
  // Default to food-drink if no match found
  return 'food-drink';
};

// Function to get category color
const getCategoryColor = (categoryId: string): string => {
  const category = categories.find(cat => cat.id === categoryId);
  return category?.color || '#D7263D'; // Default to food-drink color
};

// Function to geocode address to coordinates
const geocodeAddress = async (address: string): Promise<{ latitude: number; longitude: number } | null> => {
  try {
    // Using a simple geocoding service (you can replace with Google Geocoding API)
    const response = await fetch(
      `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}&limit=1`
    );
    const data = await response.json();
    
    if (data && data.length > 0) {
      return {
        latitude: parseFloat(data[0].lat),
        longitude: parseFloat(data[0].lon)
      };
    }
    return null;
  } catch (error) {
    console.error('Geocoding error:', error);
    return null;
  }
};

// Function to get coordinates for a place
const getPlaceCoordinates = async (place: Place): Promise<{ latitude: number; longitude: number } | null> => {
  // First, try to use existing coordinates
  if (place.latitude && place.longitude) {
    return { latitude: place.latitude, longitude: place.longitude };
  }
  
  if (place.lat && place.lng) {
    return { latitude: place.lat, longitude: place.lng };
  }
  
  // If no coordinates, try to geocode the address
  if (place.address) {
    return await geocodeAddress(place.address);
  }
  
  return null;
};

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
  const insets = useSafeAreaInsets();
  const navbarHeight = insets.top + 4 + 48 + 1; // safe area + padding top + content height + padding bottom
  const searchBarTop = navbarHeight + 10; // navbar height + 10px spacing (moved up)
  const sheetExpandedTop = navbarHeight + 10;
  const sheetCollapsedTop = Dimensions.get('window').height * 0.7;
  const sheetTop = useRef(new RNAnimated.Value(sheetCollapsedTop)).current;
  const sheetTopValue = useRef(sheetCollapsedTop);

  useEffect(() => {
    const id = sheetTop.addListener(({ value }) => {
      sheetTopValue.current = value;
    });
    return () => sheetTop.removeListener(id);
  }, [sheetTop]);

  const [searchQuery, setSearchQuery] = useState('');
  const [places, setPlaces] = useState<Place[]>([]);
  const [filteredPlaces, setFilteredPlaces] = useState<Place[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState<FilterOption[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [activeTab, setActiveTab] = useState<string>('forYou');
  const [followingUsers, setFollowingUsers] = useState<any[]>([]);
  const [showMap, setShowMap] = useState(true);
  const [geocodedCoordinates, setGeocodedCoordinates] = useState<Record<string, { latitude: number; longitude: number }>>({});
  const [mapRef, setMapRef] = useState<MapView | null>(null);
  const [currentRegion, setCurrentRegion] = useState({
    latitude: 30.2672,
    longitude: -97.7431,
    latitudeDelta: 0.08,
    longitudeDelta: 0.08,
  });
  const [bottomSheetHeight, setBottomSheetHeight] = useState(SCREEN_WIDTH * 0.7);
  const [isDragging, setIsDragging] = useState(false);
  const [isSheetDown, setIsSheetDown] = useState(true);
  const [mapType, setMapType] = useState<'standard' | 'satellite' | 'hybrid'>('standard');
  const [selectedPlace, setSelectedPlace] = useState<Place | null>(null);

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
        let toValue;
        if (gestureState.dy < -50) {
          // Dragged up
          toValue = sheetExpandedTop;
        } else if (gestureState.dy > 50) {
          // Dragged down
          toValue = sheetCollapsedTop;
        } else {
          // Snap to nearest
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
    fetchPlaces();
    initializeFilters();
  }, []);

  // Handle geocoding for places without coordinates
  useEffect(() => {
    const geocodePlacesWithoutCoordinates = async () => {
      const placesToGeocode = places.filter(place => 
        !place.latitude && !place.longitude && !place.lat && !place.lng && place.address
      );

      for (const place of placesToGeocode) {
        if (!geocodedCoordinates[place.place_id]) {
          const coords = await geocodeAddress(place.address!);
          if (coords) {
            setGeocodedCoordinates(prev => ({
              ...prev,
              [place.place_id]: coords
            }));
          }
        }
      }
    };

    if (places.length > 0) {
      geocodePlacesWithoutCoordinates();
    }
  }, [places, geocodedCoordinates]);

  const handleTabChange = (tab: string) => {
    setActiveTab(tab);
    // TODO: Implement different data fetching logic based on tab
    console.log('Tab changed to:', tab);
  };

  useEffect(() => {
    filterPlaces();
  }, [searchQuery, filters, selectedCategory, places]);

    useEffect(() => {
    if (activeTab === 'following') {
      fetchFollowingUsers();
    }
  }, [activeTab]);


  const fetchFollowingUsers = async () => {
    setLoading(true);
    const { data: authData } = await supabase.auth.getUser();
    const userId = authData?.user?.id;
    if (!userId) return;

    const { data: followRows } = await supabase
      .from('follows')
      .select('following_id')
      .eq('follower_id', userId);

    const followingIds = followRows?.map((f) => f.following_id);
    if (!followingIds?.length) {
      setFollowingUsers([]);
      setLoading(false);
      return;
    }

    const { data: profilesData } = await supabase
      .from('profiles')
      .select('id, username, full_name, profile_picture, bio')
      .in('id', followingIds);

    setFollowingUsers(profilesData || []);
    setLoading(false);
  };

  const renderFollowingUser = ({ item }: { item: any }) => (
    <StyledTouchableOpacity className="flex-row items-center py-3 border-b border-gray-200">
      <Image
        source={item.profile_picture ? { uri: item.profile_picture } : require('../../assets/profilepic.png')}
        className="w-12 h-12 rounded-full mr-3"
      />
      <View>
        <AppText className="text-base font-bold">{item.full_name}</AppText>
        <AppText className="text-sm text-gray-500">@{item.username}</AppText>
      </View>
    </StyledTouchableOpacity>
  );





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

      const transformedPlaces = data?.map(place => {
        // Map database lat/lng to latitude/longitude for consistency
        const latitude = place.lat || place.latitude;
        const longitude = place.lng || place.longitude;
        
        return {
          ...place,
          image_url: place.image_url?.trim() || null,
          description: place.description || 'No description available',
          hours: place.hours || [],
          latitude: latitude,
          longitude: longitude,
          // Keep original lat/lng for backward compatibility
          lat: latitude,
          lng: longitude,
        };
      }) || [];

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

  // Zoom functions
  const zoomIn = () => {
    if (mapRef) {
      const newLatDelta = currentRegion.latitudeDelta * 0.5;
      const newLngDelta = currentRegion.longitudeDelta * 0.5;
      
      // Limit minimum zoom (maximum detail)
      const minDelta = 0.001;
      if (newLatDelta >= minDelta && newLngDelta >= minDelta) {
        mapRef.animateToRegion({
          latitude: currentRegion.latitude,
          longitude: currentRegion.longitude,
          latitudeDelta: newLatDelta,
          longitudeDelta: newLngDelta,
        }, 300);
      }
    }
  };

  const zoomOut = () => {
    if (mapRef) {
      const newLatDelta = currentRegion.latitudeDelta * 2;
      const newLngDelta = currentRegion.longitudeDelta * 2;
      
      // Limit maximum zoom (minimum detail)
      const maxDelta = 180;
      if (newLatDelta <= maxDelta && newLngDelta <= maxDelta) {
        mapRef.animateToRegion({
          latitude: currentRegion.latitude,
          longitude: currentRegion.longitude,
          latitudeDelta: newLatDelta,
          longitudeDelta: newLngDelta,
        }, 300);
      }
    }
  };

  const onRegionChangeComplete = (region: any) => {
    setCurrentRegion(region);
  };

  const renderPlaceCard = ({ item }: { item: Place }) => (
    <StyledTouchableOpacity
      onPress={() => setSelectedPlace(item)}
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
      {/* Image Section */}
      <StyledView style={{ position: 'relative' }}>
        <StyledView style={{ height: 120, backgroundColor: '#F3F4F6', justifyContent: 'center', alignItems: 'center' }}>
          {item.image_url ? (
            <Image
              source={{ uri: item.image_url }}
              style={{ width: '100%', height: '100%', resizeMode: 'cover' }}
            />
          ) : (
            <StyledView style={{ alignItems: 'center' }}>
              <Icon name="restaurant" size={32} color="#9CA3AF" />
              <AppText style={{ color: '#9CA3AF', marginTop: 8, fontSize: 12 }}>
                No image
              </AppText>
            </StyledView>
          )}
        </StyledView>

        {/* Rating Badge */}
        <StyledView 
          style={{
            position: 'absolute',
            top: 8,
            right: 8,
            backgroundColor: 'rgba(0,0,0,0.8)',
            paddingHorizontal: 6,
            paddingVertical: 3,
            borderRadius: 8,
            flexDirection: 'row',
            alignItems: 'center',
          }}
        >
          <Icon name="star" size={12} color="#FFD700" />
          <AppText style={{ color: 'white', fontSize: 11, fontWeight: 'bold', marginLeft: 2 }}>
            {item.rating?.toFixed(1) || 'N/A'}
          </AppText>
        </StyledView>

        {/* Category Badge */}
        <StyledView 
          style={{
            position: 'absolute',
            top: 8,
            left: 8,
            backgroundColor: getCategoryColor(getCategoryFromSubtopic(item.subtopic || '')),
            paddingHorizontal: 6,
            paddingVertical: 3,
            borderRadius: 8,
          }}
        >
          <AppText style={{ color: 'white', fontSize: 9, fontWeight: 'bold', textTransform: 'uppercase' }}>
            {item.subtopic || 'Food'}
          </AppText>
        </StyledView>
      </StyledView>

      {/* Content Section */}
      <StyledView style={{ padding: 12 }}>
        {/* Title and Price */}
        <StyledView style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 6 }}>
          <AppText 
            style={{ 
              fontSize: 16, 
              fontWeight: 'bold', 
              color: '#1F2937',
              flex: 1,
              marginRight: 8,
            }}
            numberOfLines={1}
          >
            {item.name}
          </AppText>
          {item.price_range && (
            <AppText style={{ fontSize: 14, color: '#059669', fontWeight: '700' }}>
              {'$'.repeat(item.price_range)}
            </AppText>
          )}
        </StyledView>

        {/* Rating and Description */}
        <StyledView style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 8 }}>
          <StyledView 
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              backgroundColor: '#FEF3C7',
              paddingHorizontal: 6,
              paddingVertical: 2,
              borderRadius: 8,
              marginRight: 8,
            }}
          >
            <Icon name="star" size={12} color="#F59E0B" />
            <AppText style={{ fontSize: 11, color: '#92400E', fontWeight: '600', marginLeft: 2 }}>
              {item.rating?.toFixed(1) || 'N/A'}
            </AppText>
          </StyledView>
        </StyledView>

        <AppText 
          style={{ 
            fontSize: 13, 
            color: '#6B7280', 
            lineHeight: 18,
            marginBottom: 12,
          }}
          numberOfLines={2}
        >
          {item.description}
        </AppText>

        {/* Action Buttons */}
        <StyledView style={{ flexDirection: 'row' }}>
          <StyledTouchableOpacity
            style={{
              flex: 1,
              backgroundColor: '#F3F4F6',
              paddingVertical: 8,
              paddingHorizontal: 12,
              borderRadius: 8,
              alignItems: 'center',
              marginRight: 8,
            }}
            onPress={() => console.log('Get directions to:', item.name)}
          >
            <StyledView style={{ flexDirection: 'row', alignItems: 'center' }}>
              <Icon name="directions" size={14} color="#6B7280" />
              <AppText style={{ fontSize: 12, color: '#6B7280', fontWeight: '600', marginLeft: 4 }}>
                Directions
              </AppText>
            </StyledView>
          </StyledTouchableOpacity>

          <StyledTouchableOpacity
            style={{
              flex: 1,
              backgroundColor: COLORS.mint,
              paddingVertical: 8,
              paddingHorizontal: 12,
              borderRadius: 8,
              alignItems: 'center',
            }}
            onPress={() => console.log('Save:', item.name)}
          >
            <StyledView style={{ flexDirection: 'row', alignItems: 'center' }}>
              <Icon name="favorite-border" size={14} color="white" />
              <AppText style={{ fontSize: 12, color: 'white', fontWeight: '600', marginLeft: 4 }}>
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
      <DiscoverTopNavBar currentUser={currentUser} />

      {/* Search Bar - Moved below navbar */}
      <StyledView 
        style={{
          position: 'absolute',
          top: searchBarTop,
          left: 16,
          right: 16,
          zIndex: 10,
        }}
      >
        <StyledView 
          style={{
            backgroundColor: 'white',
            borderRadius: 25,
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 0.1,
            shadowRadius: 8,
            elevation: 4,
            borderWidth: 1,
            borderColor: '#E5E7EB',
          }}
        >
          <StyledTextInput
            className="px-4 py-3 text-gray-900"
            placeholder="Search places, cuisines..."
            placeholderTextColor="#9CA3AF"
            value={searchQuery}
            onChangeText={setSearchQuery}
            style={{
              fontSize: 16,
            }}
          />
        </StyledView>
      </StyledView>

      {/* Full Screen Map */}
      <StyledView style={{ flex: 1, position: 'relative' }}>
        <MapView
          style={{ flex: 1 }}
          initialRegion={currentRegion}
          region={currentRegion}
          showsUserLocation
          customMapStyle={modernMapStyle}
          ref={setMapRef}
          onRegionChangeComplete={onRegionChangeComplete}
          mapType={mapType}
        >
          {filteredPlaces.map((place, idx) => {
            const categoryId = getCategoryFromSubtopic(place.subtopic || '');
            const categoryColor = getCategoryColor(categoryId);
            const rating = place.rating || 0;
            
            // Get coordinates with fallbacks
            const coordinates = geocodedCoordinates[place.place_id] || 
              (place.latitude && place.longitude ? { latitude: place.latitude, longitude: place.longitude } : null) ||
              (place.lat && place.lng ? { latitude: place.lat, longitude: place.lng } : null) ||
              { latitude: 30.2672 + 0.01 * (idx % 5), longitude: -97.7431 + 0.01 * (idx % 5) };
            
            return (
              <Marker
                key={place.place_id || idx}
                coordinate={coordinates}
                title={place.name}
                description={place.description}
                pinColor={categoryColor}
                tracksViewChanges={false}
                onPress={() => setSelectedPlace(place)}
              >
                {/* Zillow-style marker with rating */}
                <StyledView 
                  style={{
                    backgroundColor: categoryColor,
                    borderWidth: 2,
                    borderColor: 'white',
                    borderRadius: 8,
                    paddingHorizontal: 8,
                    paddingVertical: 4,
                    shadowColor: '#000',
                    shadowOffset: { width: 0, height: 2 },
                    shadowOpacity: 0.25,
                    shadowRadius: 4,
                    elevation: 5,
                    minWidth: 40,
                    alignItems: 'center',
                  }}
                >
                  <AppText 
                    style={{
                      color: 'white',
                      fontSize: 12,
                      fontWeight: 'bold',
                      textAlign: 'center',
                    }}
                  >
                    {rating > 0 ? rating.toFixed(1) : 'N/A'}
                  </AppText>
                </StyledView>
              </Marker>
            );
          })}
        </MapView>

        {/* Map Controls - Zoom, Map Type */}
        <StyledView className="absolute right-4 z-10" style={{ top: searchBarTop + 45 }}>
          {/* Zoom Controls */}
          <StyledView className="bg-white rounded-3xl shadow-lg mb-3 overflow-hidden">
            <StyledTouchableOpacity
              onPress={zoomIn}
              disabled={currentRegion.latitudeDelta <= 0.001}
              className={`w-12 h-12 items-center justify-center border-b border-gray-200 ${
                currentRegion.latitudeDelta <= 0.001 ? 'bg-gray-100' : 'bg-white'
              }`}
            >
              <Icon 
                name="add" 
                size={24} 
                color={currentRegion.latitudeDelta <= 0.001 ? '#9CA3AF' : COLORS.mint} 
              />
            </StyledTouchableOpacity>
            
            <StyledTouchableOpacity
              onPress={zoomOut}
              disabled={currentRegion.latitudeDelta >= 180}
              className={`w-12 h-12 items-center justify-center ${
                currentRegion.latitudeDelta >= 180 ? 'bg-gray-100' : 'bg-white'
              }`}
            >
              <Icon 
                name="remove" 
                size={24} 
                color={currentRegion.latitudeDelta >= 180 ? '#9CA3AF' : COLORS.mint} 
              />
            </StyledTouchableOpacity>
          </StyledView>

          {/* Map Type Toggle */}
          <StyledTouchableOpacity
            onPress={() => {
              if (mapType === 'standard') {
                setMapType('satellite');
              } else if (mapType === 'satellite') {
                setMapType('hybrid');
              } else {
                setMapType('standard');
              }
            }}
            className="w-12 h-12 bg-white rounded-3xl shadow-lg items-center justify-center"
          >
            <Icon 
              name={mapType === 'standard' ? 'map' : mapType === 'satellite' ? 'satellite' : 'layers'} 
              size={24} 
              color={COLORS.mint} 
            />
          </StyledTouchableOpacity>
        </StyledView>

        {/* Zillow-style Popup above bottom sheet */}
        {selectedPlace && isSheetDown && (
          <StyledView
            className="absolute left-0 right-0 items-center"
            style={{
              bottom: Dimensions.get('window').height - sheetCollapsedTop - 95,
              zIndex: 10,
            }}
            pointerEvents="none"
          >
            <StyledView className="w-80 bg-white rounded-2xl shadow-lg border border-gray-200 overflow-hidden">
              <StyledTouchableOpacity
                className="absolute top-2 right-2 bg-white border-mint p-2 rounded-full z-20"
                onPress={() => console.log('Save place:', selectedPlace.name)}
              >
                <Icon name="favorite-border" size={18} color={COLORS.mint} />
              </StyledTouchableOpacity>
              {/* Image Section */}
              <StyledView className="h-36 bg-gray-100 justify-center items-center relative">
                {selectedPlace.image_url ? (
                  <Image
                    source={{ uri: selectedPlace.image_url }}
                    style={{ width: '100%', height: '100%', resizeMode: 'cover' }}
                  />
                ) : (
                  <StyledView className="items-center">
                    <Icon name="restaurant" size={40} color="#9CA3AF" />
                    <AppText className="text-gray-400 mt-2 text-base">No image available</AppText>
                  </StyledView>
                )}

                  <StyledTouchableOpacity
                      className="flex-1 bg-gray-100 py-2 rounded-lg items-center flex-row justify-center"
                      onPress={() => console.log('Save place:', selectedPlace.name)}
                    >
                      <Icon name="favorite-border" size={14} color={COLORS.mint} />
                      <AppText className="text-mint font-semibold ml-1 text-xs">Save</AppText>
                    </StyledTouchableOpacity>
                {/* Category Badge */}
                <StyledView className="absolute top-3 left-3 px-2 py-1 rounded-lg" style={{ backgroundColor: getCategoryColor(getCategoryFromSubtopic(selectedPlace.subtopic || '')) }}>
                  <AppText className="text-white text-xs font-bold uppercase">
                    {selectedPlace.subtopic || 'Food'}
                  </AppText>
                </StyledView>
              </StyledView>
              {/* Content Section */}
              <StyledView className="flex-row w-80 p-3">

                {/* Right: Info and Actions */}
                <StyledView className="flex-1 justify-between">
                  {/* Title and Rating Row */}
                  <StyledView className="flex-row items-center mb-1">
                    <AppText className="font-bold text-base text-gray-900 flex-1 mr-2" numberOfLines={1}>
                      {selectedPlace.name}
                    </AppText>
                    <StyledTouchableOpacity
                      className="bg-mint px-2 py-1 rounded-lg items-center flex-row justify-center"
                      onPress={() => console.log('Get directions to:', selectedPlace.name)}
                    >
                      <Icon name="directions" size={12} color="white" />
                      <AppText className="text-white font-semibold ml-1 text-xs">Directions</AppText>
                    </StyledTouchableOpacity>
                  </StyledView>
                  {/* Second row: rating and price side by side */}
                  <StyledView className="flex-row items-center space-x-2 mb-1">
                    <StyledView className="flex-row items-center bg-yellow-100 px-2 py-1 rounded-lg">
                      <Icon name="star" size={12} color="#F59E0B" />
                      <AppText className="text-yellow-800 text-xs font-semibold ml-1">
                        {selectedPlace.rating?.toFixed(1) || 'N/A'}
                      </AppText>
                    </StyledView>
                    {selectedPlace.price_range && (
                      <AppText className="text-green-600 font-bold">
                        {'$'.repeat(selectedPlace.price_range)}
                      </AppText>
                    )}
                  </StyledView>
                  {/* Description */}
                  <AppText className="text-gray-500 text-xs mb-2" numberOfLines={2}>
                    {selectedPlace.description || 'No description available'}
                  </AppText>
                </StyledView>
              </StyledView>
            </StyledView>
          </StyledView>
        )}

        {/* Draggable Bottom Sheet */}
        <RNAnimated.View 
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            top: sheetTop,
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
          }}
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
                <StyledTouchableOpacity
                  onPress={() => setShowFilters(!showFilters)}
                  className={`px-3 py-2 rounded-full flex-row items-center ${showFilters ? 'bg-mint' : 'bg-gray-100'}`}
                >
                  <Icon 
                    name="tune" 
                    size={16} 
                    color={showFilters ? 'white' : '#6B7280'} 
                  />
                  <AppText className={`text-base font-semibold ml-1 ${showFilters ? 'text-white' : 'text-gray-600'}`}>Filters</AppText>
                </StyledTouchableOpacity>
              </StyledView>
            </StyledView>
          </StyledView>

          {/* Filters Section */}
          {showFilters && (
            <StyledView className="px-4 pb-4">
              <StyledView className="bg-gray-50 rounded-2xl p-4 border border-gray-200">
                <StyledView className="flex-row justify-between items-center mb-3">
                  <AppText className="text-lg font-semibold text-gray-900">
                    Filter by Category
                  </AppText>
                  <StyledTouchableOpacity onPress={clearFilters}>
                    <AppText className="text-base font-semibold text-mint">Clear All</AppText>
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
            </StyledView>
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
        </RNAnimated.View>
      </StyledView>

      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
