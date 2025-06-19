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
  PersonalInfoStep,
  CategoriesStep,
  FinalStep,
  useOnboarding,
} from './index';

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
    step,
    setStep,
    formData,
    setFormData,
    loading,
    usernameAvailable,
    showDatePicker,
    setShowDatePicker,
    errors,
    expandedCategory,
    setExpandedCategory,
    selectedSubcategories,
    setSelectedSubcategories,
    fadeAnim,
    slideAnim,
    scaleAnim,
    categoryScaleAnims,
    subcategoryAnims,
    validateStep,
    pickImage,
    checkUsername,
    handleCategoryPress,
    handleSubcategoryPress,
    handleSubmit,
  } = useOnboarding();

  const renderStep = () => {
    switch (step) {
      case 1:
        return (
          <WelcomeStep
            fadeAnim={fadeAnim}
            slideAnim={slideAnim}
            scaleAnim={scaleAnim}
          />
        );
      case 2:
        return (
          <PersonalInfoStep
            formData={formData}
            setFormData={setFormData}
            errors={errors}
            usernameAvailable={usernameAvailable}
            showDatePicker={showDatePicker}
            setShowDatePicker={setShowDatePicker}
            checkUsername={checkUsername}
            fadeAnim={fadeAnim}
            slideAnim={slideAnim}
            scaleAnim={scaleAnim}
          />
        );
      case 3:
        return (
          <CategoriesStep
            selectedSubcategories={selectedSubcategories}
            setSelectedSubcategories={setSelectedSubcategories}
            expandedCategory={expandedCategory}
            setExpandedCategory={setExpandedCategory}
            handleCategoryPress={handleCategoryPress}
            handleSubcategoryPress={handleSubcategoryPress}
            categoryScaleAnims={categoryScaleAnims}
            subcategoryAnims={subcategoryAnims}
            fadeAnim={fadeAnim}
            slideAnim={slideAnim}
            scaleAnim={scaleAnim}
          />
        );
      case 4:
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
          <StyledTouchableOpacity 
            className="absolute top-12 left-6 z-10 bg-black/20 rounded-full p-2"
            onPress={() => {
              if (step > 1) {
                setStep(prev => prev - 1);
              } else {
                navigation.navigate('Startup');
              }
            }}
          >
            <Icon name="arrow-back" size={24} color="#FFFFFF" />
          </StyledTouchableOpacity>

          <StyledScrollView
            className="flex-1"
            contentContainerStyle={{ 
              flexGrow: 1,
              justifyContent: 'center',
              paddingHorizontal: 20,
              paddingVertical: 20
            }}
          >
            <StyledView className="flex-1 justify-center">
              {renderStep()}

              <StyledView className="flex-row justify-between mt-8">
                {step > 1 && (
                  <StyledTouchableOpacity
                    className="bg-white/20 rounded-2xl p-4 flex-1 mr-2"
                    onPress={() => setStep(prev => prev - 1)}
                  >
                    <StyledText className="text-white text-center font-bold">Back</StyledText>
                  </StyledTouchableOpacity>
                )}
                <StyledTouchableOpacity
                  className={`${step > 1 ? 'flex-1 ml-2' : 'w-full'} bg-[#E74C3C] rounded-2xl p-4 shadow-lg`}
                  onPress={() => {
                    if (step < 4) {
                      if (step === 2) {
                        const isValid = validateStep();
                        if (isValid) {
                          setStep(prev => prev + 1);
                        } else {
                          Alert.alert('Error', 'Please fill in all required fields correctly.');
                        }
                      } else {
                        setStep(prev => prev + 1);
                      }
                    } else {
                      handleSubmit();
                    }
                  }}
                  disabled={loading || (step === 2 && usernameAvailable === false)}
                >
                  {loading ? (
                    <ActivityIndicator color="#FFF6E3" />
                  ) : (
                    <StyledText className="text-[#FFF6E3] text-center font-bold text-lg">
                      {step === 4 ? 'Get Started' : 'Continue'}
                    </StyledText>
                  )}
                </StyledTouchableOpacity>
              </StyledView>

              {step === 3 && (
                <StyledTouchableOpacity
                  className="mt-4 bg-white/20 rounded-2xl p-4"
                  onPress={() => setStep(4)}
                  disabled={loading}
                >
                  <StyledText className="text-white text-center font-bold">Skip Interests</StyledText>
                </StyledTouchableOpacity>
              )}

              <StyledView className="flex-row justify-center mt-6 space-x-2">
                {[1, 2, 3, 4].map((stepNumber) => (
                  <StyledView
                    key={stepNumber}
                    className={`w-3 h-3 rounded-full ${
                      step === stepNumber ? 'bg-white' : 'bg-white/30'
                    }`}
                  />
                ))}
              </StyledView>
            </StyledView>
          </StyledScrollView>
        </StyledView>
      </LinearGradient>
    </KeyboardAvoidingView>
  );
} 