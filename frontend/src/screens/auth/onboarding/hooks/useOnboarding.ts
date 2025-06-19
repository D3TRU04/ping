import { useState, useEffect, useRef } from 'react';
import { Alert, Animated } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import * as ImagePicker from 'expo-image-picker';
import { supabase } from '../../../../../lib/supabase';
import { categories, onboardingSteps } from '../data';
import { FormData } from '../types';

type RootStackParamList = {
  [key: string]: any;
};

type OnboardingScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Onboarding'>;

export const useOnboarding = () => {
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState<FormData>({
    fullName: '',
    birthday: new Date(),
    username: '',
    phoneNumber: '',
    profilePicture: null,
    selectedCategories: [],
    selectedSubcategories: [],
  });
  const [loading, setLoading] = useState(false);
  const [usernameAvailable, setUsernameAvailable] = useState<boolean | null>(null);
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [selectedSubcategories, setSelectedSubcategories] = useState<string[]>([]);
  
  // Animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;
  const scaleAnim = useRef(new Animated.Value(0.8)).current;
  
  const navigation = useNavigation<OnboardingScreenNavigationProp>();
  const hasNavigatedRef = useRef(false);

  // Calculate total steps dynamically
  const getTotalSteps = () => {
    // Base steps (welcome, name, birthday, username, category selection)
    let total = 5;
    // Add one step for each selected category (subcategory selection)
    total += selectedCategories.length;
    // Add final step
    total += 1;
    return total;
  };

  // Get current step configuration
  const getCurrentStepConfig = () => {
    if (currentStep === 1) return { type: 'welcome', title: 'Welcome to Ping!', subtitle: "Let's get you started on your journey" };
    if (currentStep === 2) return { type: 'personal-info', title: "What's your name?", subtitle: "We'd love to know what to call you" };
    if (currentStep === 3) return { type: 'personal-info', title: "When's your birthday?", subtitle: "We'll use this to personalize your experience" };
    if (currentStep === 4) return { type: 'personal-info', title: 'Choose your username', subtitle: 'This will be your unique identifier on Ping' };
    if (currentStep === 5) return { type: 'category-selection', title: 'What interests you most?', subtitle: 'Select the categories that resonate with you' };
    
    // Subcategory selection steps
    const subcategoryStepIndex = currentStep - 6;
    if (subcategoryStepIndex >= 0 && subcategoryStepIndex < selectedCategories.length) {
      const categoryId = selectedCategories[subcategoryStepIndex];
      const category = categories.find(c => c.id === categoryId);
      return { 
        type: 'subcategory-selection', 
        title: category?.name || 'Select Interests',
        subtitle: category?.description || 'Choose your specific interests',
        categoryId 
      };
    }
    
    // Final step
    return { type: 'final', title: "You're all set!", subtitle: 'Welcome to the Ping community' };
  };

  // Animate step transitions
  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 600,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 600,
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnim, {
        toValue: 1,
        tension: 50,
        friction: 7,
        useNativeDriver: true,
      }),
    ]).start();
  }, [currentStep]);

  const checkSession = async () => {
    const { data: { session }, error } = await supabase.auth.getSession();
    console.log('Session at Onboarding mount:', session);
    if (error) console.error('Error fetching session on mount:', error);
  };

  useEffect(() => {
    checkSession();
  }, []);

  // Adjust current step if we're beyond the new total after category changes
  useEffect(() => {
    const totalSteps = getTotalSteps();
    if (currentStep > totalSteps) {
      setCurrentStep(totalSteps);
    }
  }, [selectedCategories, currentStep]);

  const validateCurrentStep = () => {
    const newErrors: Record<string, string> = {};
    const stepConfig = getCurrentStepConfig();
    
    switch (stepConfig.type) {
      case 'personal-info':
        if (currentStep === 2 && !formData.fullName.trim()) {
          newErrors.fullName = 'Full name is required';
        }
        if (currentStep === 3) {
          // const age = new Date().getFullYear() - formData.birthday.getFullYear();
          // if (age < 13) {
          //   newErrors.birthday = 'You must be at least 13 years old';
          // }
        }
        if (currentStep === 4) {
        if (!formData.username.trim()) {
          newErrors.username = 'Username is required';
        } else if (formData.username.length < 3) {
          newErrors.username = 'Username must be at least 3 characters';
        } else if (!/^[a-zA-Z0-9_]+$/.test(formData.username)) {
          newErrors.username = 'Username can only contain letters, numbers, and underscores';
          }
        }
        break;
      case 'category-selection':
        if (selectedCategories.length === 0) {
          newErrors.categories = 'Please select at least one category';
        }
        break;
      case 'subcategory-selection':
        if (stepConfig.categoryId) {
          const category = categories.find(c => c.id === stepConfig.categoryId);
          const categorySubcategories = selectedSubcategories.filter(subcategory => 
            category?.subcategories.some(sub => sub.name === subcategory)
          );
          if (categorySubcategories.length === 0) {
            newErrors.subcategories = 'Please select at least one interest';
          }
        }
        break;
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const checkUsername = async (username: string) => {
    if (username.length < 3) {
      setUsernameAvailable(null);
      return;
    }

    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('username')
        .eq('username', username)
        .single();

      setUsernameAvailable(!data);
    } catch (error) {
      console.error('Error checking username:', error);
    }
  };

  const nextStep = () => {
    if (!validateCurrentStep()) {
      Alert.alert('Error', 'Please fill in all required fields correctly.');
      return;
    }

    const totalSteps = getTotalSteps();
    if (currentStep < totalSteps) {
      setCurrentStep(prev => prev + 1);
    } else {
      handleSubmit();
    }
  };

  const prevStep = () => {
    if (currentStep > 1) {
      setCurrentStep(prev => prev - 1);
      }
  };

  const handleSubmit = async () => {
    if (hasNavigatedRef.current) return;
    console.log('Onboarding handleSubmit called');

    setLoading(true);
    try {
      const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      
      if (sessionError) {
        console.error('Session error:', sessionError);
        throw new Error('Failed to get session');
      }

      if (!session?.user.id) {
        console.error('No active session found');
        throw new Error('No active session found. Please sign in again.');
      }

      const user = session.user;
      console.log('User found:', user.id);

      let profilePictureUrl = null;
      if (formData.profilePicture) {
        const response = await fetch(formData.profilePicture);
        const blob = await response.blob();
        const fileExt = formData.profilePicture.split('.').pop();
        const fileName = `${user.id}-${Date.now()}.${fileExt}`;
        const { error: uploadError } = await supabase.storage
          .from('profile-pictures')
          .upload(fileName, blob);
        if (uploadError) {
          console.error('Profile picture upload error:', uploadError);
          throw uploadError;
        }
        profilePictureUrl = `${supabase.storage.from('profile-pictures').getPublicUrl(fileName).data.publicUrl}`;
      }

      const { error: upsertError } = await supabase
        .from('profiles')
        .upsert({
          id: user.id,
          birthday: formData.birthday.toISOString(),
          username: formData.username,
          selected_categories: selectedCategories,
          selected_subcategories: selectedSubcategories,
        });

      if (upsertError) {
        console.error('Supabase upsert error:', upsertError);
        throw new Error(upsertError.message || 'Failed to update profile');
      }

      console.log('Profile updated successfully');
      hasNavigatedRef.current = true;
      
      const { data: { session: currentSession } } = await supabase.auth.getSession();
      if (!currentSession) {
        console.error('No session found after profile update');
        navigation.navigate('Startup');
        return;
      }
      
      setTimeout(() => {
        try {
          navigation.navigate('Home');
        } catch (navError) {
          console.error('Navigation error:', navError);
          navigation.navigate('Startup');
        }
      }, 100);
    } catch (error) {
      console.error('Error updating profile:', error);
      Alert.alert(
        'Error',
        error instanceof Error 
          ? error.message 
          : 'Failed to update profile. Please try again.'
      );
      
      if (error instanceof Error && error.message.includes('session')) {
        navigation.navigate('Startup');
      }
    } finally {
      setLoading(false);
    }
  };

  return {
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
  };
}; 