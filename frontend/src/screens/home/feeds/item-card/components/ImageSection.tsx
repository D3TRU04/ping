// home/feeds/item-card/components/ImageSection.tsx
import React, { useRef, useState } from 'react';
import { View, Image, Pressable, Animated } from 'react-native';
import Constants from 'expo-constants';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import MapboxGL from '@rnmapbox/maps';
import AppText from '../../../../../components/AppText';
import TopActionButtons from './TopActionButtons';
import { categories } from '../../../../auth/onboarding/data';

const token = Constants.expoConfig?.extra?.EXPO_PUBLIC_MAPBOX_TOKEN;
MapboxGL.setAccessToken(token);
console.log(token);



const StyledView = styled(View);
const StyledImage = styled(Image);

function getDisplayNameFromValue(value: string): string {
  for (const cat of categories) {
    const match = cat.subcategories.find(sub => sub.value === value);
    if (match) return match.name;
  }
  return value;
}

interface ImageSectionProps {
  imageUrl?: string;
  imageFailed: boolean;
  onImageError: () => void;
  subtopic?: string;
  isLiked: boolean;
  isSaved: boolean;
  onLike: () => void;
  onSave: () => void;
  onShare: () => void;
  longitude: number;
  latitude: number;
}

export default function ImageSection({
  imageUrl,
  imageFailed,
  onImageError,
  subtopic,
  isLiked,
  isSaved,
  onLike,
  onSave,
  onShare,
  longitude,
  latitude
}: ImageSectionProps) {
  // Debug: Print coordinates
  console.log('ImageSection coordinates:', { longitude, latitude, subtopic });


  const [is3DEnabled, setIs3DEnabled] = useState(false);
  const toggle3D = () => setIs3DEnabled(!is3DEnabled);
  
  const lastTap = useRef<number>(0);
  const [showHeart, setShowHeart] = useState(false);
  const heartOpacity = useRef(new Animated.Value(0)).current;

  const handleDoubleTap = () => {
    const now = Date.now();
    if (lastTap.current && now - lastTap.current < 300) {
      // Double tap detected
      if (!isLiked) {
        onLike(); // Only like if not already liked
      }
      triggerHeartAnimation(); // Always show heart
    }
    lastTap.current = now;
  };

  const triggerHeartAnimation = () => {
    setShowHeart(true);
    Animated.sequence([
      Animated.timing(heartOpacity, {
        toValue: 1,
        duration: 150,
        useNativeDriver: true,
      }),
      Animated.timing(heartOpacity, {
        toValue: 0,
        duration: 300,
        delay: 300,
        useNativeDriver: true,
      }),
    ]).start(() => setShowHeart(false));
  };

  return (
    <StyledView className="relative bg-white">
      <Pressable onPress={handleDoubleTap}>
        {/* {imageUrl && !imageFailed ? (
          <StyledImage
            source={{ uri: imageUrl }}
            className="w-full h-80"
            resizeMode="cover"
            onError={onImageError}
          />
        ) : (
          <StyledView className="w-full h-80 bg-gradient-to-br from-gray-200 to-gray-300 justify-center items-center">
            <Icon name="restaurant" size={48} color="#9CA3AF" />
            <AppText className="text-gray-500 mt-2">No image available</AppText>
          </StyledView>
        )} */}

        <MapboxGL.MapView
          style={{ width: '100%', height: 320 }}
          styleURL={MapboxGL.StyleURL.Street} // or .Street
        >
          <MapboxGL.Camera
            zoomLevel={15.5}
            centerCoordinate={[longitude, latitude]}
            pitch={63}
            heading={45}
            animationMode="flyTo"
            animationDuration={1000}
          />

          
          {/* ⛰️ Elevation Data */}
          {is3DEnabled && (
            <>
              <MapboxGL.VectorSource id="mapbox-dem" url="mapbox://mapbox.mapbox-terrain-dem-v1">
                <MapboxGL.Terrain sourceID="mapbox-dem" exaggeration={1.5} />
              </MapboxGL.VectorSource>
            </>
          )}


          {/* 🏙️ 3D Buildings */}
          <MapboxGL.VectorSource id="composite" url="mapbox://mapbox.mapbox-streets-v8">
            <MapboxGL.FillExtrusionLayer
              id="3d-buildings"
              sourceLayerID="building"
              minZoomLevel={0}
              maxZoomLevel={65}
              style={{
                fillExtrusionColor: '#aaa',
                fillExtrusionHeight: ['get', 'height'],
                fillExtrusionBase: ['get', 'min_height'],
                fillExtrusionOpacity: 1.0,
              }}
              filter={['==', 'extrude', 'true']}
            />
          </MapboxGL.VectorSource>


          {/* 📍 Marker */}
          {/* <MapboxGL.PointAnnotation id="marker" coordinate={[longitude, latitude]} /> */}
          <MapboxGL.PointAnnotation id="marker" coordinate={[longitude, latitude]}>
            <View style={{ width: 20, height: 20, backgroundColor: 'red', borderRadius: 10 }} />
          </MapboxGL.PointAnnotation>
        </MapboxGL.MapView>


        {/* Animated Heart */}
        {showHeart && (
          <Animated.View
            style={{
              position: 'absolute',
              top: '40%',
              left: '45%',
              opacity: heartOpacity,
              transform: [{ scale: heartOpacity }],
            }}
          >
            <Icon name="favorite" size={64} color="#FF5C5C" />
          </Animated.View>
        )}
      </Pressable>

      {/* Top Right Action Buttons */}
      <TopActionButtons
        isLiked={isLiked}
        isSaved={isSaved}
        onLike={onLike}
        onSave={onSave}
        onShare={onShare}
      />

      {/* Category Badge */}
      {/* {subtopic && (
        <StyledView className="absolute top-4 left-4">
          <StyledView className="bg-white/90 px-3 py-1 rounded-full shadow-sm">
            <AppText className="text-sm text-gray-800">
              {getDisplayNameFromValue(subtopic)}
            </AppText>
          </StyledView>
        </StyledView>
      )} */}
    </StyledView>
  );
}
