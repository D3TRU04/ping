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

    // Toggle subcategory selection and expansion
    setSelectedSubcategories((prev: string[]) => {
      const isSelected = prev.includes(subcategoryName);
      let updated;
      if (isSelected) {
        updated = prev.filter(name => name !== subcategoryName);
        setExpandedSubcategory(null);
      } else {
        updated = [...prev, subcategoryName];
        setExpandedSubcategory(subcategoryName);
      }
      return updated;
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

      {/* Subcategory bubbles - 2x2 grid layout */}
      <StyledView className="px-4">
        <StyledView className="flex-row flex-wrap justify-between" style={{ gap: 16 }}>
          {category.subcategories.slice(0, 4).map((subcategory, index) => {
            const isSelected = selectedSubcategories.includes(subcategory.name);
            const isExpanded = expandedSubcategory === subcategory.name;
            const selectedColor = brightGradients[index % brightGradients.length];
            
            return (
              <StyledView key={subcategory.name} className="mb-4" style={{ width: '45%' }}>
                <Animated.View
                  style={{
                    transform: [{ scale: scaleAnims[index] }],
                  }}
                >
                  <StyledTouchableOpacity
                    onPress={() => handleSubcategoryPress(subcategory.name, index)}
                    activeOpacity={0.9}
                    className={`rounded-2xl items-center justify-center px-3 py-4 aspect-square shadow-md ${isSelected ? 'border-2 border-gray-200' : ''}`}
                    style={{
                      backgroundColor: isSelected ? '#fff' : selectedColor[0],
                      borderColor: isSelected ? '#E5E7EB' : 'transparent',
                    }}
                  >
                    <AppText
                      style={{
                        color: isSelected ? selectedColor[0] : '#fff',
                        fontSize: 22,
                        textAlign: 'center',
                        marginBottom: 8,
                      }}
                    >
                      {subcategory.icon}
                    </AppText>
                    <AppText
                      style={{
                        color: isSelected ? selectedColor[0] : '#fff',
                        fontWeight: '600',
                        fontSize: 13,
                        textAlign: 'center',
                        lineHeight: 16,
                        maxWidth: 90,
                      }}
                      numberOfLines={1}
                      ellipsizeMode="tail"
                    >
                      {subcategory.name}
                    </AppText>
                  </StyledTouchableOpacity>
                </Animated.View>

                {/* Sub-subcategories */}
                {isExpanded && subcategory.subSubcategories && (
                  <StyledView className="w-full mt-3 px-4">
                    <StyledView className="flex-row flex-wrap justify-between">
                    {subcategory.subSubcategories.slice(0, 4).map((subSubcategory, subIndex) => {
                      const isSubSelected = selectedSubcategories.includes(subSubcategory.name);
                      const subColors = [
                        '#F59E0B', // Amber
                        '#84CC16', // Lime
                        '#06B6D4', // Cyan
                        '#8B5CF6', // Purple
                        '#EC4899', // Pink
                        '#EF4444', // Red
                        '#10B981', // Green
                        '#3B82F6', // Blue
                      ];
                      const subColor = subColors[subIndex % subColors.length];
                      
                      return (
                        <StyledView style={{ width: '48%', alignItems: 'center', marginBottom: 16 }}>
                          <StyledTouchableOpacity
                            key={subSubcategory.name}
                            onPress={() => handleSubSubcategoryPress(subSubcategory.name)}
                            activeOpacity={0.85}
                            className={`w-[58px] h-[58px] rounded-full m-1 flex items-center justify-center ${isSubSelected ? 'border-2 border-gray-200' : ''}`}
                            style={{
                              backgroundColor: isSubSelected ? '#fff' : subColor,
                              borderColor: isSubSelected ? '#E5E7EB' : 'transparent',
                            }}
                          >
                            <AppText
                              style={{
                                color: isSubSelected ? subColor : '#fff',
                                fontSize: 22,
                                textAlign: 'center',
                              }}
                            >
                              {subSubcategory.icon}
                            </AppText>
                            <AppText
                              style={{
                                color: isSubSelected ? subColor : '#fff',
                                fontWeight: '600',
                                fontSize: 11,
                                textAlign: 'center',
                                marginTop: -2,
                                lineHeight: 12,
                              }}
                              numberOfLines={1}
                              ellipsizeMode="tail"
                            >
                              {subSubcategory.name}
                            </AppText>
                            {subSubcategory.price && (
                              <AppText
                                style={{
                                  color: isSubSelected ? subColor : '#fff',
                                  fontSize: 9,
                                  textAlign: 'center',
                                  marginTop: -2,
                                }}
                                numberOfLines={1}
                                ellipsizeMode="tail"
                              >
                                {subSubcategory.price.replace(/N\/A - /g, '').replace(/-/g, '').replace(/\$/g, '')}
                              </AppText>
                            )}
                          </StyledTouchableOpacity>
                        </StyledView>
                      );
                    })}
                    </StyledView>
                  </StyledView>
                )}
              </StyledView>
            );
          })}
        </StyledView>
      </StyledView>
    </Animated.View>
  );
}; 