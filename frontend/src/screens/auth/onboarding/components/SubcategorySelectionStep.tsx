import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Animated } from 'react-native';
import { styled } from 'nativewind';
import { LinearGradient } from 'expo-linear-gradient';
import { categories } from '../data';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledScrollView = styled(ScrollView);

interface SubcategorySelectionStepProps {
  categoryId: string;
  selectedSubcategories: string[];
  setSelectedSubcategories: (subcategories: string[] | ((prev: string[]) => string[])) => void;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const SubcategorySelectionStep: React.FC<SubcategorySelectionStepProps> = ({
  categoryId,
  selectedSubcategories,
  setSelectedSubcategories,
  fadeAnim,
  slideAnim,
  scaleAnim,
}) => {
  const category = categories.find(c => c.id === categoryId);
  
  if (!category) {
    return null;
  }

  // Filter subcategories for this specific category
  const currentCategorySubcategories = selectedSubcategories.filter(subcategory => 
    category.subcategories.some(sub => sub.name === subcategory)
  );

  const handleSubcategoryPress = (subcategoryName: string) => {
    setSelectedSubcategories((prev: string[]) => {
      const isSelected = prev.includes(subcategoryName);
      if (isSelected) {
        return prev.filter(name => name !== subcategoryName);
      } else {
        return [...prev, subcategoryName];
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
        <StyledView className="w-20 h-20 rounded-full items-center justify-center">
          <LinearGradient
            colors={category.gradient}
            style={{
              width: '100%',
              height: '100%',
              borderRadius: 40,
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <StyledText className="text-3xl">{category.icon}</StyledText>
          </LinearGradient>
        </StyledView>
        <StyledText className="text-white text-3xl font-bold text-center">
          {category.name}
        </StyledText>
        <StyledText className="text-white/80 text-lg text-center px-8">
          {category.description}
        </StyledText>
      </StyledView>

      <StyledScrollView 
        className="flex-1"
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 20 }}
      >
        <StyledView className="flex-row flex-wrap justify-center space-x-3 space-y-3">
          {category.subcategories.map((subcategory) => {
            const isSelected = selectedSubcategories.includes(subcategory.name);
            return (
              <StyledTouchableOpacity
                key={subcategory.name}
                className={`px-6 py-4 rounded-2xl items-center justify-center min-w-[120px] ${
                  isSelected ? 'shadow-lg' : ''
                }`}
                onPress={() => handleSubcategoryPress(subcategory.name)}
                activeOpacity={0.8}
              >
                <LinearGradient
                  colors={isSelected ? category.gradient : ['rgba(255,255,255,0.95)', 'rgba(255,255,255,0.95)']}
                  style={{
                    paddingHorizontal: 16,
                    paddingVertical: 12,
                    borderRadius: 16,
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderWidth: isSelected ? 2 : 0,
                    borderColor: '#E74C3C',
                  }}
                >
                  <StyledText className="text-2xl mb-2">{subcategory.icon}</StyledText>
                  <StyledText 
                    className={`text-center font-medium text-sm ${
                      isSelected ? 'text-white' : 'text-gray-800'
                    }`}
                  >
                    {subcategory.name}
                  </StyledText>
                  {isSelected && (
                    <StyledView className="absolute -top-1 -right-1 w-5 h-5 bg-[#E74C3C] rounded-full items-center justify-center">
                      <StyledText className="text-white text-xs">✓</StyledText>
                    </StyledView>
                  )}
                </LinearGradient>
              </StyledTouchableOpacity>
            );
          })}
        </StyledView>
      </StyledScrollView>

      {currentCategorySubcategories.length > 0 && (
        <StyledView className="bg-white/20 rounded-2xl p-4 mt-4">
          <StyledText className="text-white text-center font-bold mb-2">
            Selected ({currentCategorySubcategories.length})
          </StyledText>
          <StyledView className="flex-row flex-wrap justify-center">
            {currentCategorySubcategories.slice(0, 4).map((subcategory) => (
              <StyledView
                key={subcategory}
                className="bg-white/90 rounded-full px-3 py-2 m-1"
              >
                <StyledText className="text-gray-800 text-xs">{subcategory}</StyledText>
              </StyledView>
            ))}
            {currentCategorySubcategories.length > 4 && (
              <StyledView className="bg-white/90 rounded-full px-3 py-2 m-1">
                <StyledText className="text-gray-800 text-xs">
                  +{currentCategorySubcategories.length - 4} more
                </StyledText>
              </StyledView>
            )}
          </StyledView>
        </StyledView>
      )}
    </Animated.View>
  );
}; 