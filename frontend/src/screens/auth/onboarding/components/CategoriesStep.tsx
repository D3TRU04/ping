import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Animated } from 'react-native';
import { styled } from 'nativewind';
import { LinearGradient } from 'expo-linear-gradient';
import { categories } from '../data';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledScrollView = styled(ScrollView);

interface CategoriesStepProps {
  selectedSubcategories: string[];
  setSelectedSubcategories: (subcategories: string[]) => void;
  expandedCategory: string | null;
  setExpandedCategory: (category: string | null) => void;
  handleCategoryPress: (categoryId: string) => void;
  handleSubcategoryPress: (subcategory: string) => void;
  categoryScaleAnims: Record<string, Animated.Value>;
  subcategoryAnims: Record<string, Animated.Value>;
  fadeAnim: Animated.Value;
  slideAnim: Animated.Value;
  scaleAnim: Animated.Value;
}

export const CategoriesStep: React.FC<CategoriesStepProps> = ({
  selectedSubcategories,
  setSelectedSubcategories,
  expandedCategory,
  setExpandedCategory,
  handleCategoryPress,
  handleSubcategoryPress,
  categoryScaleAnims,
  subcategoryAnims,
  fadeAnim,
  slideAnim,
  scaleAnim,
}) => {
  return (
    <Animated.View 
      style={{ 
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }, { scale: scaleAnim }]
      }}
      className="space-y-6"
    >
      <StyledView className="items-center space-y-4">
        <StyledText className="text-white text-3xl font-bold text-center">
          What interests you?
        </StyledText>
        <StyledText className="text-white/80 text-lg text-center">
          Tap categories to explore and select your interests
        </StyledText>
      </StyledView>

      <StyledScrollView 
        className="flex-1"
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 20 }}
      >
        <StyledView className="space-y-6">
          {categories.map((category) => (
            <StyledView key={category.id} className="items-center">
              <Animated.View
                style={{
                  transform: [{ scale: categoryScaleAnims[category.id] || 1 }],
                }}
              >
                <StyledTouchableOpacity
                  className={`w-32 h-32 rounded-full items-center justify-center shadow-2xl ${
                    expandedCategory === category.id ? 'shadow-3xl' : ''
                  }`}
                  onPress={() => handleCategoryPress(category.id)}
                >
                  <LinearGradient
                    colors={category.gradient}
                    style={{
                      width: '100%',
                      height: '100%',
                      borderRadius: 64,
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    <StyledText className="text-4xl mb-2">{category.icon}</StyledText>
                    <StyledText className="text-white text-sm font-bold text-center px-2">
                      {category.name}
                    </StyledText>
                  </LinearGradient>
                </StyledTouchableOpacity>
              </Animated.View>
              
              {expandedCategory === category.id && (
                <Animated.View 
                  className="mt-6 flex-row flex-wrap justify-center"
                  style={{
                    opacity: subcategoryAnims[category.subcategories[0]?.name] || 0,
                  }}
                >
                  {category.subcategories.map((subcategory, index) => (
                    <Animated.View
                      key={subcategory.name}
                      style={{
                        opacity: subcategoryAnims[subcategory.name] || 0,
                        transform: [{
                          scale: subcategoryAnims[subcategory.name] || 0
                        }],
                      }}
                    >
                      <StyledTouchableOpacity
                        className={`m-2 px-4 py-3 rounded-full ${
                          selectedSubcategories.includes(subcategory.name)
                            ? 'bg-white shadow-lg'
                            : 'bg-white/90'
                        }`}
                        onPress={() => handleSubcategoryPress(subcategory.name)}
                      >
                        <StyledText className="text-2xl mb-1">{subcategory.icon}</StyledText>
                        <StyledText
                          className={`text-xs font-medium text-center ${
                            selectedSubcategories.includes(subcategory.name)
                              ? 'text-gray-800'
                              : 'text-gray-700'
                          }`}
                        >
                          {subcategory.name}
                        </StyledText>
                      </StyledTouchableOpacity>
                    </Animated.View>
                  ))}
                </Animated.View>
              )}
            </StyledView>
          ))}
        </StyledView>
      </StyledScrollView>

      {selectedSubcategories.length > 0 && (
        <StyledView className="bg-white/20 rounded-2xl p-4">
          <StyledText className="text-white text-center font-bold mb-3">
            Selected Interests ({selectedSubcategories.length})
          </StyledText>
          <StyledView className="flex-row flex-wrap justify-center">
            {selectedSubcategories.slice(0, 6).map((subcategory) => (
              <StyledView
                key={subcategory}
                className="bg-white/90 rounded-full px-3 py-2 m-1"
              >
                <StyledText className="text-gray-800 text-xs">{subcategory}</StyledText>
              </StyledView>
            ))}
            {selectedSubcategories.length > 6 && (
              <StyledView className="bg-white/90 rounded-full px-3 py-2 m-1">
                <StyledText className="text-gray-800 text-xs">
                  +{selectedSubcategories.length - 6} more
                </StyledText>
              </StyledView>
            )}
          </StyledView>
        </StyledView>
      )}
    </Animated.View>
  );
}; 