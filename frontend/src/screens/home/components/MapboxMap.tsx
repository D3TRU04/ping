// frontend/src/components/MapboxMap.tsx
import React, { useState } from 'react';
import { View } from 'react-native';
import MapboxGL from '@rnmapbox/maps';

interface MapboxMapProps {
  longitude: number;
  latitude: number;
  zoom?: number;
  pitch?: number;
  heading?: number;
  show3DBuildings?: boolean;
  showTerrain?: boolean;
  style?: any;
  height?: number;
  width?: string | number; // Allow both string and number
}

export default function MapboxMap({
  longitude,
  latitude,
  zoom = 15,
  pitch = 63,
  heading = 45,
  show3DBuildings = true,
  showTerrain = false,
  style,
  height = 320,
  width = '100%'
}: MapboxMapProps) {
  const [is3DEnabled, setIs3DEnabled] = useState(showTerrain);

  return (
    <MapboxGL.MapView
      style={[{ width, height }, style]} // Make sure style is an object, not a string
      styleURL={MapboxGL.StyleURL.Outdoors}
      scrollEnabled={true}
      zoomEnabled={true}
      rotateEnabled={true}
      pitchEnabled={true}
    >


      <MapboxGL.Camera
      zoomLevel={zoom}
      centerCoordinate={[longitude, latitude]}
      pitch={pitch}
      heading={heading}
      animationMode="flyTo"
      animationDuration={1000}
      />

      {/* Terrain Data */}
      {showTerrain && (
      <MapboxGL.VectorSource id="mapbox-dem" url="mapbox://mapbox.mapbox-terrain-dem-v1">
        <MapboxGL.Terrain sourceID="mapbox-dem" exaggeration={1.5} />
      </MapboxGL.VectorSource>
      )}

      {/* 3D Buildings */}
      {show3DBuildings && (
      <MapboxGL.VectorSource id="composite" url="mapbox://mapbox.mapbox-streets-v8">
        <MapboxGL.FillExtrusionLayer
          id="3d-buildings"
          sourceLayerID="building"
          minZoomLevel={0}
          maxZoomLevel={77}
          style={{
            fillExtrusionColor: '#aaa',
            fillExtrusionOpacity: 1.0,
          }}
          filter={['==', 'extrude', 'true']}
        />
      </MapboxGL.VectorSource>
      )}

      {/* Marker */}
      <MapboxGL.PointAnnotation id="marker" coordinate={[longitude, latitude]}>
      <View style={{ width: 17, height: 17, backgroundColor: '#1FC9C3', borderRadius: 10 }} />
      </MapboxGL.PointAnnotation>
    </MapboxGL.MapView>
  );
}




