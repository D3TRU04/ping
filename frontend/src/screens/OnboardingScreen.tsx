import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  TextInput,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Animated,
  Dimensions,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { styled } from 'nativewind';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useAuth, User } from '../hooks/useAuth';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);
const StyledScrollView = styled(ScrollView);

const { width } = Dimensions.get('window');

type RootStackParamList = {
  Onboarding: undefined;
  Home: undefined;
};

type OnboardingScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Onboarding'>;

// Age range options
const AGE_RANGES = [
  '18-24',
  '25-34',
  '35-44',
  '45+'
];

// Vibe options
const VIBES = [
  'Chill',
  'Party',
  'Foodie',
  'Adventure',
  'Culture',
  'Relaxed'
];

// Category options
const CATEGORIES = [
  { id: 'food', label: 'Food', icon: 'restaurant' },
  { id: 'adventure', label: 'Adventure', icon: 'explore' },
  { id: 'shopping', label: 'Shopping', icon: 'shopping-bag' },
  { id: 'entertainment', label: 'Entertainment', icon: 'movie' },
];

// Food subtopics
const FOOD_SUBTOPICS = [
  'Korean BBQ',
  'Tacos',
  'Sushi',
  'Italian',
  'Indian',
  'Thai',
  'Mexican',
  'Chinese',
  'Vietnamese',
  'Mediterranean'
];

