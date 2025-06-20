import React, { useRef, useEffect } from 'react';
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
  Animated,
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
  MarketingStep,
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

  const progressAnim = useRef(new Animated.Value((currentStep / totalSteps) * 100)).current;

  useEffect(() => {
    Animated.timing(progressAnim, {
      toValue: (currentStep / totalSteps) * 100,
      duration: 400,
      useNativeDriver: false,
    }).start();
  }, [currentStep, totalSteps]);

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
      case 'marketing':
        return (
          <MarketingStep
            titlePart1={stepConfig.titlePart1}
            highlightedText={stepConfig.highlightedText}
            titlePart2={stepConfig.titlePart2}
            subtitle={stepConfig.subtitle}
            fadeAnim={fadeAnim}
            slideAnim={slideAnim}
            scaleAnim={scaleAnim}
          />
        );
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
      className="flex-1"
    >
      <StatusBar barStyle="light-content" backgroundColor="#FFA726" />
      <LinearGradient
        colors={['#FFA726', '#FFA726', '#FFA726']}
        className="flex-1"
      >
        <StyledView className="flex-1 mt-2">
          {/* Header with back button and progress */}
          <StyledView className="flex-row items-center mt-8 pt-6 pb-2 w-full justify-center">
            <StyledTouchableOpacity 
              className="bg-black/20 rounded-full p-2 ml-8"
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
            {/* Progress Bar - smaller and centered */}
            <StyledView className="h-1 bg-white/30 rounded-full overflow-hidden max-w-md w-1/2 mx-auto ml-8">
              <Animated.View
                className="h-2 bg-white rounded-full"
                style={{ width: progressAnim.interpolate({ inputRange: [0, 100], outputRange: ['0%', '100%'] }) }}
              />
            </StyledView>
          </StyledView>

          {/* Main content */}
          <StyledView className="flex-1 px-5 pb-5">
            {renderCurrentStep()}
          </StyledView>

          {/* Bottom navigation */}
          <StyledView className="px-6 pb-8">
            <StyledTouchableOpacity
              className={`bg-[#E74C3C] rounded-2xl p-4 shadow-lg ${
                canGoNext() ? 'opacity-100' : 'opacity-50'
              }`}
              onPress={nextStep}
              disabled={loading || !canGoNext()}
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



/* -------------------------------aaron ----------------------------------------------- */

// import React, { useState, useEffect, useRef } from 'react';
// import {
//   View,
//   Text,
//   TouchableOpacity,
//   TextInput,
//   KeyboardAvoidingView,
//   Platform,
//   ScrollView,
//   Alert,
//   Image,
//   ActivityIndicator,
//   Animated,
// } from 'react-native';
// import { useNavigation } from '@react-navigation/native';
// import { NativeStackNavigationProp } from '@react-navigation/native-stack';
// import { styled } from 'nativewind';
// import Icon from 'react-native-vector-icons/MaterialIcons';
// import { supabase } from '../../../lib/supabase';
// import * as ImagePicker from 'expo-image-picker';
// import DateTimePicker from '@react-native-community/datetimepicker';

// const StyledView = styled(View);
// const StyledText = styled(Text);
// const StyledTouchableOpacity = styled(TouchableOpacity);
// const StyledTextInput = styled(TextInput);
// const StyledScrollView = styled(ScrollView);
// const StyledImage = styled(Image);

