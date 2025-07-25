import React from 'react';
import { View, Dimensions } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import DiscoverTopNavBar from './components/Navbar';
import BottomNavBar from '../../components/BottomNavBar';
import Map, { modernMapStyle } from './components/Map';
import MapControls from './components/MapControls';
import SearchBar from './components/SearchBar';
import PlacePopup from './components/PlacePopup';
import DraggableBottomSheet from './components/DraggableBottomSheet';
import { getCategoryFromSubtopic, getCategoryColor } from './components/CategoryMapper';
import { COLORS } from '../../theme/colors';
import { useDiscoverState } from './hooks/useDiscoverState';

export default function DiscoverScreen({ route }: { route: any }) {
  const currentUser = route?.params?.currentUser;
  const insets = useSafeAreaInsets();
  const navbarHeight = insets.top + 4 + 48 + 1;
  const searchBarTop = navbarHeight + 10;
  const sheetCollapsedTop = Dimensions.get('window').height * 0.7;

  // Use custom hook for all state
  const state = useDiscoverState(sheetCollapsedTop);

  return (
    <View style={{ flex: 1, backgroundColor: '#FAF6F2' }}>
      <DiscoverTopNavBar currentUser={currentUser} />
      <SearchBar
        searchQuery={state.searchQuery}
        setSearchQuery={state.setSearchQuery}
        searchBarTop={searchBarTop}
      />
      <View style={{ flex: 1, position: 'relative' }}>
        <Map
          currentRegion={state.currentRegion}
          filteredPlaces={state.filteredPlaces}
          geocodedCoordinates={state.geocodedCoordinates}
          setGeocodedCoordinates={state.setGeocodedCoordinates}
          places={state.places}
          setSelectedPlace={state.setSelectedPlace}
          getCategoryFromSubtopic={getCategoryFromSubtopic}
          getCategoryColor={getCategoryColor}
          mapType={state.mapType}
          setMapRef={state.setMapRef}
          setCurrentRegion={state.setCurrentRegion}
          modernMapStyle={modernMapStyle}
        />
        <MapControls
          mapRef={state.mapRef}
          currentRegion={state.currentRegion}
          mapType={state.mapType}
          setMapType={state.setMapType}
          COLORS={COLORS}
          searchBarTop={searchBarTop}
        />
        <PlacePopup
          selectedPlace={state.selectedPlace}
          isSheetDown={state.isSheetDown}
          sheetCollapsedTop={sheetCollapsedTop}
          getCategoryColor={getCategoryColor}
          getCategoryFromSubtopic={getCategoryFromSubtopic}
          COLORS={COLORS}
        />
        <DraggableBottomSheet
          showFilters={state.showFilters}
          setShowFilters={state.setShowFilters}
          filters={state.filters}
          setFilters={state.setFilters}
          setSelectedCategory={state.setSelectedCategory}
          setSearchQuery={state.setSearchQuery}
          loading={state.loading}
          setLoading={state.setLoading}
          refreshing={state.refreshing}
          setRefreshing={state.setRefreshing}
          activeTab={state.activeTab}
          followingUsers={state.followingUsers}
          places={state.places}
          setPlaces={state.setPlaces}
          filteredPlaces={state.filteredPlaces}
          setFilteredPlaces={state.setFilteredPlaces}
          searchQuery={state.searchQuery}
          sheetCollapsedTop={sheetCollapsedTop}
          navbarHeight={navbarHeight}
          setIsSheetDown={state.setIsSheetDown}
          setSelectedPlace={state.setSelectedPlace}
        />
      </View>
      <BottomNavBar currentUser={currentUser} />
    </View>
  );
}
