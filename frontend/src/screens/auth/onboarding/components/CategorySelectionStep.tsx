import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Animated } from 'react-native';
import { styled } from 'nativewind';
import { LinearGradient } from 'expo-linear-gradient';
import { categories } from '../data';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledScrollView = styled(ScrollView);

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
  const handleCategoryPress = (categoryId: string) => {
    setSelectedCategories((prev: string[]) => {
      const isSelected = prev.includes(categoryId);
      if (isSelected) {
        return prev.filter((id: string) => id !== categoryId);
      } else {
        return [...prev, categoryId];
      }
    });
  };

  return (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }]
      }}
      className="flex-1"
    >
      <StyledView className="items-center space-y-4 mb-8">
        <StyledView className="w-20 h-20 bg-white/20 rounded-full items-center justify-center">
          <StyledText className="text-3xl">🎯</StyledText>
        </StyledView>
        <StyledText className="text-white text-3xl font-bold text-center">
          What interests you most?
        </StyledText>
        <StyledText className="text-white/80 text-lg text-center px-8">
          Select the categories that resonate with you
        </StyledText>
      </StyledView>

      <StyledScrollView 
        className="flex-1"
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 20 }}
      >
        <StyledView className="flex-row flex-wrap justify-center space-x-4 space-y-4">
          {categories.map((category) => {
            const isSelected = selectedCategories.includes(category.id);
            return (
              <StyledTouchableOpacity
                key={category.id}
                className={`w-40 h-40 rounded-3xl items-center justify-center shadow-lg ${
                  isSelected ? 'shadow-2xl' : ''
                }`}
                onPress={() => handleCategoryPress(category.id)}
                activeOpacity={0.8}
              >
                <LinearGradient
                  colors={isSelected ? category.gradient : ['rgba(255,255,255,0.9)', 'rgba(255,255,255,0.9)']}
                  style={{
                    width: '100%',
                    height: '100%',
                    borderRadius: 24,
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderWidth: isSelected ? 3 : 0,
                    borderColor: '#E74C3C',
                  }}
                >
                  <StyledText className="text-4xl mb-3">{category.icon}</StyledText>
                  <StyledText 
                    className={`text-center font-bold text-sm px-2 ${
                      isSelected ? 'text-white' : 'text-gray-800'
                    }`}
                  >
                    {category.name}
                  </StyledText>
                  {isSelected && (
                    <StyledView className="absolute top-3 right-3 w-6 h-6 bg-[#E74C3C] rounded-full items-center justify-center">
                      <StyledText className="text-white text-xs">✓</StyledText>
                    </StyledView>
                  )}
                </LinearGradient>
              </StyledTouchableOpacity>
            );
          })}
        </StyledView>
      </StyledScrollView>

      {selectedCategories.length > 0 && (
        <StyledView className="bg-white/20 rounded-2xl p-4 mt-4">
          <StyledText className="text-white text-center font-bold mb-2">
            Selected ({selectedCategories.length})
          </StyledText>
          <StyledView className="flex-row flex-wrap justify-center">
            {selectedCategories.slice(0, 3).map((categoryId) => {
              const category = categories.find(c => c.id === categoryId);
              return (
                <StyledView
                  key={categoryId}
                  className="bg-white/90 rounded-full px-3 py-2 m-1"
                >
                  <StyledText className="text-gray-800 text-xs">{category?.name}</StyledText>
                </StyledView>
              );
            })}
            {selectedCategories.length > 3 && (
              <StyledView className="bg-white/90 rounded-full px-3 py-2 m-1">
                <StyledText className="text-gray-800 text-xs">
                  +{selectedCategories.length - 3} more
                </StyledText>
              </StyledView>
            )}
          </StyledView>
        </StyledView>
      )}
    </Animated.View>
  );
}; 