// // Category data structure
// const categories = [
//   {
//     id: 'food-drink',
//     name: 'Food & Drink',
//     color: '#FF6B6B',
//     subcategories: ['Fast Food', 'Seafood', 'Desserts', 'Vegan', 'Japanese', 'Chinese', 'Italian', 'Mexican', 'Healthy', 'Coffee', 'Burgers', 'Pizza', 'Sushi', 'Thai', 'Indian', 'Mediterranean', 'BBQ', 'Breakfast', 'Brunch', 'Fine Dining']
//   },
//   {
//     id: 'shopping-markets',
//     name: 'Shopping & Markets',
//     color: '#4ECDC4',
//     subcategories: ['Malls', 'Boutiques', 'Farmers Markets', 'Thrift', 'Tech Stores', 'Bookstores', 'Jewelry', 'Shoes', 'Clothing', 'Home Decor', 'Electronics', 'Grocery', 'Antiques', 'Art Galleries', 'Flea Markets', 'Department Stores', 'Outlet Malls', 'Local Shops', 'Online Shopping', 'Vintage']
//   },
//   {
//     id: 'creative-arts',
//     name: 'Creative Arts & Crafts',
//     color: '#45B7D1',
//     subcategories: ['Painting', 'Pottery', 'DIY', 'Knitting', 'Drawing', 'Photography', 'Sculpture', 'Digital Art', 'Calligraphy', 'Origami', 'Jewelry Making', 'Woodworking', 'Sewing', 'Crochet', 'Embroidery', 'Glass Blowing', 'Printmaking', 'Collage', 'Mixed Media', 'Animation']
//   },
//   {
//     id: 'social-nightlife',
//     name: 'Social & Nightlife',
//     color: '#96CEB4',
//     subcategories: ['Bars', 'Clubs', 'Karaoke', 'Lounges', 'Pubs', 'Wine Bars', 'Cocktail Bars', 'Dance Clubs', 'Live Music', 'Comedy Clubs', 'Rooftop Bars', 'Speakeasies', 'Sports Bars', 'Jazz Clubs', 'Beer Gardens', 'Hookah Lounges', 'Night Markets', 'Festivals', 'Concerts', 'Parties']
//   },
//   {
//     id: 'recreation-fitness',
//     name: 'Recreation & Fitness',
//     color: '#FFEAA7',
//     subcategories: ['Gym', 'Yoga', 'Sports', 'Skating', 'Swimming', 'Running', 'Cycling', 'Hiking', 'Rock Climbing', 'Tennis', 'Basketball', 'Soccer', 'Volleyball', 'Golf', 'Boxing', 'Martial Arts', 'Pilates', 'CrossFit', 'Dance', 'Meditation']
//   },
//   {
//     id: 'nature-outdoors',
//     name: 'Nature & Outdoors',
//     color: '#DDA0DD',
//     subcategories: ['Hiking', 'Parks', 'Lakes', 'Stargazing', 'Camping', 'Beaches', 'Mountains', 'Forests', 'Gardens', 'Botanical Gardens', 'Wildlife Watching', 'Bird Watching', 'Fishing', 'Kayaking', 'Canoeing', 'Rock Climbing', 'Mountain Biking', 'Skiing', 'Snowboarding', 'Sunset Viewing']
//   },
//   {
//     id: 'indoor-adventure',
//     name: 'Indoor Adventure',
//     color: '#FFB347',
//     subcategories: ['Escape Rooms', 'Bowling', 'Arcades', 'Laser Tag', 'Mini Golf', 'Trampoline Parks', 'Rock Climbing Gyms', 'Virtual Reality', 'Board Game Cafes', 'Karaoke', 'Movie Theaters', 'Museums', 'Aquariums', 'Zoos', 'Science Centers', 'Planetariums', 'Art Galleries', 'Theaters', 'Concert Halls', 'Comedy Shows']
//   },
//   {
//     id: 'sight-seeing',
//     name: 'Sight-Seeing',
//     color: '#98D8C8',
//     subcategories: ['Museums', 'Landmarks', 'Architecture', 'Historical Sites', 'Monuments', 'Statues', 'Churches', 'Temples', 'Castles', 'Palaces', 'Bridges', 'Towers', 'Squares', 'Plazas', 'Gardens', 'Fountains', 'Street Art', 'Viewpoints', 'Observation Decks', 'City Tours']
//   }
// ];

// type RootStackParamList = {
//   [key: string]: any;
// };

// type OnboardingScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Onboarding'>;

