import React, { useEffect } from 'react';
import { View, Text, TouchableOpacity, Animated, Dimensions } from 'react-native';
import { styled } from 'nativewind';
import { LinearGradient } from 'expo-linear-gradient';
import { categories } from '../data';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);

const { width: SCREEN_WIDTH } = Dimensions.get('window');
// Calculate width for 3 cards per row with equal spacing
const CARD_WIDTH = (SCREEN_WIDTH - 48 - 16) / 3; // 48 for outer padding (24 each side), 16 for gaps between cards
const CARD_HEIGHT = CARD_WIDTH * 1.15;
const GAP = 8; // Gap between cards

interface CategorySelectionStepProps {
  selectedCategories: string[];
  setSelectedCategories: (categories: string[] | ((prev: string[]) => string[])) => void;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const CategorySelectionStep: React.FC<CategorySelectionStepProps> = ({
  selectedCategories,
  setSelectedCategories,
  fadeAnim,
  slideAnim,
  scaleAnim,
}) => {
  // Animation values for each category card
  const scaleAnims = categories.map(() => new Animated.Value(1));

  // Bright color gradients for selected categories (no dark colors)
  const mutedGradients = [
    ['#8B5CF6', '#7C3AED'], // Purple
    ['#10B981', '#059669'], // Green
    ['#EF4444', '#DC2626'], // Red
    ['#3B82F6', '#2563EB'], // Blue
    ['#F59E0B', '#D97706'], // Orange
    ['#EC4899', '#DB2777'], // Pink
    ['#06B6D4', '#0891B2'], // Cyan
    ['#8B5A2B', '#A0522D'], // Brown
  ];

  const handleCategoryPress = (categoryId: string, index: number) => {
    // Scale animation on press for tactile feedback
    Animated.sequence([
      Animated.timing(scaleAnims[index], {
        toValue: 0.95,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnims[index], {
        toValue: 1,
        tension: 100,
        friction: 5,
        useNativeDriver: true,
      }),
    ]).start();

    // Toggle category selection
    setSelectedCategories((prev: string[]) => {
      const isSelected = prev.includes(categoryId);
      if (isSelected) {
        return prev.filter((id: string) => id !== categoryId);
      } else {
        return [...prev, categoryId];
      }
    });
  };

  // Split categories into rows of 3 for grid layout
  const rows = [];
  for (let i = 0; i < categories.length; i += 3) {
    rows.push(categories.slice(i, i + 3));
  }

  return (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }],
        flex: 1,
      }}
      className="justify-center"
    >
      {/* Header section with icon and title */}
      <StyledView className="items-center space-y-6 mb-8">
        <StyledView className="w-16 h-16 bg-white/20 rounded-full items-center justify-center">
          <Text className="text-3xl">🎯</Text>
        </StyledView>
        <Text 
          className="text-white text-center font-medium text-3xl px-6"
        >
          What interests you most?
        </Text>
      </StyledView>

      {/* Category grid - 3 cards per row, centered */}
      <StyledView className="flex-1 px-4">
        {rows.map((row, rowIndex) => (
          <StyledView 
            key={rowIndex}
            className="flex-row mb-2 justify-center"
            style={{
              gap: GAP,
            }}
          >
            {row.map((category, colIndex) => {
              const index = rowIndex * 3 + colIndex;
              const isSelected = selectedCategories.includes(category.id);
              return (
                <Animated.View
                  key={category.id}
                  style={{
                    transform: [{ scale: scaleAnims[index] }],
                  }}
                >
                  <StyledTouchableOpacity
                    onPress={() => handleCategoryPress(category.id, index)}
                    activeOpacity={0.9}
                    style={{
                      width: CARD_WIDTH,
                      height: CARD_HEIGHT,
                    }}
                  >
                    <LinearGradient
                      colors={isSelected ? mutedGradients[index % mutedGradients.length] : ['rgba(255,255,255,0.95)', 'rgba(255,255,255,0.95)']}
                      className="w-full h-full rounded-2xl p-3 items-center justify-center"
                      style={{
                        borderWidth: isSelected ? 2 : 0,
                        borderColor: '#374151',
                      }}
                    >
                      <StyledView className="items-center justify-center flex-1">
                        <Text className="text-3xl mb-2">{category.icon}</Text>
                        <Text 
                          className={`text-center text-sm font-medium ${
                            isSelected ? 'text-white' : 'text-gray-800'
                          }`}
                          numberOfLines={2}
                        >
                          {category.name}
                        </Text>
                      </StyledView>
                      {/* Selection indicator */}
                      {isSelected && (
                        <StyledView className="absolute top-2 right-2 w-6 h-6 bg-gray-700 rounded-full items-center justify-center">
                          <Text className="text-white text-xs">✓</Text>
                        </StyledView>
                      )}
                    </LinearGradient>
                  </StyledTouchableOpacity>
                </Animated.View>
              );
            })}
          </StyledView>
        ))}
      </StyledView>
    </Animated.View>
  );
}; 