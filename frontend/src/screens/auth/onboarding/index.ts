export { 
  WelcomeStep, 
  NameStep, 
  BirthdayStep, 
  UsernameStep, 
  CategorySelectionStep, 
  SubcategorySelectionStep,
  FinalStep
} from './components';
export { useOnboarding } from './hooks';
export { categories, onboardingSteps, getStepById, getTotalSteps } from './data';
export type { FormData, OnboardingStepProps } from './types'; 