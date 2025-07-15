// home/today/components/AnimatedStackCard.tsx
import React, { useRef, useEffect } from 'react';
import { Animated } from 'react-native';

interface AnimatedStackCardProps {
  top: number;
  zIndex: number;
  color: string;
  height: number;
  children: React.ReactNode;
}

const AnimatedStackCard: React.FC<AnimatedStackCardProps> = ({ top, zIndex, color, height, children }) => {
  const animatedTop = useRef(new Animated.Value(top)).current;

  useEffect(() => {
    Animated.timing(animatedTop, {
      toValue: top,
      duration: 350,
      useNativeDriver: false,
    }).start();
  }, [top]);

  return (
    <Animated.View
      style={{
        position: 'absolute',
        left: 0,
        right: 0,
        top: animatedTop,
        backgroundColor: color,
        zIndex,
        borderRadius: 32,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.10,
        shadowRadius: 16,
        elevation: 8,
        height,
      }}
    >
      {children}
    </Animated.View>
  );
};

export default AnimatedStackCard; 