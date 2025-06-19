export interface FormData {
  fullName: string;
  birthday: Date;
  username: string;
  phoneNumber: string;
  profilePicture: string | null;
  selectedCategories: string[];
  selectedSubcategories: string[];
}

export interface OnboardingStepProps {
  formData: FormData;
  setFormData: (data: FormData | ((prev: FormData) => FormData)) => void;
  errors: Record<string, string>;
  usernameAvailable: boolean | null;
  showDatePicker: boolean;
  setShowDatePicker: (show: boolean) => void;
  checkUsername: (username: string) => void;
  pickImage: () => void;
  selectedSubcategories: string[];
  setSelectedSubcategories: (subcategories: string[]) => void;
  expandedCategory: string | null;
  setExpandedCategory: (category: string | null) => void;
  handleCategoryPress: (categoryId: string) => void;
  handleSubcategoryPress: (subcategory: string) => void;
  categoryScaleAnims: Record<string, any>;
  subcategoryAnims: Record<string, any>;
  fadeAnim: any;
  slideAnim: any;
  scaleAnim: any;
}

// New types for granular steps
export interface CategorySelectionState {
  selectedCategories: string[];
  selectedSubcategories: Record<string, string[]>; // categoryId -> subcategory names
  currentCategory: string | null;
}

export interface StepConfig {
  id: number;
  title: string;
  subtitle: string;
  type: 'welcome' | 'personal-info' | 'category-selection' | 'subcategory-selection' | 'final';
  validation?: boolean;
  categoryId?: string; // For subcategory steps
} 