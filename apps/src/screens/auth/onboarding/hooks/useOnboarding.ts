import { useState, useEffect, useRef } from 'react';
import { Alert, Animated } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import * as ImagePicker from 'expo-image-picker';
import { supabase } from '../../../../../lib/supabase';
// import { categories, onboardingSteps } from '../data';
import { categories, onboardingSteps } from '../data';
import { FormData } from '../types';
import notificationsService from '../../../notifications/services/notificationsService';

type RootStackParamList = {
  [key: string]: any;
};

type OnboardingScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Onboarding'>;

export const useOnboarding = () => {
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState<FormData>({
    email: '',
    password: '',
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
    // Base steps (auth-options, email, password, name, birthday, username, MARKETING, category selection)
    let total = 8;
    // Add one step for each selected category (subcategory selection)
    total += selectedCategories.length;
    // Add final step
    total += 1;
    return total;
  };

  // Get current step configuration
  const getCurrentStepConfig = () => {
    if (currentStep === 1) return { type: 'auth-options' as const, title: "Create your account", subtitle: "Choose how you'd like to sign up for Ping" };
    if (currentStep === 2) return { type: 'email' as const, title: "What's your email?", subtitle: "We'll use this to create your account and keep you signed in." };
    if (currentStep === 3) return { type: 'password' as const, title: "Create a password", subtitle: "Choose a strong password to keep your account secure." };
    if (currentStep === 4) return { type: 'personal-info' as const, title: "What's your name?", subtitle: "We'd love to know what to call you" };
    if (currentStep === 5) return { type: 'personal-info' as const, title: "When's your birthday?", subtitle: "We'll use this to personalize your experience" };
    if (currentStep === 6) return { type: 'personal-info' as const, title: 'Choose your username', subtitle: 'This will be your unique identifier on Ping' };
    if (currentStep === 7) return { 
        type: 'marketing' as const, 
        titlePart1: 'Discover amazing places ',
        highlightedText: 'together.',
        titlePart2: '',
        subtitle: 'Connect with friends and explore the best spots in your city.'
    };
    if (currentStep === 8) return { type: 'category-selection' as const, title: 'What interests you most?', subtitle: 'Select the categories that resonate with you' };
    
    // Subcategory selection steps
    const subcategoryStepIndex = currentStep - 9;
    if (subcategoryStepIndex >= 0 && subcategoryStepIndex < selectedCategories.length) {
      const categoryId = selectedCategories[subcategoryStepIndex];
      const category = categories.find(c => c.id === categoryId);
      return { 
        type: 'subcategory-selection' as const, 
        title: category?.name || 'Select Interests',
        subtitle: category?.description || 'Choose your specific interests',
        categoryId 
      };
    }
    
    // Final step
    return { type: 'final' as const, title: "You're all set!", subtitle: 'Welcome to the Ping community' };
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
    if (error) {
      // Handle error silently
    }
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
      case 'auth-options':
        // No validation needed for auth options step
        break;
      case 'email':
        if (!formData.email.trim()) {
          newErrors.email = 'Email is required';
        } else if (!formData.email.includes('@')) {
          newErrors.email = 'Please enter a valid email address';
        }
        break;
      case 'password':
        if (!formData.password.trim()) {
          newErrors.password = 'Password is required';
        } else if (formData.password.length < 8) {
          newErrors.password = 'Password must be at least 8 characters long';
        }
        break;
      case 'personal-info':
        if (currentStep === 4 && !formData.fullName.trim()) {
          newErrors.fullName = 'Full name is required';
        }
        if (currentStep === 5) {
          // const age = new Date().getFullYear() - formData.birthday.getFullYear();
          // if (age < 13) {
          //   newErrors.birthday = 'You must be at least 13 years old';
          // }
        }
        if (currentStep === 6) {
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
      // console.error('Error checking username:', error);
    }
  };

  const nextStep = async () => {
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

  const handleEmailSignup = () => {
    setCurrentStep(2); // Go to email step
  };

  const handleGoogleSignup = () => {
    // TODO: Implement Google OAuth
    Alert.alert('Coming Soon', 'Google sign-up will be available soon!');
  };

  const handleAppleSignup = () => {
    // TODO: Implement Apple OAuth
    Alert.alert('Coming Soon', 'Apple sign-up will be available soon!');
  };

  const prevStep = () => {
    if (currentStep > 1) {
      setCurrentStep(prev => prev - 1);
      }
  };

  const handleSubmit = async () => {
    if (hasNavigatedRef.current) return;
    // console.log('Onboarding handleSubmit called');

    setLoading(true);
    try {
      // First, create the user account using the collected email and password
      const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
        email: formData.email.trim(),
        password: formData.password,
        options: {
          emailRedirectTo: 'ping://onboarding',
        },
      });

      if (signUpError) {
        throw new Error(signUpError.message || 'Failed to create account');
      }

      if (!signUpData.user?.id) {
        throw new Error('Failed to create user account');
      }

      // Now get the session for the newly created user
      const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      
      if (sessionError) {
        // console.error('Session error:', sessionError);
        throw new Error('Failed to get session');
      }

      if (!session?.user.id) {
        // console.error('No active session found');
        throw new Error('No active session found. Please sign in again.');
      }

      const user = session.user;
      // console.log('User found:', user.id);

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
          // console.error('Profile picture upload error:', uploadError);
          throw uploadError;
        }
        profilePictureUrl = `${supabase.storage.from('profile-pictures').getPublicUrl(fileName).data.publicUrl}`;
      }

       // ✅ Build normalized category preferences with cleaned subcategory values
      const categoryPreferences: Record<string, string[]> = {};

      // selectedCategories.forEach(categoryId => {
      //   const category = categories.find(c => c.id === categoryId);
      //   if (!category) return;

      //   const subsForThisCategory: string[] = [];

      //   selectedSubcategories.forEach((userSelectedName) => {
      //     const match = category.subcategories.find(sub => sub.name === userSelectedName);
      //     if (match && match.value) {
      //       subsForThisCategory.push(match.value);
      //     }

      //   });

      //   categoryPreferences[categoryId] = subsForThisCategory;
      // });

      selectedCategories.forEach((categoryId) => {
        const category = categories.find((c) => c.id === categoryId);
        if (!category) return;

        const subsForThisCategory: string[] = [];

        selectedSubcategories.forEach((userSelectedName) => {
          let match: { name: string; value?: string; icon?: string; price?: string } | undefined;

          for (const sub of category.subcategories) {
            match = sub.subSubcategories?.find(
              (subSub: { name: string; value?: string }) => subSub.name === userSelectedName
            );
            if (match) break;
          }

          if (match?.value) {
            subsForThisCategory.push(match.value);
          }
        });

        categoryPreferences[categoryId] = subsForThisCategory;
      });




      // Convert user-facing labels into DB-safe values
      // const cleanedSubcategories = selectedSubcategories.map(subName => {
      //   for (const category of categories) {
      //     const found = category.subcategories.find(sub => sub.name === subName);
      //     if (found) return found.value;
      //   }
      //   return subName; // fallback (just in case)
      // });

      
      const { error: upsertError } = await supabase
        .from('profiles')
        .upsert({
          id: user.id,
          birthday: formData.birthday.toISOString(),
          username: formData.username,
          // selected_categories: selectedCategories,
          // selected_subcategories: cleanedSubcategories, // 👈 now values not labels
          category_preferences: categoryPreferences,
        });

      if (upsertError) {
        // console.error('Supabase upsert error:', upsertError);
        throw new Error(upsertError.message || 'Failed to update profile');
      }

      // Create default notification settings for the new user
      const { error: notificationError } = await supabase
        .from('notification_settings')
        .insert({
          user_id: user.id,
          push_notifications: true,
          email_notifications: true,
          message_notifications: true,
          place_recommendation_notifications: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        });

      if (notificationError) {
        console.error('Error creating notification settings:', notificationError);
        // Don't throw error here as it's not critical for onboarding
        // The user can still complete onboarding and settings will be created later
      } else {
        console.log('Notification settings created successfully for new user');
      }

      // Load notifications in background after successful signup
      notificationsService.loadNotificationsInBackground(user.id)
        .then(({ notifications, counts }) => {
          console.log(`Loaded ${notifications.length} notifications for new user`);
          console.log(`Notification counts:`, counts);
        })
        .catch(error => {
          console.error('Error loading notifications in background:', error);
        });

      // console.log('Profile updated successfully');
      hasNavigatedRef.current = true;
      
      const { data: { session: currentSession } } = await supabase.auth.getSession();
      if (!currentSession) {
        // console.error('No session found after profile update');
        navigation.navigate('Startup');
        return;
      }
      
      setTimeout(() => {
        try {
          navigation.navigate('Home');
        } catch (navError) {
          // console.error('Navigation error:', navError);
          navigation.navigate('Startup');
        }
      }, 100);
    } catch (error) {
      // console.error('Error updating profile:', error);
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
    handleEmailSignup,
    handleGoogleSignup,
    handleAppleSignup,
  };
}; 