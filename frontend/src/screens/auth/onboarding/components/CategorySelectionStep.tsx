import React, { useEffect } from 'react';
import { View, TouchableOpacity, Animated, Dimensions } from 'react-native';
import { styled } from 'nativewind';
import { LinearGradient } from 'expo-linear-gradient';
import { categories } from '../data';
import AppText from '../../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

const { width: SCREEN_WIDTH } = Dimensions.get('window');
// Calculate width for 2 cards per row with equal spacing
const OUTER_PADDING = 16 * 2; // 16 each side
const GAP = 8;
const CARD_WIDTH = (SCREEN_WIDTH - OUTER_PADDING - GAP) / 2;
const CARD_HEIGHT = CARD_WIDTH * 0.48; // increase button height

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
    ['#FF5C5C', '#FF5C5C'], // Teal (replacing Mint)
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

  // Split categories into rows of 2 for grid layout
  const rows = [];
  for (let i = 0; i < categories.length; i += 2) {
    rows.push(categories.slice(i, i + 2));
  }

  return (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }],
        flex: 1,
      }}
      className="flex-1 pt-6 px-4 space-y-8"
    >
      {/* Header section with icon and title */}
      <StyledView className="w-full bg-transparent mb-2">
        <AppText className="text-white text-3xl font-medium text-left">
          What interests you most?
        </AppText>
        <StyledView className="w-full mt-2">
          <AppText className="text-white/80 text-base text-left max-w-[320px]">
            Select the categories that match your interests.
          </AppText>
        </StyledView>
      </StyledView>

      {/* Category grid - 2x4 layout with long rectangles */}
      <StyledView className="flex-1 px-4">
        {rows.map((row, rowIndex) => (
          <StyledView
            key={rowIndex}
            className="flex-row justify-center"
            style={{ gap: GAP / 2, marginBottom: 8 }} // reduced vertical and horizontal space
          >
            {row.map((category, colIndex) => {
              const index = rowIndex * 2 + colIndex;
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
                    className={`
                      rounded-[14px]
                      overflow-hidden
                      px-[10px]
                      py-[8px]
                      justify-center
                      ${isSelected ? 'border-2 border-gray-200' : ''}
                    `}
                    style={{
                      width: CARD_WIDTH,
                      height: CARD_HEIGHT,
                      backgroundColor: isSelected ? '#fff' : category.color,
                    }}
                  >
                    <View className="flex-row items-center justify-between w-full h-full">
                      <AppText
                        className="flex-1 mr-1 font-semibold"
                        style={{
                          color: isSelected ? category.color : '#fff',
                          fontSize: 16,
                        }}
                        numberOfLines={2}
                        ellipsizeMode="tail"
                      >
                        {category.name}
                      </AppText>
                      <AppText
                        className="w-8 text-right"
                        style={{
                          fontSize: 26,
                          color: isSelected ? category.color : '#fff',
                          transform: [{ rotate: category.id === 'food-drink' ? '0deg' : (category.rotation || '25deg') }],
                          opacity: 0.95,
                        }}
                      >
                        {category.icon}
                      </AppText>
                    </View>
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