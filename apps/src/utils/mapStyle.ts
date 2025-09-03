// frontend/src/utils/mapStyles.ts

export const dawnStyleJSON = {
    version: 8,
    sources: {
      'mapbox-streets': {
        type: 'vector',
        url: 'mapbox://mapbox.mapbox-streets-v8'
      }
    },
    layers: [
      {
        id: 'background',
        type: 'background',
        paint: {
          'background-color': '#FFE5B4' // Warm dawn color
        }
      },
      {
        id: 'land',
        type: 'fill',
        source: 'mapbox-streets',
        'source-layer': 'landuse',
        paint: {
          'fill-color': '#FFF8DC',
          'fill-opacity': 0.8
        }
      },
      {
        id: 'water',
        type: 'fill',
        source: 'mapbox-streets',
        'source-layer': 'water',
        paint: {
          'fill-color': '#B0E0E6',
          'fill-opacity': 0.6
        }
      }
    ]
  };
  
  export const duskStyleJSON = {
    version: 8,
    name: 'Complete Streets v8 3D - Dusk Custom',
    sources: {
      composite: {
        url: 'mapbox://mapbox.mapbox-streets-v8',
        type: 'vector',
      },
    },
    layers: [
      {
        id: 'background',
        type: 'background',
        paint: {
          'background-color': '#ffffff', // <-- Your custom dusk color
        },
      },
      {
        id: 'water',
        type: 'fill',
        source: 'composite',
        'source-layer': 'water',
        paint: {
          'fill-color': '#9dd4fa',
        },
      },
      {
        id: 'landuse',
        type: 'fill',
        source: 'composite',
        'source-layer': 'landuse',
        paint: {
          'fill-color': '#e6e6e6',
        },
      },
      {
        id: "parks",
        type: "fill",
        source: "composite",
        'source-layer': "landuse",
        filter: ["==", "class", "park"],
        paint: {
          "fill-color": "#c7f5c4"
        }
      },
      {
        id: 'motorways',
        type: 'line',
        source: 'composite',
        'source-layer': 'road',
        filter: ['==', 'class', 'motorway'],
        paint: { 'line-color': '#8e8f9c' }
      },
      {
        id: 'trunk',
        type: 'line',
        source: 'composite',
        'source-layer': 'road',
        filter: ['==', 'class', 'trunk'],
        paint: { 'line-color': '#b4b2d0' }
      },
      {
        id: 'street',
        type: 'line',
        source: 'composite',
        'source-layer': 'road',
        filter: ['==', 'class', 'street'],
        paint: { 'line-color': '#c8c7df' }
      },
      {
        id: 'road',
        type: 'line',
        source: 'composite',
        'source-layer': 'road',
        paint: {
          'line-color': '#ffffff',
        },
      },
      {
        id: 'building',
        type: 'fill-extrusion',
        source: 'composite',
        'source-layer': 'building',
        paint: {
        //   'fill-extrusion-color': '#aaa',
          'fill-extrusion-height': ['get', 'height'],
          'fill-extrusion-base': ['get', 'min_height'],
          'fill-extrusion-opacity': 1,
        'fill-extrusion-color': ['interpolate', ['linear'], ['zoom'],
        15, '#705c55',
        18, '#ffffff'
        ],
        // 'fill-extrusion-opacity': 0.9

        },
      },
      {
        id: 'poi_label',
        type: 'symbol',
        source: 'composite',
        'source-layer': 'poi_label',
        layout: {
          'text-field': ['get', 'name'],
          'text-size': 12,
          'text-color': '#383838' // poi label

        },
      },
      {
        id: 'place_label',
        type: 'symbol',
        source: 'composite',
        'source-layer': 'place_label',
        layout: {
          'text-field': ['get', 'name'],
          'text-size': 14,
          'text-color': '#000000' // place label

        },
      },
      {
        id: 'structure',
        type: 'fill',
        source: 'composite',
        'source-layer': 'structure',
        paint: {
          'fill-color': '#2e2e35' // dark gray to match Dusk
        }
      },
      {
        id: 'landuse_overlay',
        type: 'fill',
        source: 'composite',
        'source-layer': 'landuse_overlay',
        paint: {
          'fill-color': '#1f1f26', // muted dark blue
          'fill-opacity': 0.5
        }
      },
      {
        id: 'waterway',
        type: 'line',
        source: 'composite',
        'source-layer': 'waterway',
        paint: {
          'line-color': '#a6c8ff',
          'line-width': 1
        }
      },
      {
        id: 'admin',
        type: 'line',
        source: 'composite',
        'source-layer': 'admin',
        paint: {
          'line-color': '#444444',
          'line-width': 1
        }
      },
      {
        id: 'aeroway',
        type: 'fill',
        source: 'composite',
        'source-layer': 'aeroway',
        paint: {
          'fill-color': '#5c5c66'
        }
      },
    ],
  };
  
  
  export const nightStyleJSON = {
    // Dark theme for night
    version: 8,
    sources: {
      'mapbox-streets': {
        type: 'vector',
        url: 'mapbox://mapbox.mapbox-streets-v8'
      }
    },
    layers: [
      {
        id: 'background',
        type: 'background',
        paint: {
          'background-color': '#1a1a1a'
        }
      },
      // ... other layers
    ]
  };
  
//   // Helper function to get time-based style
//   export const getTimeBasedStyle = () => {
//     const hour = new Date().getHours();
    
//     if (hour >= 5 && hour < 7) return dawnStyleJSON;      // Dawn (5-7 AM)
//     if (hour >= 7 && hour < 18) return null;              // Day (7 AM - 6 PM) - use default
//     if (hour >= 18 && hour < 20) return duskStyleJSON;    // Dusk (6-8 PM)
//     return nightStyleJSON;                                 // Night (8 PM - 5 AM)
//   };