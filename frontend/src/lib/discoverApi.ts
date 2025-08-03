// API client for discover functionality
const API_BASE_URL = 'http://localhost:3001/api';

interface ApiResponse<T> {
  data?: T;
  error?: string;
}

interface Place {
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

class DiscoverApiClient {
  private baseUrl: string;

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    try {
      const url = `${this.baseUrl}${endpoint}`;

      const response = await fetch(url, {
        headers: {
          'Content-Type': 'application/json',
          ...options.headers,
        },
        ...options,
      });

      const data = await response.json();

      if (!response.ok) {
        return { error: data.error || 'Request failed' };
      }

      return { data };
    } catch (error) {
      return { error: 'Network error' };
    }
  }

  // Get all places
  async getPlaces(): Promise<ApiResponse<Place[]>> {
    return this.request<Place[]>('/discover/places');
  }

  // Search places
  async searchPlaces(query: string): Promise<ApiResponse<Place[]>> {
    return this.request<Place[]>(`/discover/search?query=${encodeURIComponent(query)}`);
  }

  // Filter places by subtopic
  async filterPlacesBySubtopic(subtopics: string[]): Promise<ApiResponse<Place[]>> {
    return this.request<Place[]>('/discover/filter', {
      method: 'POST',
      body: JSON.stringify({ subtopics }),
    });
  }

  // Get available subtopics
  async getAvailableSubtopics(): Promise<ApiResponse<string[]>> {
    return this.request<string[]>('/discover/subtopics');
  }

  // Get place by ID
  async getPlaceById(placeId: string): Promise<ApiResponse<Place>> {
    return this.request<Place>(`/discover/places/${placeId}`);
  }

  // Get filtered places
  async getFilteredPlaces(filters: {
    searchQuery?: string;
    selectedFilters?: string[];
  }): Promise<ApiResponse<Place[]>> {
    return this.request<Place[]>('/discover/filtered', {
      method: 'POST',
      body: JSON.stringify(filters),
    });
  }
}

export const discoverApiClient = new DiscoverApiClient();
export default discoverApiClient; 