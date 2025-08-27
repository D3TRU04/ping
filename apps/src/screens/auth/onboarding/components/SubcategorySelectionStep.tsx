import React, { useState, useEffect } from 'react';
import { View, TouchableOpacity, Animated, ScrollView } from 'react-native';
import { styled } from 'nativewind';
import { LinearGradient } from 'expo-linear-gradient';
import { categories } from '../data';
import AppText from '../../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledScrollView = styled(ScrollView);

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
  const [expandedSubcategory, setExpandedSubcategory] = useState<string | null>(null);
  
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

  const handleSubSubcategoryPress = (subSubcategoryName: string) => {
    setSelectedSubcategories((prev: string[]) => {
      const isSelected = prev.includes(subSubcategoryName);
      if (isSelected) {
        return prev.filter(name => name !== subSubcategoryName);
      } else {
        return [...prev, subSubcategoryName];
      }
    });
  };

  // Get all selected subcategories
  const selectedSubcategoryNames = category.subcategories
    .map(sub => sub.name)
    .filter(name => selectedSubcategories.includes(name));

  // Get all subsubcategories from selected subcategories with left-to-right ordering
  // Newest selections appear on the left
  const allSubSubcategories = category.subcategories
    .filter(sub => selectedSubcategories.includes(sub.name))
    .reverse() // Reverse the order so newest selections appear first
    .flatMap(sub => sub.subSubcategories || []);

  // Split subcategories into two columns for masonry layout
  const leftColumn = category.subcategories.filter((_, i) => i % 2 === 0);
  const rightColumn = category.subcategories.filter((_, i) => i % 2 === 1);

  return (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }],
        flex: 1,
      }}
      className="flex-1"
    >
      <StyledView 
        className="flex-1 px-4"
        style={{ paddingTop: 24, paddingBottom: 40 }}
      >
        {/* Header section with category icon and title */}
        <StyledView className="w-full bg-transparent mb-6">
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

        {/* Subcategory bubbles - 2-column masonry layout, vertically centered */}
        <StyledView className="flex-1 justify-center">
          <StyledView className="flex-row justify-center w-full space-x-4">
            {/* Left column */}
            <StyledView className="flex-1 space-y-2">
              {leftColumn.map((subcategory, index) => {
                const globalIndex = category.subcategories.indexOf(subcategory);
                const isSelected = selectedSubcategories.includes(subcategory.name);
                const selectedColor = brightGradients[globalIndex % brightGradients.length];
                return (
                  <Animated.View
                    key={subcategory.name}
                    style={{
                      transform: [{ scale: scaleAnims[globalIndex] }],
                    }}
                  >
                    <StyledTouchableOpacity
                      onPress={() => handleSubcategoryPress(subcategory.name, globalIndex)}
                      activeOpacity={0.9}
                      className={`rounded-2xl items-center justify-center px-3 py-0.5 shadow-md ${isSelected ? 'border-2 border-gray-200' : ''}`}
                      style={{
                        backgroundColor: isSelected ? '#fff' : selectedColor[0],
                        borderColor: isSelected ? '#E5E7EB' : 'transparent',
                        minHeight: 18,
                      }}
                    >
                      <AppText
                        style={{
                          color: isSelected ? selectedColor[0] : '#fff',
                          fontSize: 15,
                          textAlign: 'center',
                          marginBottom: 2,
                        }}
                      >
                        {subcategory.icon}
                      </AppText>
                      <AppText
                        style={{
                          color: isSelected ? selectedColor[0] : '#fff',
                          fontWeight: '600',
                          fontSize: 12,
                          textAlign: 'center',
                          lineHeight: 16,
                          marginBottom: 8,
                        }}
                        numberOfLines={2}
                        ellipsizeMode="tail"
                      >
                        {subcategory.name}
                      </AppText>
                    </StyledTouchableOpacity>
                  </Animated.View>
                );
              })}
            </StyledView>
            {/* Right column */}
            <StyledView className="flex-1 space-y-2">
              {rightColumn.map((subcategory, index) => {
                const globalIndex = category.subcategories.indexOf(subcategory);
                const isSelected = selectedSubcategories.includes(subcategory.name);
                const selectedColor = brightGradients[globalIndex % brightGradients.length];
                return (
                  <Animated.View
                    key={subcategory.name}
                    style={{
                      transform: [{ scale: scaleAnims[globalIndex] }],
                    }}
                  >
                    <StyledTouchableOpacity
                      onPress={() => handleSubcategoryPress(subcategory.name, globalIndex)}
                      activeOpacity={0.9}
                      className={`rounded-2xl items-center justify-center px-3 py-0.5 shadow-md ${isSelected ? 'border-2 border-gray-200' : ''}`}
                      style={{
                        backgroundColor: isSelected ? '#fff' : selectedColor[0],
                        borderColor: isSelected ? '#E5E7EB' : 'transparent',
                        minHeight: 18,
                      }}
                    >
                      <AppText
                        style={{
                          color: isSelected ? selectedColor[0] : '#fff',
                          fontSize: 15,
                          textAlign: 'center',
                          marginBottom: 2,
                        }}
                      >
                        {subcategory.icon}
                      </AppText>
                      <AppText
                        style={{
                          color: isSelected ? selectedColor[0] : '#fff',
                          fontWeight: '600',
                          fontSize: 12,
                          textAlign: 'center',
                          lineHeight: 16,
                          marginBottom: 8,
                        }}
                        numberOfLines={2}
                        ellipsizeMode="tail"
                      >
                        {subcategory.name}
                      </AppText>
                    </StyledTouchableOpacity>
                  </Animated.View>
                );
              })}
            </StyledView>
          </StyledView>
        </StyledView>

        {/* Sub-subcategories in horizontal scrollable row - only show when there are selected subcategories */}
        {allSubSubcategories.length > 0 && (
          <StyledView className="w-full mt-6">
            <StyledView className="mb-3">
              <AppText className="text-white/90 text-sm font-medium">
                Refine your selection:
              </AppText>
            </StyledView>
            <StyledScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={{
                paddingHorizontal: 4,
                gap: 8,
              }}
              className="w-full"
            >
              {allSubSubcategories.map((subSubcategory, index) => {
                const isSubSelected = selectedSubcategories.includes(subSubcategory.name);
                const subColors = [
                  '#F59E0B', '#84CC16', '#06B6D4', '#8B5CF6', '#EC4899', '#EF4444',
                  '#10B981', '#3B82F6', '#F97316', '#A855F7', '#14B8A6', '#F43F5E',
                ];
                const subColor = subColors[index % subColors.length];
                return (
                  <StyledTouchableOpacity
                    key={`${subSubcategory.name}-${index}`}
                    onPress={() => handleSubSubcategoryPress(subSubcategory.name)}
                    activeOpacity={0.85}
                    className={`rounded-xl flex-row items-center px-3 py-1.5 ${isSubSelected ? 'border-2 border-gray-200' : ''}`}
                    style={{
                      backgroundColor: isSubSelected ? '#fff' : subColor,
                      borderColor: isSubSelected ? '#E5E7EB' : 'transparent',
                      minHeight: 24,
                      minWidth: 140,
                      maxWidth: 180,
                    }}
                  >
                    <AppText
                      style={{
                        color: isSubSelected ? subColor : '#fff',
                        fontSize: 16,
                        textAlign: 'center',
                        marginRight: 8,
                        lineHeight: 16,
                      }}
                    >
                      {subSubcategory.icon}
                    </AppText>
                    <StyledView className="flex-1" style={{ overflow: 'hidden' }}>
                      <AppText
                        style={{
                          color: isSubSelected ? subColor : '#fff',
                          fontWeight: '600',
                          fontSize: 11,
                          textAlign: 'left',
                          lineHeight: 13,
                        }}
                        numberOfLines={2}
                      >
                        {subSubcategory.name}
                      </AppText>
                      {subSubcategory.price && (
                        <AppText
                          style={{
                            color: isSubSelected ? subColor : '#fff',
                            fontSize: 9,
                            textAlign: 'left',
                            opacity: 0.8,
                            marginTop: 1,
                            lineHeight: 11,
                          }}
                          numberOfLines={1}
                        >
                          {subSubcategory.price.replace(/N\/A - /g, '').replace(/-/g, '').replace(/\$/g, '')}
                        </AppText>
                      )}
                    </StyledView>
                  </StyledTouchableOpacity>
                );
              })}
            </StyledScrollView>
          </StyledView>
        )}
      </StyledView>
    </Animated.View>
  );
}; 