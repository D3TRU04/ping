import 'dotenv/config';

export default ({ config }) => {
  return {
    ...config,
    name: 'Ping',
    slug: 'Ping',
    version: '1.0.0',
    orientation: 'portrait',
    icon: './src/assets/logo/logo2.png',
    splash: {
      image: './src/assets/logo/logo2.png',
      resizeMode: 'contain',
      backgroundColor: '#ffffff',
    },
    updates: {
      fallbackToCacheTimeout: 0,
    },
    assetBundlePatterns: ['**/*'],
    ios: {
      supportsTablet: true,
      bundleIdentifier: 'com.justaaron.ping',
    },
    android: {
      ...config.android,
      package: 'com.justaaron.ping',
      adaptiveIcon: {
        foregroundImage: './src/assets/adaptive-icon.png',
        backgroundColor: '#FFFFFF',
    },

    },
    extra: {
      EXPO_PUBLIC_SUPABASE_URL: process.env.EXPO_PUBLIC_SUPABASE_URL,
      EXPO_PUBLIC_SUPABASE_ANON_KEY: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY,
      EXPO_PUBLIC_MAPBOX_TOKEN: process.env.EXPO_PUBLIC_MAPBOX_TOKEN,
      eas: { projectId: '380f0e77-6b1a-42f2-b403-aafafcbf5417' },  

    },
  };
};
