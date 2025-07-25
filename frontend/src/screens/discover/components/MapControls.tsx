import React from 'react';
import { View, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';

const StyledView = styled(View);
// Remove StyledTouchableOpacity, use TouchableOpacity from react-native

interface MapControlsProps {
  mapRef: any;
  currentRegion: { latitude: number; longitude: number; latitudeDelta: number; longitudeDelta: number };
  mapType: 'standard' | 'satellite' | 'hybrid';
  setMapType: (type: 'standard' | 'satellite' | 'hybrid') => void;
  COLORS: any;
  searchBarTop: number;
}

const MapControls: React.FC<MapControlsProps> = ({
  mapRef,
  currentRegion,
  mapType,
  setMapType,
  COLORS,
  searchBarTop,
}) => {
  const zoomIn = () => {
    if (mapRef) {
      const newLatDelta = currentRegion.latitudeDelta * 0.5;
      const newLngDelta = currentRegion.longitudeDelta * 0.5;
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

  return (
    <StyledView className="absolute right-4 z-10" style={{ top: searchBarTop }}>
      {/* Zoom Controls */}
      <StyledView className="bg-white rounded-3xl shadow-lg mb-3 overflow-hidden">
        <TouchableOpacity
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
        </TouchableOpacity>

        <TouchableOpacity
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
        </TouchableOpacity>
      </StyledView>

      {/* Map Type Toggle */}
      <TouchableOpacity
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
          name={
            mapType === 'standard'
              ? 'map'
              : mapType === 'satellite'
              ? 'satellite'
              : 'layers'
          }
          size={24}
          color={COLORS.mint}
        />
      </TouchableOpacity>
    </StyledView>
  );
};

export default MapControls; 