// export default function OnboardingScreen() {

//   useEffect(() => {
//   const checkSession = async () => {
//     const { data: { session }, error } = await supabase.auth.getSession();
//     console.log('Session at Onboarding mount:', session);
//     if (error) console.error('Error fetching session on mount:', error);
//   };
//   checkSession();
//   }, []);

//   const [step, setStep] = useState(1);
//   const [formData, setFormData] = useState({
//     fullName: '',
//     birthday: new Date(),
//     username: '',
//     phoneNumber: '',
//     profilePicture: null as string | null,
//     // selectedCategories: [] as string[],
//     // selectedSubcategories: [] as string[],
//   });
//   const [loading, setLoading] = useState(false);
//   const [usernameAvailable, setUsernameAvailable] = useState<boolean | null>(null);
//   const [showDatePicker, setShowDatePicker] = useState(false);
//   const [errors, setErrors] = useState<Record<string, string>>({});
//   const [expandedCategory, setExpandedCategory] = useState<string | null>(null);
//   const [categoryAnimations, setCategoryAnimations] = useState<Record<string, Animated.Value>>({});
//   const [subcategoryAnimations, setSubcategoryAnimations] = useState<Record<string, Animated.Value>>({});
//   const navigation = useNavigation<OnboardingScreenNavigationProp>();
//   const hasNavigatedRef = useRef(false);
//   const subcategoryOpacityRef = useRef(new Animated.Value(0));

//   // Initialize animations for each category
//   useEffect(() => {
//     const animations: Record<string, Animated.Value> = {};
//     const subAnimations: Record<string, Animated.Value> = {};
    
//     categories.forEach(category => {
//       animations[category.id] = new Animated.Value(1);
//       category.subcategories.forEach(subcategory => {
//         subAnimations[subcategory] = new Animated.Value(0);
//       });
//     });
    
//     setCategoryAnimations(animations);
//     setSubcategoryAnimations(subAnimations);
//   }, []);

//   // Animate subcategories when category is expanded
//   useEffect(() => {
//     if (expandedCategory) {
//       const category = categories.find(c => c.id === expandedCategory);
//       if (category) {
//         // Find the Animated.View element and animate it
//         // const animatedView = document.querySelector(`[data-category="${expandedCategory}"]`);
//         // if (animatedView) {
//         //   Animated.timing(new Animated.Value(0), {
//         //     toValue: 1,
//         //     duration: 300,
//         //     useNativeDriver: true,
//         //   }).start();
//         // }
//       }
//     }
//   }, [expandedCategory]);

//   const validateStep = () => {
//     const newErrors: Record<string, string> = {};
    
//     switch (step) {
//       case 1:
//         if (!formData.fullName.trim()) {
//           newErrors.fullName = 'Full name is required';
//         }
//         break;
//       case 2:
//         const age = new Date().getFullYear() - formData.birthday.getFullYear();
//         if (age < 13) {
//           newErrors.birthday = 'You must be at least 13 years old';
//         }
//         break;
//       case 3:
//         if (!formData.username.trim()) {
//           newErrors.username = 'Username is required';
//         } else if (formData.username.length < 3) {
//           newErrors.username = 'Username must be at least 3 characters';
//         } else if (!/^[a-zA-Z0-9_]+$/.test(formData.username)) {
//           newErrors.username = 'Username can only contain letters, numbers, and underscores';
//         }
//         break;
//     }
    
//     setErrors(newErrors);
//     return Object.keys(newErrors).length === 0;
//   };

//   const pickImage = async () => {
//     try {
//       const result = await ImagePicker.launchImageLibraryAsync({
//         mediaTypes: ImagePicker.MediaTypeOptions.Images,
//         allowsEditing: true,
//         aspect: [1, 1],
//         quality: 0.5,
//       });

//       if (!result.canceled) {
//         setFormData(prev => ({ ...prev, profilePicture: result.assets[0].uri }));
//       }
//     } catch (error) {
//       Alert.alert('Error', 'Failed to pick image. Please try again.');
//     }
//   };

