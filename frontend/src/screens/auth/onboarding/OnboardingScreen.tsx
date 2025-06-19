import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
  ActivityIndicator,
  StatusBar,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { styled } from 'nativewind';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { LinearGradient } from 'expo-linear-gradient';

// Import modular components
import {
  WelcomeStep,
  NameStep,
  BirthdayStep,
  UsernameStep,
  CategorySelectionStep,
  SubcategorySelectionStep,
  FinalStep,
  useOnboarding,
} from './index';
import { categories } from './data';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledScrollView = styled(ScrollView);

type RootStackParamList = {
  [key: string]: any;
};

type OnboardingScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Onboarding'>;

export default function OnboardingScreen() {
  const navigation = useNavigation<OnboardingScreenNavigationProp>();
  
  const {
    currentStep,
    setCurrentStep,
    formData,
    setFormData,
    loading,
    usernameAvailable,
    showDatePicker,
    setShowDatePicker,
    errors,
    selectedCategories,
    setSelectedCategories,
    selectedSubcategories,
    setSelectedSubcategories,
    fadeAnim,
    slideAnim,
    scaleAnim,
    getCurrentStepConfig,
    getTotalSteps,
    validateCurrentStep,
    checkUsername,
    nextStep,
    prevStep,
    handleSubmit,
  } = useOnboarding();

  const stepConfig = getCurrentStepConfig();
  const totalSteps = getTotalSteps();

  const renderCurrentStep = () => {
    switch (stepConfig.type) {
      case 'welcome':
        return (
          <WelcomeStep
            fadeAnim={fadeAnim}
            slideAnim={slideAnim}
            scaleAnim={scaleAnim}
          />
        );
      case 'personal-info':
        if (currentStep === 2) {
          return (
            <NameStep
              formData={formData}
              setFormData={setFormData}
              errors={errors}
              fadeAnim={fadeAnim}
              slideAnim={slideAnim}
              scaleAnim={scaleAnim}
            />
          );
        } else if (currentStep === 3) {
          return (
            <BirthdayStep
              formData={formData}
              setFormData={setFormData}
              errors={errors}
              showDatePicker={showDatePicker}
              setShowDatePicker={setShowDatePicker}
              fadeAnim={fadeAnim}
              slideAnim={slideAnim}
              scaleAnim={scaleAnim}
            />
          );
        } else if (currentStep === 4) {
          return (
            <UsernameStep
              formData={formData}
              setFormData={setFormData}
              errors={errors}
              usernameAvailable={usernameAvailable}
              checkUsername={checkUsername}
              fadeAnim={fadeAnim}
              slideAnim={slideAnim}
              scaleAnim={scaleAnim}
            />
          );
        }
        break;
      case 'category-selection':
        return (
          <CategorySelectionStep
            selectedCategories={selectedCategories}
            setSelectedCategories={setSelectedCategories}
            fadeAnim={fadeAnim}
            slideAnim={slideAnim}
            scaleAnim={scaleAnim}
          />
        );
      case 'subcategory-selection':
        if (stepConfig.categoryId) {
          return (
            <SubcategorySelectionStep
              categoryId={stepConfig.categoryId}
              selectedSubcategories={selectedSubcategories}
              setSelectedSubcategories={setSelectedSubcategories}
              fadeAnim={fadeAnim}
              slideAnim={slideAnim}
              scaleAnim={scaleAnim}
            />
          );
        }
        break;
      case 'final':
        return (
          <FinalStep
            selectedSubcategories={selectedSubcategories}
            fadeAnim={fadeAnim}
            slideAnim={slideAnim}
            scaleAnim={scaleAnim}
            onSkipToHome={() => navigation.navigate('Home')}
          />
        );
      default:
        return null;
    }
  };

  const canGoNext = () => {
    if (stepConfig.type === 'personal-info') {
      if (currentStep === 2) return formData.fullName.trim().length > 0;
      if (currentStep === 3) return true; // Birthday is always valid
      if (currentStep === 4) return formData.username.trim().length >= 3 && usernameAvailable === true;
    }
    if (stepConfig.type === 'category-selection') {
      return selectedCategories.length > 0;
    }
    if (stepConfig.type === 'subcategory-selection' && stepConfig.categoryId) {
      const category = categories.find((c: any) => c.id === stepConfig.categoryId);
      const categorySubcategories = selectedSubcategories.filter((subcategory: string) => 
        category?.subcategories.some((sub: any) => sub.name === subcategory)
      );
      return categorySubcategories.length > 0;
    }
    return true;
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1 }}
    >
      <StatusBar barStyle="light-content" backgroundColor="#FFA726" />
      <LinearGradient
        colors={['#FFA726', '#FFA726', '#FFA726']}
        style={{ flex: 1 }}
      >
        <StyledView className="flex-1">
          {/* Header with back button and progress */}
          <StyledView className="flex-row items-center justify-between px-6 pt-12 pb-4">
            <StyledTouchableOpacity 
              className="bg-black/20 rounded-full p-2"
              onPress={() => {
                if (currentStep > 1) {
                  prevStep();
                } else {
                  navigation.navigate('Startup');
                }
              }}
            >
              <Icon name="arrow-back" size={24} color="#FFFFFF" />
            </StyledTouchableOpacity>
            
            <StyledView className="flex-row space-x-1">
              {Array.from({ length: totalSteps }, (_, i) => (
                <StyledView
                  key={i}
                  className={`w-2 h-2 rounded-full ${
                    i + 1 <= currentStep ? 'bg-white' : 'bg-white/30'
                  }`}
                />
              ))}
            </StyledView>
            
            <StyledView className="w-10" />
          </StyledView>

          {/* Main content */}
          <StyledScrollView
            className="flex-1"
            contentContainerStyle={{ 
              flexGrow: 1,
              paddingHorizontal: 20,
              paddingBottom: 20
            }}
            showsVerticalScrollIndicator={false}
          >
            {renderCurrentStep()}
          </StyledScrollView>

          {/* Bottom navigation */}
          <StyledView className="px-6 pb-8">
            <StyledTouchableOpacity
              className="bg-[#E74C3C] rounded-2xl p-4 shadow-lg"
              onPress={nextStep}
              disabled={loading || !canGoNext()}
              style={{ opacity: canGoNext() ? 1 : 0.5 }}
            >
              {loading ? (
                <ActivityIndicator color="#FFF6E3" />
              ) : (
                <StyledText className="text-[#FFF6E3] text-center font-bold text-lg">
                  {currentStep === totalSteps ? 'Get Started' : 'Continue'}
                </StyledText>
              )}
            </StyledTouchableOpacity>
          </StyledView>
        </StyledView>
      </LinearGradient>
    </KeyboardAvoidingView>
  );
} 