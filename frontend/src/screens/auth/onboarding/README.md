# Onboarding Module

This module contains all the components, logic, and data for the user onboarding flow in the Ping app.

## Folder Structure

```
onboarding/
├── components/           # React components for each onboarding step
│   ├── WelcomeStep.tsx   # Welcome screen with app introduction
│   ├── PersonalInfoStep.tsx # User personal information input
│   ├── CategoriesStep.tsx   # Category and subcategory selection
│   ├── FinalStep.tsx     # Completion screen
│   └── index.ts          # Component exports
├── hooks/                # Custom React hooks
│   ├── useOnboarding.ts  # Main onboarding logic and state management
│   └── index.ts          # Hook exports
├── data/                 # Static data and constants
│   ├── categories.ts     # Category and subcategory definitions
│   └── index.ts          # Data exports
├── types/                # TypeScript type definitions
│   ├── types.ts          # Interface and type definitions
│   └── index.ts          # Type exports
├── OnboardingScreen.tsx  # Main onboarding screen component
├── index.ts              # Main module exports
└── README.md             # This documentation
```

## Organization by Purpose

### Components (`/components`)
- **WelcomeStep**: Marketing-focused welcome screen with app features
- **PersonalInfoStep**: User information collection (name, birthday, username)
- **CategoriesStep**: Interactive category selection with animations
- **FinalStep**: Completion screen with selected interests summary

### Hooks (`/hooks`)
- **useOnboarding**: Centralized state management and business logic for the entire onboarding flow

### Data (`/data`)
- **categories**: Static data defining all available categories and subcategories with their properties

### Types (`/types`)
- **types**: TypeScript interfaces and type definitions for the onboarding module

## Benefits of This Structure

1. **Separation of Concerns**: Each folder has a specific purpose
2. **Maintainability**: Easy to find and modify specific functionality
3. **Reusability**: Components and hooks can be easily reused
4. **Scalability**: Easy to add new components, hooks, or data
5. **Clean Imports**: Index files provide clean import paths
6. **Type Safety**: Centralized type definitions

## Usage

```typescript
// Import the main onboarding screen
import OnboardingScreen from './onboarding/OnboardingScreen';

// Import specific components
import { WelcomeStep, PersonalInfoStep } from './onboarding/components';

// Import the custom hook
import { useOnboarding } from './onboarding/hooks';

// Import data
import { categories } from './onboarding/data';

// Import types
import { FormData } from './onboarding/types';
``` 