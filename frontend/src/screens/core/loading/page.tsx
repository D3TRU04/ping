import React, { useEffect, useRef } from 'react';
import { Dimensions, Animated, Easing } from 'react-native';
import { styled } from 'nativewind';
import { useNavigation } from '@react-navigation/native';

const { width /* height */ } = Dimensions.get('window');

const StyledView = styled(Animated.View);
const StyledImage = styled(Animated.Image);

const LoadingScreen = () => {
  const navigation = useNavigation<any>();
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.2)).current;
  const slideAnim = useRef(new Animated.Value(0)).current;
  const pulseAnim = useRef(new Animated.Value(1)).current;
  const glowAnim = useRef(new Animated.Value(0)).current;
  
  // Bounce effects for "found" state
  const bounceAnim = useRef(new Animated.Value(0)).current;
  const foundPulseAnim = useRef(new Animated.Value(1)).current;
  const pingBounceAnim = useRef(new Animated.Value(0)).current;

  // Exit animation values
  const exitFadeAnim = useRef(new Animated.Value(1)).current;
  const exitScaleAnim = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    // EXPLOSIVE entrance with spring effect
    Animated.parallel([
      Animated.spring(fadeAnim, {
        toValue: 1,
        tension: 100,
        friction: 8,
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnim, {
        toValue: 1.2,
        tension: 120,
        friction: 6,
        useNativeDriver: true,
      }),
      Animated.spring(slideAnim, {
        toValue: 1,
        tension: 150,
        friction: 7,
        useNativeDriver: true,
      }),
    ]).start();

    // Bounce in place like "found a place" effect
    setTimeout(() => {
      Animated.loop(
        Animated.sequence([
          Animated.spring(bounceAnim, {
            toValue: 1,
            tension: 200,
            friction: 3,
            useNativeDriver: true,
          }),
          Animated.spring(bounceAnim, {
            toValue: 0,
            tension: 200,
            friction: 3,
            useNativeDriver: true,
          }),
        ])
      ).start();
    }, 800);

    // Ping bounce effect - like a radar ping hitting something
    setTimeout(() => {
      Animated.loop(
        Animated.sequence([
          Animated.timing(pingBounceAnim, {
            toValue: 1,
            duration: 600,
            easing: Easing.out(Easing.back(1.5)),
            useNativeDriver: true,
          }),
          Animated.timing(pingBounceAnim, {
            toValue: 0,
            duration: 600,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: true,
          }),
        ])
      ).start();
    }, 1000);

    // Found pulse effect - celebration of finding something
    setTimeout(() => {
      Animated.loop(
        Animated.sequence([
          Animated.timing(foundPulseAnim, {
            toValue: 1.1,
            duration: 800,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: true,
          }),
          Animated.timing(foundPulseAnim, {
            toValue: 1,
            duration: 800,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: true,
          }),
        ])
      ).start();
    }, 1200);

    // Subtle pulse for logo
    setTimeout(() => {
      Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, {
            toValue: 1.05,
            duration: 1000,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: true,
          }),
          Animated.timing(pulseAnim, {
            toValue: 1,
            duration: 1000,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: true,
          }),
        ])
      ).start();
    }, 2000);

    // GLOW effect
    setTimeout(() => {
      Animated.loop(
        Animated.sequence([
          Animated.timing(glowAnim, {
            toValue: 1,
            duration: 1200,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: true,
          }),
          Animated.timing(glowAnim, {
            toValue: 0,
            duration: 1200,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: true,
          }),
        ])
      ).start();
    }, 2200);

    // Smooth exit animation before navigation
    const exitTimer = setTimeout(() => {
      Animated.parallel([
        Animated.timing(exitFadeAnim, {
          toValue: 0,
          duration: 600,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
        Animated.timing(exitScaleAnim, {
          toValue: 0.8,
          duration: 600,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
      ]).start(() => {
        // Navigate after exit animation completes
        navigation.replace('Startup');
      });
    }, 3000);

    return () => clearTimeout(exitTimer);
  }, [navigation, fadeAnim, scaleAnim, slideAnim, pulseAnim, glowAnim, bounceAnim, foundPulseAnim, pingBounceAnim, exitFadeAnim, exitScaleAnim]);

  const slide = slideAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [80, 0],
  });

  // const glow = glowAnim.interpolate({
  //   inputRange: [0, 1],
  //   outputRange: [0, 1],
  // });

  // Bounce effects
  const bounce = bounceAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0, -20],
  });

  const pingBounce = pingBounceAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0, -15],
  });

  return (
    <StyledView 
      className="flex-1 items-center justify-center" 
      style={{ 
        backgroundColor: '#1FC9C3',
        opacity: Animated.multiply(fadeAnim, exitFadeAnim),
      }}
    >
      {/* Main Logo with Bounce Effects */}
      <StyledImage
        source={require('../../../assets/logo/logo.png')}
        className=""
        style={{
          width: width * 0.7,
          height: width * 0.7,
          opacity: fadeAnim,
          transform: [
            { scale: Animated.multiply(
              Animated.multiply(scaleAnim, Animated.multiply(pulseAnim, foundPulseAnim)),
              exitScaleAnim
            ) },
            { translateY: Animated.add(slide, Animated.add(bounce, pingBounce)) }
          ],
        }}
        resizeMode="contain"
      />
    </StyledView>
  );
};

export default LoadingScreen; 