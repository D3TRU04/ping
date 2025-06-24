import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, Easing, Dimensions } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { COLORS } from '../theme/colors';

const { width } = Dimensions.get('window');

type RootStackParamList = {
  Results: undefined;
};

type LoadingScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Results'>;

const LoadingScreen = () => {
  const navigation = useNavigation<LoadingScreenNavigationProp>();
  const spinValue = useRef(new Animated.Value(0)).current;
  const fadeValue = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Start spinning animation
    Animated.loop(
      Animated.timing(spinValue, {
        toValue: 1,
        duration: 2000,
        easing: Easing.linear,
        useNativeDriver: true,
      })
    ).start();

    // Fade in text
    Animated.timing(fadeValue, {
      toValue: 1,
      duration: 1000,
      useNativeDriver: true,
    }).start();

    // Navigate to Results screen after 3 seconds
    const timer = setTimeout(() => {
      navigation.navigate('Results');
    }, 3000);

    return () => clearTimeout(timer);
  }, [navigation, spinValue, fadeValue]);

  const spin = spinValue.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  return (
    <View style={styles.container}>
      <View style={styles.background}>
        <Animated.View
          style={[
            styles.loadingCircle,
            {
              transform: [{ rotate: spin }],
            },
          ]}
        />
        <Animated.View style={{ opacity: fadeValue }}>
          <Text style={styles.loadingText}>Finding Perfect Matches</Text>
          <Text style={styles.subText}>Analyzing your preferences...</Text>
        </Animated.View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  background: {
    flex: 1,
    backgroundColor: 'white',
    alignItems: 'center',
    justifyContent: 'center',
  },
  loadingCircle: {
    width: width * 0.2,
    height: width * 0.2,
    borderRadius: (width * 0.2) / 2,
    borderWidth: 3,
    borderColor: COLORS.text,
    borderTopColor: 'transparent',
    marginBottom: 30,
  },
  loadingText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.text,
    textAlign: 'center',
    marginBottom: 10,
  },
  subText: {
    fontSize: 16,
    color: COLORS.text,
    opacity: 0.8,
    textAlign: 'center',
  },
});

export default LoadingScreen; 