//   const checkUsername = async (username: string) => {
//     if (username.length < 3) {
//       setUsernameAvailable(null);
//       return;
//     }

//     try {
//       const { data, error } = await supabase
//         .from('profiles')
//         .select('username')
//         .eq('username', username)
//         .single();

//       setUsernameAvailable(!data);
//     } catch (error) {
//       console.error('Error checking username:', error);
//     }
//   };

//   // Category management functions
//   const handleCategoryPress = (categoryId: string) => {
//     const category = categories.find(c => c.id === categoryId);
//     if (!category) return;

//     if (expandedCategory === categoryId) {
//       // Collapse the category
//       setExpandedCategory(null);
//       Animated.spring(categoryAnimations[categoryId], {
//         toValue: 1,
//         useNativeDriver: true,
//       }).start();
      
//       // Fade out subcategories
//       Animated.timing(subcategoryOpacityRef.current, {
//         toValue: 0,
//         duration: 200,
//         useNativeDriver: true,
//       }).start();
      
//       // Animate out subcategories
//       category.subcategories.forEach((subcategory, index) => {
//         Animated.timing(subcategoryAnimations[subcategory], {
//           toValue: 0,
//           duration: 200,
//           delay: index * 50,
//           useNativeDriver: true,
//         }).start();
//       });
//     } else {
//       // Collapse previous category if any
//       if (expandedCategory) {
//         const prevCategory = categories.find(c => c.id === expandedCategory);
//         if (prevCategory) {
//           Animated.spring(categoryAnimations[expandedCategory], {
//             toValue: 1,
//             useNativeDriver: true,
//           }).start();
          
//           // Animate out previous subcategories
//           prevCategory.subcategories.forEach((subcategory, index) => {
//             Animated.timing(subcategoryAnimations[subcategory], {
//               toValue: 0,
//               duration: 200,
//               delay: index * 30,
//               useNativeDriver: true,
//             }).start();
//           });
//         }
//       }
      
//       // Expand new category
//       setExpandedCategory(categoryId);
//       Animated.spring(categoryAnimations[categoryId], {
//         toValue: 1.1,
//         useNativeDriver: true,
//       }).start();
      
//       // Animate in subcategories with fade-in
//       Animated.timing(subcategoryOpacityRef.current, {
//         toValue: 1,
//         duration: 300,
//         useNativeDriver: true,
//       }).start();
      
//       // Animate in subcategories
//       category.subcategories.forEach((subcategory, index) => {
//         Animated.timing(subcategoryAnimations[subcategory], {
//           toValue: 1,
//           duration: 300,
//           delay: index * 100,
//           useNativeDriver: true,
//         }).start();
//       });
//     }
//   };

//   // const handleSubcategoryPress = (subcategory: string) => {
//   //   setFormData(prev => {
//   //     const isSelected = prev.selectedSubcategories.includes(subcategory);
//   //     if (isSelected) {
//   //       return {
//   //         ...prev,
//   //         selectedSubcategories: prev.selectedSubcategories.filter(s => s !== subcategory)
//   //       };
//   //     } else {
//   //       return {
//   //         ...prev,
//   //         selectedSubcategories: [...prev.selectedSubcategories, subcategory]
//   //       };
//   //     }
//   //   });
//   // };

//   // const isSubcategorySelected = (subcategory: string) => {
//   //   return formData.selectedSubcategories.includes(subcategory);
//   // };

//   const handleSubmit = async () => {
//     if (hasNavigatedRef.current) return;
//     console.log('Onboarding handleSubmit called');
//     if (!validateStep()) {
//       Alert.alert('Error', 'Please fill in all required fields correctly.');
//       return;
//     }

//     setLoading(true);
//     try {
//       // Get the current session first
//       const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      
//       if (sessionError) {
//         console.error('Session error:', sessionError);
//         throw new Error('Failed to get session');
//       }

