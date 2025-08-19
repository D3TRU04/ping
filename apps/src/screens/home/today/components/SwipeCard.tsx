// home/today/components/SwipeCard.tsx
import React, { useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  Animated,
  PanResponder,
  Platform,
  TouchableOpacity,
} from 'react-native';
import { COLORS } from '../../../theme/colors';
import AppText from '../../../../components/AppText';

const { width } = Dimensions.get('window');
const SWIPE_THRESHOLD = width * 0.3;

interface SwipeCardProps {
  children: React.ReactNode;
  backgroundColor: string;
  swipeDirection: 'left' | 'right' | null;
  onSwipedOut: () => void;
  onSwipeLeft?: () => void;
  onSwipeRight?: () => void;
  pendingRemoval?: boolean;
  style?: any;
}

const SwipeCard: React.FC<SwipeCardProps> = ({
  children,
  backgroundColor,
  swipeDirection,
  onSwipedOut,
  onSwipeLeft,
  onSwipeRight,
  pendingRemoval,
  style,
}) => {
  const position = useRef(new Animated.ValueXY()).current;
  const rotation = position.x.interpolate({
    inputRange: [-width * 1.5, 0, width * 1.5],
    outputRange: ['-20deg', '0deg', '20deg'],
  });
  const cardStyle = {
    transform: [
      { translateX: position.x },
      { translateY: position.y },
      { rotate: rotation },
    ],
  };

  useEffect(() => {
    if (swipeDirection === 'left') {
      Animated.timing(position, {
        toValue: { x: -width * 1.2, y: 0 },
        duration: 500,
        useNativeDriver: true,
      }).start(onSwipedOut);
    } else if (swipeDirection === 'right') {
      Animated.timing(position, {
        toValue: { x: width * 1.2, y: 0 },
        duration: 500,
        useNativeDriver: true,
      }).start(onSwipedOut);
    }
  }, [swipeDirection]);

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onPanResponderMove: (_, gesture) => {
        position.setValue({ x: gesture.dx, y: gesture.dy });
      },
      onPanResponderRelease: (_, gesture) => {
        if (pendingRemoval) return;
        if (gesture.dx > SWIPE_THRESHOLD) {
          if (onSwipeRight) onSwipeRight();
        } else if (gesture.dx < -SWIPE_THRESHOLD) {
          if (onSwipeLeft) onSwipeLeft();
        } else {
          Animated.spring(position, {
            toValue: { x: 0, y: 0 },
            useNativeDriver: true,
          }).start();
        }
      },
    })
  ).current;

  return (
    <Animated.View
      style={[styles.card, cardStyle, style]}
      {...panResponder.panHandlers}
    >
      {children}
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  card: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 10,
    borderWidth: 0,
  },
});

export default SwipeCard; 