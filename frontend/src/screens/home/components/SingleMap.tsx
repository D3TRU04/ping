// home/components/SingleMap.tsx
import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import MapboxGL from '@rnmapbox/maps';
import Constants from 'expo-constants';

const token = Constants.expoConfig?.extra?.EXPO_PUBLIC_MAPBOX_TOKEN;
MapboxGL.setAccessToken(token);

const StyledView = styled(View);

interface SingleMapProps {
  places: Array<{ id: any; name: any; longitude: any; latitude: any }>;
}

export default function SingleMap({ places }: SingleMapProps) {
  if (!places || places.length === 0) {
    return (
      <StyledView className="w-full h-80 bg-gray-100 justify-center items-center">
        <StyledView className="text-gray-500">No places to display</StyledView>
      </StyledView>
    );
  }

  // Calculate center point from all places
  const centerLongitude = places.reduce((sum, place) => sum + place.longitude, 0) / places.length;
  const centerLatitude = places.reduce((sum, place) => sum + place.latitude, 0) / places.length;

  return (
    <StyledView className="w-full h-80 bg-white">
      <MapboxGL.MapView
        style={{ width: '100%', height: 320 }}
        styleURL={MapboxGL.StyleURL.Street}
      >
        <MapboxGL.Camera 
          zoomLevel={10} 
          centerCoordinate={[centerLongitude, centerLatitude]} 
        />
        
        {/* Add markers for all places */}
        {places.map((place, index) => (
          <MapboxGL.PointAnnotation
            key={`${place.id}-${index}`}
            id={`marker-${place.id}`}
            coordinate={[place.longitude, place.latitude]}
          >
            <View style={{ width: 20, height: 20, backgroundColor: 'red', borderRadius: 10 }} />
          </MapboxGL.PointAnnotation>
        ))}
      </MapboxGL.MapView>
    </StyledView>
  );
}