//       if (!session?.user.id) {
//         console.error('No active session found');
//         throw new Error('No active session found. Please sign in again.');
//       }

//       const user = session.user;
//       console.log('User found:', user.id);

//       let profilePictureUrl = null;
//       if (formData.profilePicture) {
//         const response = await fetch(formData.profilePicture);
//         const blob = await response.blob();
//         const fileExt = formData.profilePicture.split('.').pop();
//         const fileName = `${user.id}-${Date.now()}.${fileExt}`;
//         const { error: uploadError } = await supabase.storage
//           .from('profile-pictures')
//           .upload(fileName, blob);
//         if (uploadError) {
//           console.error('Profile picture upload error:', uploadError);
//           throw uploadError;
//         }
//         profilePictureUrl = `${supabase.storage.from('profile-pictures').getPublicUrl(fileName).data.publicUrl}`;
//       }

//       const { error: upsertError } = await supabase
//         .from('profiles')
//         .upsert({
//           id: user.id,

//           /* COMMENTS DOES NOT EXIST IN PROFILE TABLE */
          
//           // full_name: formData.fullName,
//           // display_name: formData.fullName,
//           birthday: formData.birthday.toISOString(),
//           username: formData.username,
//           // phone_number: formData.phoneNumber || null,
//           // avatar_url: profilePictureUrl,
//           // has_onboarded: true,
//           // selected_categories: formData.selectedCategories,
//           // selected_subcategories: formData.selectedSubcategories,
//         });

//       if (upsertError) {
//         console.error('Supabase upsert error:', upsertError);
//         throw new Error(upsertError.message || 'Failed to update profile');
//       }

//       console.log('Profile updated successfully');
//       hasNavigatedRef.current = true;
      
//       // Check session before navigation
//       const { data: { session: currentSession } } = await supabase.auth.getSession();
//       if (!currentSession) {
//         console.error('No session found after profile update');
//         navigation.navigate('Startup');
//         return;
//       }
      
//       // Add a small delay to ensure session state is updated
//       setTimeout(() => {
//         try {
//           navigation.navigate('Home');
//         } catch (navError) {
//           console.error('Navigation error:', navError);
//           // Fallback to Startup screen if Home navigation fails
//           navigation.navigate('Startup');
//         }
//       }, 100);
//     } catch (error) {
//       console.error('Error updating profile:', error);
//       Alert.alert(
//         'Error',
//         error instanceof Error 
//           ? error.message 
//           : 'Failed to update profile. Please try again.'
//       );
      
//       // If there's an authentication error, navigate back to startup
//       if (error instanceof Error && error.message.includes('session')) {
//         navigation.navigate('Startup');
//       }
//     } finally {
//       setLoading(false);
//     }
//   };

