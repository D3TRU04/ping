import { useEffect, useState } from 'react';
import * as Font from 'expo-font';

export default function useCustomFonts() {
  const [fontsLoaded, setFontsLoaded] = useState(false);

  useEffect(() => {
    async function loadFonts() {
      try {
        await Font.loadAsync({
          'Satoshi-Medium': require('../../assets/fonts/Satoshi-Variable.ttf'),
          // MaterialIcons font is loaded automatically with @expo/vector-icons
        });
        setFontsLoaded(true);
      } catch (error) {
        console.error('Error loading fonts:', error);
        setFontsLoaded(true); // Still allow app to load with system fonts
      }
    }

    loadFonts();
  }, []);

  return fontsLoaded;
}