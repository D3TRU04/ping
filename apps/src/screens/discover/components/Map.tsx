import React, { useEffect } from 'react';
import { View, Dimensions, Image } from 'react-native';
import MapView, { Marker } from 'react-native-maps';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';

const StyledView = styled(View);

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

interface MapProps {
  currentRegion: any;
  filteredPlaces: Place[];
  geocodedCoordinates: Record<string, { latitude: number; longitude: number }>;
  setGeocodedCoordinates: React.Dispatch<React.SetStateAction<Record<string, { latitude: number; longitude: number }>>>;
  places: Place[];
  setSelectedPlace: (place: Place) => void;
  getCategoryFromSubtopic: (subtopic: string) => string;
  getCategoryColor: (categoryId: string) => string;
  mapType: 'standard' | 'satellite' | 'hybrid';
  setMapRef: (ref: MapView | null) => void;
  setCurrentRegion: (region: any) => void;
  modernMapStyle: any;
}

// Function to geocode address to coordinates
const geocodeAddress = async (address: string): Promise<{ latitude: number; longitude: number } | null> => {
  try {
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
    return null;
  }
};

// Function to get coordinates for a place
export const getPlaceCoordinates = async (place: Place): Promise<{ latitude: number; longitude: number } | null> => {
  if (place.latitude && place.longitude) {
    return { latitude: place.latitude, longitude: place.longitude };
  }
  if (place.lat && place.lng) {
    return { latitude: place.lat, longitude: place.lng };
  }
  if (place.address) {
    return await geocodeAddress(place.address);
  }
  return null;
};

// Modern map style
export const modernMapStyle = [
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

const Map: React.FC<MapProps> = ({
  currentRegion,
  filteredPlaces,
  geocodedCoordinates,
  setGeocodedCoordinates,
  places,
  setSelectedPlace,
  getCategoryFromSubtopic,
  getCategoryColor,
  mapType,
  setMapRef,
  setCurrentRegion,
  modernMapStyle,
}) => {
  useEffect(() => {
    const geocodePlacesWithoutCoordinates = async () => {
      const placesToGeocode = places.filter(place => 
        !place.latitude && !place.longitude && !place.lat && !place.lng && place.address
      );
      for (const place of placesToGeocode) {
        if (!geocodedCoordinates[place.place_id]) {
          const coords = await getPlaceCoordinates(place);
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
  }, [places, geocodedCoordinates, setGeocodedCoordinates]);

  const onRegionChangeComplete = (region: any) => {
    setCurrentRegion(region);
  };

  return (
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
  );
};

export default Map; 