import React, { useState } from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { COLORS } from '../theme/colors';
import SwipeCard from '../components/SwipeCard';

const { width } = Dimensions.get('window');

type RootStackParamList = {
  Loading: undefined;
};

type SwipeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Loading'>;

interface Card {
  id: string;
  text: string;
  category: string;
}

const SwipeScreen = () => {
  const navigation = useNavigation<SwipeScreenNavigationProp>();
  const [cards] = useState<Card[]>([
    {
      id: '1',
      text: 'Coffee and Conversation',
      category: 'Coffee Shop',
    },
    {
      id: '2',
      text: 'Adventure Park',
      category: 'Activity',
    },
    {
      id: '3',
      text: 'Night Market',
      category: 'Food & Entertainment',
    },
  ]);

  const handleSwipeRight = () => {
    navigation.navigate('Loading');
  };

  const handleSwipeLeft = () => {
    console.log('Disliked');
  };

  return (
    <View style={styles.container}>
      <View style={styles.background}>
        {cards.map((card) => (
          <SwipeCard
            key={card.id}
            text={card.text}
            category={card.category}
            onSwipeRight={handleSwipeRight}
            onSwipeLeft={handleSwipeLeft}
          />
        ))}
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
    backgroundColor: COLORS.background,
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default SwipeScreen; 