import React, { useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  Animated,
  PanResponder,
  Platform,
} from 'react-native';
import { COLORS } from '../theme/colors';

const { width } = Dimensions.get('window');
const SWIPE_THRESHOLD = width * 0.3;

interface SwipeCardProps {
  text: string;
  category: string;
  onSwipeRight: () => void;
  onSwipeLeft: () => void;
}

const SwipeCard: React.FC<SwipeCardProps> = ({
  text,
  category,
  onSwipeRight,
  onSwipeLeft,
}) => {
  const position = useRef(new Animated.ValueXY()).current;
  const rotation = position.x.interpolate({
    inputRange: [-width * 1.5, 0, width * 1.5],
    outputRange: ['-120deg', '0deg', '120deg'],
  });

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onPanResponderMove: (_, gesture) => {
        position.setValue({ x: gesture.dx, y: gesture.dy });
      },
      onPanResponderRelease: (_, gesture) => {
        if (gesture.dx > SWIPE_THRESHOLD) {
          forceSwipe('right');
        } else if (gesture.dx < -SWIPE_THRESHOLD) {
          forceSwipe('left');
        } else {
          resetPosition();
        }
      },
    })
  ).current;

  const forceSwipe = (direction: 'right' | 'left') => {
    const x = direction === 'right' ? width * 1.5 : -width * 1.5;
    Animated.timing(position, {
      toValue: { x, y: 0 },
      duration: 250,
      useNativeDriver: true,
    }).start(() => {
      if (direction === 'right') {
        onSwipeRight();
      } else {
        onSwipeLeft();
      }
    });
  };

  const resetPosition = () => {
    Animated.spring(position, {
      toValue: { x: 0, y: 0 },
      useNativeDriver: true,
    }).start();
  };

  const cardStyle = {
    transform: [
      { translateX: position.x },
      { translateY: position.y },
      { rotate: rotation },
    ],
  };

  return (
    <Animated.View
      style={[styles.card]}
      {...panResponder.panHandlers}
    >
      <View style={styles.cardContent}>
        <Text style={styles.category}>{category}</Text>
        <Text style={styles.text}>{text}</Text>
      </View>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  card: {
    position: 'absolute',
    width: width * 0.9,
    height: width * 1.2,
    borderRadius: 20,
    backgroundColor: COLORS.cardBackground,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
      },
      android: {
        elevation: 5,
      },
    }),
  },
  cardContent: {
    flex: 1,
    padding: 20,
    justifyContent: 'flex-end',
  },
  category: {
    fontSize: 16,
    color: COLORS.textSecondary,
    marginBottom: 8,
  },
  text: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: 20,
  },
});

export default SwipeCard; 