export default function OnboardingScreen() {
  const navigation = useNavigation<OnboardingScreenNavigationProp>();
  const { user, updateUser } = useAuth();
  const [currentStep, setCurrentStep] = useState(0);
  const [nickname, setNickname] = useState('');
  const [ageRange, setAgeRange] = useState('');
  const [selectedVibes, setSelectedVibes] = useState<string[]>([]);
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [selectedSubtopics, setSelectedSubtopics] = useState<string[]>([]);
  const scrollRef = useRef<ScrollView>(null);

  const steps = [
    'Personal Info',
    'Categories',
    'Subtopics',
    'Review',
  ];

  const handleVibeToggle = (vibe: string) => {
    setSelectedVibes(prev => 
      prev.includes(vibe) 
        ? prev.filter(v => v !== vibe)
        : [...prev, vibe]
    );
  };

  const handleCategoryToggle = (categoryId: string) => {
    setSelectedCategories(prev =>
      prev.includes(categoryId)
        ? prev.filter(c => c !== categoryId)
        : [...prev, categoryId]
    );
  };

  const handleSubtopicToggle = (subtopic: string) => {
    setSelectedSubtopics(prev =>
      prev.includes(subtopic)
        ? prev.filter(s => s !== subtopic)
        : [...prev, subtopic]
    );
  };

  const handleNext = () => {
    if (currentStep < 3) {
      setCurrentStep(prev => {
        const next = prev + 1;
        scrollRef.current?.scrollTo({ x: width * next, animated: true });
        return next;
      });
    } else if (user) {
      // Save user preferences and navigate to home
      const updatedUser: User = {
        id: user.id,
        email: user.email,
        hasOnboarded: true,
        preferences: {
          nickname,
          ageRange,
          vibes: selectedVibes,
          categories: selectedCategories,
          subtopics: selectedSubtopics
        }
      };
      updateUser(updatedUser);
      navigation.navigate('Home');
    }
  };

  const handleBack = () => {
    if (currentStep > 0) {
      setCurrentStep(prev => {
        const next = prev - 1;
        scrollRef.current?.scrollTo({ x: width * next, animated: true });
        return next;
      });
    }
  };

  // Progress Dots
  const renderProgress = () => (
    <StyledView className="flex-row justify-center items-center mt-8 mb-4">
      {steps.map((_, idx) => (
        <StyledView
          key={idx}
          className={`mx-1 w-3 h-3 rounded-full ${idx === currentStep ? 'bg-[#E74C3C]' : 'bg-white/40'}`}
        />
      ))}
    </StyledView>
  );

  // Step Cards
  const renderStep1 = () => (
    <StyledView className="w-full px-4 items-center justify-center">
      <StyledText className="text-3xl font-bold text-white mb-8 text-center">Let's get started!</StyledText>
      <StyledText className="text-white mb-2 text-lg">What should we call you?</StyledText>
      <StyledTextInput
        className="bg-white/90 rounded-xl px-4 h-[50px] text-gray-800 text-base mb-6 w-full"
        placeholder="Enter your nickname"
        placeholderTextColor="#666"
        value={nickname}
        onChangeText={setNickname}
      />
      <StyledText className="text-white mb-2 text-lg">Age Range</StyledText>
      <StyledView className="flex-row flex-wrap gap-2 mb-6 justify-center">
        {AGE_RANGES.map(range => (
          <StyledTouchableOpacity
            key={range}
            className={`px-4 py-2 rounded-full ${ageRange === range ? 'bg-[#E74C3C]' : 'bg-white/20'}`}
            onPress={() => setAgeRange(range)}
          >
            <StyledText className={`${ageRange === range ? 'text-white' : 'text-white/80'}`}>{range}</StyledText>
          </StyledTouchableOpacity>
        ))}
      </StyledView>
      <StyledText className="text-white mb-2 text-lg">What's your vibe?</StyledText>
      <StyledView className="flex-row flex-wrap gap-2 justify-center">
        {VIBES.map(vibe => (
          <StyledTouchableOpacity
            key={vibe}
            className={`px-4 py-2 rounded-full ${selectedVibes.includes(vibe) ? 'bg-[#E74C3C]' : 'bg-white/20'}`}
            onPress={() => handleVibeToggle(vibe)}
          >
            <StyledText className={`${selectedVibes.includes(vibe) ? 'text-white' : 'text-white/80'}`}>{vibe}</StyledText>
          </StyledTouchableOpacity>
        ))}
      </StyledView>
    </StyledView>
  );

  const renderStep2 = () => (
    <StyledView className="w-full px-4 items-center justify-center">
      <StyledText className="text-3xl font-bold text-white mb-8 text-center">What are you usually down for?</StyledText>
      <StyledView className="flex-row flex-wrap gap-4 justify-center">
        {CATEGORIES.map(category => (
          <StyledTouchableOpacity
            key={category.id}
            className={`w-[45%] aspect-square rounded-2xl p-4 items-center justify-center ${selectedCategories.includes(category.id) ? 'bg-[#E74C3C]' : 'bg-white/20'}`}
            onPress={() => handleCategoryToggle(category.id)}
          >
            <Icon name={category.icon} size={32} color="#FFFFFF" />
            <StyledText className="text-white mt-2 text-center">{category.label}</StyledText>
          </StyledTouchableOpacity>
        ))}
      </StyledView>
    </StyledView>
  );

  const renderStep3 = () => (
    <StyledView className="w-full px-4 items-center justify-center">
      <StyledText className="text-3xl font-bold text-white mb-8 text-center">Pick your favorites</StyledText>
      <StyledView className="flex-row flex-wrap gap-2 justify-center">
        {FOOD_SUBTOPICS.map(subtopic => (
          <StyledTouchableOpacity
            key={subtopic}
            className={`px-4 py-2 rounded-full ${selectedSubtopics.includes(subtopic) ? 'bg-[#E74C3C]' : 'bg-white/20'}`}
            onPress={() => handleSubtopicToggle(subtopic)}
          >
            <StyledText className={`${selectedSubtopics.includes(subtopic) ? 'text-white' : 'text-white/80'}`}>{subtopic}</StyledText>
          </StyledTouchableOpacity>
        ))}
      </StyledView>
    </StyledView>
  );

  const renderStep4 = () => (
    <StyledView className="w-full px-4 items-center justify-center">
      <StyledText className="text-3xl font-bold text-white mb-8 text-center">Review your preferences</StyledText>
      <StyledView className="bg-white/10 rounded-2xl p-6 mb-6 w-full">
        <StyledText className="text-white text-lg mb-4">Your Profile</StyledText>
        <StyledText className="text-white/80 mb-2">Nickname: {nickname}</StyledText>
        <StyledText className="text-white/80 mb-2">Age Range: {ageRange}</StyledText>
        <StyledText className="text-white/80 mb-2">Vibes: {selectedVibes.join(', ')}</StyledText>
        <StyledText className="text-white/80 mb-2">Categories: {selectedCategories.map(id => CATEGORIES.find(c => c.id === id)?.label).join(', ')}</StyledText>
        <StyledText className="text-white/80">Food Preferences: {selectedSubtopics.join(', ')}</StyledText>
      </StyledView>
    </StyledView>
  );

  const renderStep = (idx: number) => {
    switch (idx) {
      case 0:
        return renderStep1();
      case 1:
        return renderStep2();
      case 2:
        return renderStep3();
      case 3:
        return renderStep4();
      default:
        return null;
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1 }}
    >
      {/* Subtle background gradient */}
      <StyledView className="absolute inset-0 w-full h-full" style={{ backgroundColor: '#FFA726' }} />
      <StyledView className="flex-1">
        {/* Back Button */}
        <StyledTouchableOpacity
          className="absolute top-12 left-6 z-10 bg-black/10 rounded-full p-2"
          onPress={() => navigation.goBack()}
        >
          <Icon name="arrow-back" size={28} color="#FFF" />
        </StyledTouchableOpacity>
        {renderProgress()}
        <ScrollView
          ref={scrollRef}
          horizontal
          pagingEnabled
          scrollEnabled={false}
          showsHorizontalScrollIndicator={false}
          style={{ flex: 1 }}
        >
          {[0, 1, 2, 3].map(idx => (
            <View key={idx} style={{ width, justifyContent: 'center', alignItems: 'center' }}>
              {renderStep(idx)}
            </View>
          ))}
        </ScrollView>
        {/* Action Buttons */}
        <StyledView className="absolute bottom-8 left-0 right-0 px-8 flex-row justify-between items-center">
          {currentStep > 0 ? (
            <StyledTouchableOpacity
              className="bg-white/30 rounded-xl py-3 px-8"
              onPress={handleBack}
            >
              <StyledText className="text-white text-base font-bold">Back</StyledText>
            </StyledTouchableOpacity>
          ) : <View style={{ width: 80 }} />}
          <StyledTouchableOpacity
            className="bg-[#E74C3C] rounded-xl py-3 px-8 shadow-lg"
            onPress={handleNext}
          >
            <StyledText className="text-[#FFF6E3] text-base font-bold">
              {currentStep === 3 ? "Let's Ping!" : 'Next'}
            </StyledText>
          </StyledTouchableOpacity>
        </StyledView>
      </StyledView>
    </KeyboardAvoidingView>
  );
} 