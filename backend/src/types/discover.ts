export interface Place {
  place_id: string;
  name: string;
  image_url?: string;
  description?: string;
  type_of_food?: string;
  subtopic?: string;
  rating?: number;
  price_range?: number;
  hours: string[];
  address?: string;
  lat?: number;
  lng?: number;
  latitude?: number;
  longitude?: number;
}

export interface FilterOption {
  id: string;
  name: string;
  value: string;
  selected: boolean;
}

export interface DiscoverFilters {
  searchQuery?: string;
  selectedFilters?: string[];
  category?: string;
} 