//   const renderStep = () => {
//     switch (step) {
//       case 1:
//         return (
//           <StyledView className="space-y-6">
//             <StyledText className="text-white text-3xl font-bold text-center">What's your name?</StyledText>
//             <StyledView className="space-y-2">
//               <StyledTextInput
//                 className="bg-white/90 rounded-xl p-4 text-gray-800 text-lg"
//                 placeholder="Full Name"
//                 value={formData.fullName}
//                 onChangeText={(text) => setFormData(prev => ({ ...prev, fullName: text }))}
//               />
//               {errors.fullName && (
//                 <StyledText className="text-red-400 text-sm text-center">{errors.fullName}</StyledText>
//               )}
//             </StyledView>
//           </StyledView>
//         );
//       case 2:
//         return (
//           <StyledView className="space-y-6">
//             <StyledText className="text-white text-3xl font-bold text-center">When's your birthday?</StyledText>
//             <StyledView className="space-y-2">
//               <StyledTouchableOpacity
//                 className="bg-white/90 rounded-xl p-4"
//                 onPress={() => setShowDatePicker(true)}
//               >
//                 <StyledText className="text-gray-800 text-lg text-center">
//                   {formData.birthday.toLocaleDateString()}
//                 </StyledText>
//               </StyledTouchableOpacity>
//               {errors.birthday && (
//                 <StyledText className="text-red-400 text-sm text-center">{errors.birthday}</StyledText>
//               )}
//               {showDatePicker && (
//                 <DateTimePicker
//                   value={formData.birthday}
//                   mode="date"
//                   display="default"
//                   onChange={(event, selectedDate) => {
//                     setShowDatePicker(false);
//                     if (selectedDate) {
//                       setFormData(prev => ({ ...prev, birthday: selectedDate }));
//                     }
//                   }}
//                   maximumDate={new Date()}
//                 />
//               )}
//             </StyledView>
//           </StyledView>
//         );
//       case 3:
//         return (
//           <StyledView className="space-y-6">
//             <StyledText className="text-white text-3xl font-bold text-center">Choose a username</StyledText>
//             <StyledView className="space-y-2">
//               <StyledView className="flex-row items-center bg-white/90 rounded-xl px-4">
//                 <StyledText className="text-gray-500 mr-2 text-lg">@</StyledText>
//                 <StyledTextInput
//                   className="flex-1 h-[50px] text-gray-800 text-lg"
//                   placeholder="username"
//                   value={formData.username}
//                   onChangeText={(text) => {
//                     setFormData(prev => ({ ...prev, username: text }));
//                     checkUsername(text);
//                   }}
//                   autoCapitalize="none"
//                 />
//               </StyledView>
//               {errors.username && (
//                 <StyledText className="text-red-400 text-sm text-center">{errors.username}</StyledText>
//               )}
//               {usernameAvailable !== null && (
//                 <StyledText className={`text-sm text-center ${usernameAvailable ? 'text-green-400' : 'text-red-400'}`}>
//                   {usernameAvailable ? 'Username available!' : 'Username taken'}
//                 </StyledText>
//               )}
//             </StyledView>
//           </StyledView>
//         );
//       case 4:
//         return (
//           <StyledView className="space-y-6">
//             <StyledText className="text-white text-3xl font-bold text-center">Optional Information</StyledText>
//             <StyledView className="space-y-6">
//               <StyledView>
//                 <StyledText className="text-white/80 text-lg mb-2 text-center">Phone Number (optional)</StyledText>
//                 <StyledTextInput
//                   className="bg-white/90 rounded-xl p-4 text-gray-800 text-lg"
//                   placeholder="+1 (555) 555-5555"
//                   value={formData.phoneNumber}
//                   onChangeText={(text) => setFormData(prev => ({ ...prev, phoneNumber: text }))}
//                   keyboardType="phone-pad"
//                 />
//               </StyledView>
//               <StyledView>
//                 <StyledText className="text-white/80 text-lg mb-2 text-center">Profile Picture (optional)</StyledText>
//                 <StyledTouchableOpacity
//                   className="bg-white/90 rounded-xl p-4 items-center"
//                   onPress={pickImage}
//                 >
//                   <StyledText className="text-gray-800 text-lg">
//                     {formData.profilePicture ? 'Change Profile Picture' : 'Add Profile Picture'}
//                   </StyledText>
//                 </StyledTouchableOpacity>
//                 {formData.profilePicture && (
//                   <StyledImage
//                     source={{ uri: formData.profilePicture }}
//                     className="w-32 h-32 rounded-full self-center mt-4"
//                   />
//                 )}
//               </StyledView>
//             </StyledView>
//           </StyledView>
//         );
//       case 5:
//         return (
//           <StyledView className="space-y-6">
//             <StyledText className="text-white text-3xl font-bold text-center">What interests you?</StyledText>
//             <StyledText className="text-white/80 text-lg text-center">Tap categories to explore subcategories</StyledText>
            
