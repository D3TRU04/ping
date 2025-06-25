import { StepConfig } from '../types/types';

export const onboardingSteps: StepConfig[] = [
  // Welcome Steps
  {
    id: 1,
    title: "Welcome to Ping!",
    subtitle: "Let's get you started on your journey",
    type: "welcome",
    validation: false
  },
  
  // Personal Info Steps
  {
    id: 2,
    title: "What's your name?",
    subtitle: "We'd love to know what to call you",
    type: "personal-info",
    validation: true
  },
  {
    id: 3,
    title: "When's your birthday?",
    subtitle: "We'll use this to personalize your experience",
    type: "personal-info",
    validation: true
  },
  {
    id: 4,
    title: "Choose your username",
    subtitle: "This will be your unique identifier on Ping",
    type: "personal-info",
    validation: true
  },
  
  // Category Selection Steps
  {
    id: 5,
    title: "What interests you most?",
    subtitle: "Select the categories that resonate with you",
    type: "category-selection",
    validation: false
  },
  
  // Subcategory Selection Steps (will be dynamically generated)
  // These will be created based on selected categories
  
  // Final Step
  {
    id: 999, // Will be calculated dynamically
    title: "You're all set!",
    subtitle: "Welcome to the Ping community",
    type: "final",
    validation: false
  }
];

export const getStepById = (id: number): StepConfig | undefined => {
  return onboardingSteps.find(step => step.id === id);
};

export const getTotalSteps = (selectedCategories: string[]): number => {
  // Base steps + subcategory steps for each selected category + final step
  return onboardingSteps.length + selectedCategories.length;
}; 