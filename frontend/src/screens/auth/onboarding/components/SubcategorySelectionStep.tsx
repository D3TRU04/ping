import React, { useState, useEffect } from 'react';
import { View, TouchableOpacity, Animated } from 'react-native';
import { styled } from 'nativewind';
import { LinearGradient } from 'expo-linear-gradient';
import { categories } from '../data';
import AppText from '../../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

// const { width: SCREEN_WIDTH } = Dimensions.get('window');

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
  
  // Animation values for each subcategory bubble
  const [scaleAnims, setScaleAnims] = useState<Animated.Value[]>([]);
  useEffect(() => {
    setScaleAnims(category?.subcategories.map(() => new Animated.Value(1)) || []);
  }, [category]);

  // Bright color gradients for selected subcategories
  const brightGradients = [
    ['#3B82F6', '#1D4ED8'], // Bright Blue
    ['#10B981', '#059669'], // Bright Green
    ['#FF5C5C', '#FF5C5C'], // Teal (replacing Bright Mint)
    ['#EF4444', '#DC2626'], // Bright Red
    ['#8B5CF6', '#7C3AED'], // Bright Purple
    ['#EC4899', '#DB2777'], // Bright Pink
    ['#06B6D4', '#0891B2'], // Bright Cyan
    ['#84CC16', '#65A30D'], // Bright Lime
    ['#FF5C5C', '#FF5C5C'], // Teal (replacing Bright Mint Red)
    ['#6366F1', '#4F46E5'], // Bright Indigo
  ];
  
  if (!category) {
    return null;
  }

  // Prevent rendering if animations are not ready for the new category
  if (scaleAnims.length !== category.subcategories.length) {
    return null;
  }

  // Filter subcategories for this specific category
  // const currentCategorySubcategories = selectedSubcategories.filter(subcategory => 
  //   category.subcategories.some(sub => sub.name === subcategory)
  // );

  const handleSubcategoryPress = (subcategoryName: string, index: number) => {
    // Scale animation on press for tactile feedback
    Animated.sequence([
      Animated.timing(scaleAnims[index], {
        toValue: 0.9,
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

    // Toggle subcategory selection
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
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }],
        flex: 1,
      }}
      className="flex-1 pt-6 px-4 space-y-8"
    >
      {/* Header section with category icon and title */}
      <StyledView className="w-full bg-transparent mb-2">
        <StyledView className="flex-row items-center mb-4">
          <StyledView className="w-12 h-12 rounded-full items-center justify-center overflow-hidden mr-3">
            <LinearGradient
              colors={category.gradient}
              className="w-full h-full items-center justify-center"
            >
              <AppText className="text-2xl">{category.icon}</AppText>
            </LinearGradient>
          </StyledView>
          <AppText className="text-white text-3xl font-medium text-left flex-1">
            {category.name}
          </AppText>
        </StyledView>
        <StyledView className="w-full mt-2">
          <AppText className="text-white/80 text-base text-left max-w-[320px]">
            Select your specific interests
          </AppText>
        </StyledView>
      </StyledView>

      {/* Subcategory bubbles - dynamic sizing based on text length */}
      <StyledView className="px-3">
        <StyledView className="flex-row flex-wrap justify-center gap-1.5">
          {category.subcategories.map((subcategory, index) => {
            const isSelected = selectedSubcategories.includes(subcategory.name);
            const selectedColor = brightGradients[index % brightGradients.length];
            
            return (
              <Animated.View
                key={subcategory.name}
                style={{
                  transform: [{ scale: scaleAnims[index] }],
                }}
              >
                <StyledTouchableOpacity
                  onPress={() => handleSubcategoryPress(subcategory.name, index)}
                  activeOpacity={0.9}
                  className="rounded-full items-center px-2 py-1.5"
                  style={{
                    backgroundColor: isSelected ? selectedColor[0] : 'rgba(255,255,255,0.9)',
                    borderWidth: isSelected ? 2 : 0,
                    borderColor: selectedColor[1],
                  }}
                >
                  <AppText className="text-sm mb-0.5">
                    {subcategory.icon}
                  </AppText>
                  <AppText 
                    className={`text-xs font-medium text-center whitespace-nowrap ${
                      isSelected ? 'text-white' : 'text-gray-800'
                    }`}
                  >
                    {subcategory.name}
                  </AppText>
                </StyledTouchableOpacity>
              </Animated.View>
            );
          })}
        </StyledView>
      </StyledView>
    </Animated.View>
  );
}; 