//             <StyledScrollView 
//               className="flex-1"
//               showsVerticalScrollIndicator={false}
//               contentContainerStyle={{ paddingBottom: 20 }}
//             >
//               <StyledView className="space-y-4">
//                 {categories.map((category) => (
//                   <StyledView key={category.id} className="items-center">
//                     <Animated.View
//                       style={{
//                         transform: [{ scale: categoryAnimations[category.id] || 1 }],
//                       }}
//                     >
//                       <StyledTouchableOpacity
//                         className={`w-36 h-36 rounded-full items-center justify-center shadow-lg ${
//                           expandedCategory === category.id ? 'shadow-2xl' : ''
//                         }`}
//                         style={{ backgroundColor: category.color }}
//                         onPress={() => handleCategoryPress(category.id)}
//                       >
//                         <StyledText className="text-white text-lg font-bold text-center px-4">
//                           {category.name}
//                         </StyledText>
//                       </StyledTouchableOpacity>
//                     </Animated.View>
                    
//                     {/* {expandedCategory === category.id && (
//                       <Animated.View 
//                         className="mt-4 flex-row flex-wrap justify-center"
//                         style={{
//                           opacity: subcategoryOpacityRef.current,
//                         }}
//                       >
//                         {category.subcategories.map((subcategory, index) => (
//                           <StyledTouchableOpacity
//                             key={subcategory}
//                             className={`m-1 px-3 py-2 rounded-full ${
//                               isSubcategorySelected(subcategory)
//                                 ? 'bg-[#E74C3C]'
//                                 : 'bg-white/90'
//                             }`}
//                             onPress={() => handleSubcategoryPress(subcategory)}
//                           >
//                             <StyledText
//                               className={`text-sm font-medium ${
//                                 isSubcategorySelected(subcategory)
//                                   ? 'text-white'
//                                   : 'text-gray-800'
//                               }`}
//                             >
//                               {subcategory}
//                             </StyledText>
//                           </StyledTouchableOpacity>
//                         ))}
//                       </Animated.View>
//                     )} */}
//                   </StyledView>
//                 ))}
//               </StyledView>
//             </StyledScrollView>
            
//             {errors.categories && (
//               <StyledText className="text-red-400 text-sm text-center">{errors.categories}</StyledText>
//             )}
            
//             {/* {formData.selectedSubcategories.length > 0 && (
//               <StyledView className="bg-white/20 rounded-xl p-4">
//                 <StyledText className="text-white text-center font-bold mb-2">
//                   Selected Interests ({formData.selectedSubcategories.length})
//                 </StyledText>
//                 <StyledView className="flex-row flex-wrap justify-center">
//                   {formData.selectedSubcategories.slice(0, 5).map((subcategory) => (
//                     <StyledView
//                       key={subcategory}
//                       className="bg-white/90 rounded-full px-2 py-1 m-1"
//                     >
//                       <StyledText className="text-gray-800 text-xs">{subcategory}</StyledText>
//                     </StyledView>
//                   ))}
//                   {formData.selectedSubcategories.length > 5 && (
//                     <StyledView className="bg-white/90 rounded-full px-2 py-1 m-1">
//                       <StyledText className="text-gray-800 text-xs">
//                         +{formData.selectedSubcategories.length - 5} more
//                       </StyledText>
//                     </StyledView>
//                   )}
//                 </StyledView>
//               </StyledView>
//             )} */}
//           </StyledView>
//         );
//       case 6:
//         return (
//           <StyledView className="space-y-6">
//             <StyledText className="text-white text-3xl font-bold text-center">You're all set!</StyledText>
//             <StyledText className="text-white/80 text-lg text-center">
//               We'll use your interests to personalize your experience
//             </StyledText>
            
