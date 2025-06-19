import { useState, useEffect, useRef } from 'react';
import { Alert, Animated } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import * as ImagePicker from 'expo-image-picker';
import { supabase } from '../../../../../lib/supabase';
import { categories } from '../data';
import { FormData } from '../types';

type RootStackParamList = {
  [key: string]: any;
};

type OnboardingScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Onboarding'>;

export const useOnboarding = () => {
  const [step, setStep] = useState(1);
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
  const [expandedCategory, setExpandedCategory] = useState<string | null>(null);
  const [selectedSubcategories, setSelectedSubcategories] = useState<string[]>([]);
  
  // Animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;
  const scaleAnim = useRef(new Animated.Value(0.8)).current;
  const categoryScaleAnims = useRef<Record<string, Animated.Value>>({}).current;
  const subcategoryAnims = useRef<Record<string, Animated.Value>>({}).current;
  
  const navigation = useNavigation<OnboardingScreenNavigationProp>();
  const hasNavigatedRef = useRef(false);

  // Initialize animations
  useEffect(() => {
    categories.forEach(category => {
      categoryScaleAnims[category.id] = new Animated.Value(1);
      category.subcategories.forEach(sub => {
        subcategoryAnims[sub.name] = new Animated.Value(0);
      });
    });
  }, []);

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
  }, [step]);

  const checkSession = async () => {
    const { data: { session }, error } = await supabase.auth.getSession();
    console.log('Session at Onboarding mount:', session);
    if (error) console.error('Error fetching session on mount:', error);
  };

  useEffect(() => {
    checkSession();
  }, []);

  const validateStep = () => {
    const newErrors: Record<string, string> = {};
    
    switch (step) {
      case 1:
        // Welcome step - no validation needed
        break;
      case 2:
        // Personal info step - validate all required fields
        if (!formData.fullName.trim()) {
          newErrors.fullName = 'Full name is required';
        }
        const age = new Date().getFullYear() - formData.birthday.getFullYear();
        if (age < 13) {
          newErrors.birthday = 'You must be at least 13 years old';
        }
        if (!formData.username.trim()) {
          newErrors.username = 'Username is required';
        } else if (formData.username.length < 3) {
          newErrors.username = 'Username must be at least 3 characters';
        } else if (!/^[a-zA-Z0-9_]+$/.test(formData.username)) {
          newErrors.username = 'Username can only contain letters, numbers, and underscores';
        }
        break;
      case 3:
        // Categories step - no validation needed
        break;
      case 4:
        // Final step - no validation needed
        break;
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const pickImage = async () => {
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.5,
      });

      if (!result.canceled) {
        setFormData(prev => ({ ...prev, profilePicture: result.assets[0].uri }));
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to pick image. Please try again.');
    }
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

  const handleCategoryPress = (categoryId: string) => {
    const category = categories.find(c => c.id === categoryId);
    if (!category) return;

    if (expandedCategory === categoryId) {
      // Collapse category
      setExpandedCategory(null);
      Animated.spring(categoryScaleAnims[categoryId], {
        toValue: 1,
        tension: 50,
        friction: 7,
        useNativeDriver: true,
      }).start();
      
      // Animate out subcategories
      category.subcategories.forEach((sub, index) => {
        Animated.timing(subcategoryAnims[sub.name], {
          toValue: 0,
          duration: 200,
          delay: index * 30,
          useNativeDriver: true,
        }).start();
      });
    } else {
      // Collapse previous category
      if (expandedCategory) {
        const prevCategory = categories.find(c => c.id === expandedCategory);
        if (prevCategory) {
          Animated.spring(categoryScaleAnims[expandedCategory], {
            toValue: 1,
            tension: 50,
            friction: 7,
            useNativeDriver: true,
          }).start();
          
          prevCategory.subcategories.forEach((sub, index) => {
            Animated.timing(subcategoryAnims[sub.name], {
              toValue: 0,
              duration: 200,
              delay: index * 20,
              useNativeDriver: true,
            }).start();
          });
        }
      }
      
      // Expand new category
      setExpandedCategory(categoryId);
      Animated.spring(categoryScaleAnims[categoryId], {
        toValue: 1.2,
        tension: 50,
        friction: 7,
        useNativeDriver: true,
      }).start();
      
      // Animate in subcategories with staggered delay
      category.subcategories.forEach((sub, index) => {
        Animated.timing(subcategoryAnims[sub.name], {
          toValue: 1,
          duration: 400,
          delay: index * 80,
          useNativeDriver: true,
        }).start();
      });
    }
  };

  const handleSubcategoryPress = (subcategory: string) => {
    setSelectedSubcategories(prev => {
      const isSelected = prev.includes(subcategory);
      if (isSelected) {
        return prev.filter(s => s !== subcategory);
      } else {
        return [...prev, subcategory];
      }
    });
  };

  const handleSubmit = async () => {
    if (hasNavigatedRef.current) return;
    console.log('Onboarding handleSubmit called');
    if (!validateStep()) {
      Alert.alert('Error', 'Please fill in all required fields correctly.');
      return;
    }

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
          selected_categories: formData.selectedCategories,
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
  };
}; 