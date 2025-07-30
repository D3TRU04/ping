import { useEffect, useState } from 'react';
import * as Font from 'expo-font';

export default function useCustomFonts() {
  const [fontsLoaded, setFontsLoaded] = useState(false);

  useEffect(() => {
    async function loadFonts() {
      try {
        await Font.loadAsync({
          'Satoshi-Medium': require('../assets/fonts/Satoshi-Variable.ttf'),
          // MaterialIcons font is loaded automatically with @expo/vector-icons
        });
        setFontsLoaded(true);
      } catch (error) {
        // Handle error silently
      }
    }

    loadFonts();
  }, []);

  return fontsLoaded;
}