//             <StyledView className="bg-white/20 rounded-xl p-6">
//               <StyledText className="text-white text-center font-bold mb-4">
//                 Your Selected Interests
//               </StyledText>
//               <StyledView className="flex-row flex-wrap justify-center">
//                 {/* {formData.selectedSubcategories.map((subcategory) => (
//                   <StyledView
//                     key={subcategory}
//                     className="bg-white/90 rounded-full px-3 py-2 m-1"
//                   >
//                     <StyledText className="text-gray-800 text-sm">{subcategory}</StyledText>
//                   </StyledView>
//                 ))} */}
//               </StyledView>
//             </StyledView>
//           </StyledView>
//         );
//       default:
//         return null;
//     }
//   };

//   const isStepValid = () => {
//     return validateStep();
//   };

//   return (
//     <KeyboardAvoidingView
//       behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
//       style={{ flex: 1, backgroundColor: '#FFA726' }}
//     >
//       <StyledView className="flex-1 bg-[#FFA726]">
//         <StyledTouchableOpacity 
//           className="absolute top-12 left-6 z-10 bg-black/8 rounded-full p-1.5"
//           onPress={() => navigation.navigate('Startup')}
//         >
//           <Icon name="arrow-back" size={28} color="#FFFFFF" />
//         </StyledTouchableOpacity>

//         <StyledScrollView
//           className="flex-1"
//           contentContainerStyle={{ 
//             flexGrow: 1,
//             justifyContent: 'center',
//             paddingHorizontal: 20,
//             paddingVertical: 20
//           }}
//         >
//           <StyledView className="flex-1 justify-center">
//             {renderStep()}

//             <StyledView className="flex-row justify-between mt-8">
//               {step > 1 && (
//                 <StyledTouchableOpacity
//                   className="bg-white/20 rounded-xl p-4 flex-1 mr-2"
//                   onPress={() => setStep(prev => prev - 1)}
//                 >
//                   <StyledText className="text-white text-center font-bold">Back</StyledText>
//                 </StyledTouchableOpacity>
//               )}
//               <StyledTouchableOpacity
//                 className={`${step > 1 ? 'flex-1 ml-2' : 'w-full'} bg-[#E74C3C] rounded-xl p-4`}
//                 onPress={() => {
//                   if (step < 6) {
//                     const isValid = validateStep();
//                     if (isValid) {
//                       setStep(prev => prev + 1);
//                     } else {
//                       Alert.alert('Error', 'Please fill in all required fields correctly.');
//                     }
//                   } else {
//                     handleSubmit();
//                   }
//                 }}
//                 disabled={loading || (step === 3 && !usernameAvailable)}
//               >
//                 {loading ? (
//                   <ActivityIndicator color="#FFFFFF" />
//                 ) : (
//                   <StyledText className="text-white text-center font-bold">
//                     {step === 6 ? 'Complete' : 'Next'}
//                   </StyledText>
//                 )}
//               </StyledTouchableOpacity>
//             </StyledView>

//             {step === 4 && (
//               <StyledTouchableOpacity
//                 className="mt-4 bg-white/20 rounded-xl p-4"
//                 onPress={handleSubmit}
//                 disabled={loading}
//               >
//                 <StyledText className="text-white text-center font-bold">Skip Optional Fields</StyledText>
//               </StyledTouchableOpacity>
//             )}

//             {step === 5 && (
//               <StyledTouchableOpacity
//                 className="mt-4 bg-white/20 rounded-xl p-4"
//                 onPress={() => setStep(6)}
//                 disabled={loading}
//               >
//                 <StyledText className="text-white text-center font-bold">Skip Interests</StyledText>
//               </StyledTouchableOpacity>
//             )}

//             {step === 6 && (
//               <StyledTouchableOpacity
//                 className="mt-4 bg-green-500/80 rounded-xl p-4"
//                 onPress={() => navigation.navigate('Home')}
//                 disabled={loading}
//               >
//                 <StyledText className="text-white text-center font-bold">🚀 Go to Home (Temporary)</StyledText>
//               </StyledTouchableOpacity>
//             )}
//           </StyledView>
//         </StyledScrollView>
//       </StyledView>
//     </KeyboardAvoidingView>
//   );
// } 