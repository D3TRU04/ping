import { useState } from 'react';
import MapView from 'react-native-maps';
import { Place, FilterOption } from '../types/types';

export function useDiscoverState(sheetCollapsedTop: number) {
  const [searchQuery, setSearchQuery] = useState('');
  const [places, setPlaces] = useState<Place[]>([]);
  const [filteredPlaces, setFilteredPlaces] = useState<Place[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState<FilterOption[]>([]);
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [activeTab, setActiveTab] = useState('forYou');
  const [followingUsers, setFollowingUsers] = useState<any[]>([]);
  const [geocodedCoordinates, setGeocodedCoordinates] = useState<Record<string, { latitude: number; longitude: number }>>({});
  const [mapRef, setMapRef] = useState<MapView | null>(null);
  const [currentRegion, setCurrentRegion] = useState({
    latitude: 30.2672,
    longitude: -97.7431,
    latitudeDelta: 0.08,
    longitudeDelta: 0.08,
  });
  const [isSheetDown, setIsSheetDown] = useState(true);
  const [mapType, setMapType] = useState<'standard' | 'satellite' | 'hybrid'>('standard');
  const [selectedPlace, setSelectedPlace] = useState<Place | null>(null);

  return {
    searchQuery, setSearchQuery,
    places, setPlaces,
    filteredPlaces, setFilteredPlaces,
    loading, setLoading,
    refreshing, setRefreshing,
    showFilters, setShowFilters,
    filters, setFilters,
    selectedCategory, setSelectedCategory,
    activeTab, setActiveTab,
    followingUsers, setFollowingUsers,
    geocodedCoordinates, setGeocodedCoordinates,
    mapRef, setMapRef,
    currentRegion, setCurrentRegion,
    isSheetDown, setIsSheetDown,
    mapType, setMapType,
    selectedPlace, setSelectedPlace,
  };
} 