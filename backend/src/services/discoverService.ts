import { supabase } from '../../lib/supabase';
import { Place, FilterOption } from '../types';
import { DiscoverMapper } from '../mappers/discoverMapper';

export class DiscoverService {
  // Fetch all food places
  static async fetchPlaces(): Promise<any[]> {
    try {
      const { data, error } = await supabase
        .from('food_places')
        .select('*')
        .limit(50);
        
      if (error) {
        throw error;
      }
      
      const places = DiscoverMapper.mapToPlaces(data);
      return DiscoverMapper.mapToApiPlaces(places);
    } catch (error) {
      return [];
    }
  }

  // Search places by query
  static async searchPlaces(query: string): Promise<any[]> {
    try {
      const { data, error } = await supabase
        .from('food_places')
        .select('*')
        .or(`name.ilike.%${query}%,description.ilike.%${query}%,type_of_food.ilike.%${query}%`)
        .limit(50);
        
      if (error) {
        throw error;
      }
      
      const places = DiscoverMapper.mapToPlaces(data);
      return DiscoverMapper.mapToApiPlaces(places);
    } catch (error) {
      return [];
    }
  }

  // Filter places by subtopic
  static async filterPlacesBySubtopic(subtopics: string[]): Promise<any[]> {
    try {
      const { data, error } = await supabase
        .from('food_places')
        .select('*')
        .in('subtopic', subtopics)
        .limit(50);
        
      if (error) {
        throw error;
      }
      
      const places = DiscoverMapper.mapToPlaces(data);
      return DiscoverMapper.mapToApiPlaces(places);
    } catch (error) {
      return [];
    }
  }

  // Get all available subtopics for filtering
  static async getAvailableSubtopics(): Promise<string[]> {
    try {
      const { data, error } = await supabase
        .from('food_places')
        .select('subtopic')
        .not('subtopic', 'is', null);
        
      if (error) {
        throw error;
      }
      
      // Extract unique subtopics
      const subtopics = [...new Set(data?.map((place: any) => place.subtopic).filter(Boolean))] as string[];
      
      return subtopics;
    } catch (error) {
      return [];
    }
  }

  // Get place by ID
  static async getPlaceById(placeId: string): Promise<any | null> {
    try {
      const { data, error } = await supabase
        .from('food_places')
        .select('*')
        .eq('place_id', placeId)
        .single();
        
      if (error) {
        return null;
      }
      
      if (!data) {
        return null;
      }
      
      const place = DiscoverMapper.mapToPlace(data);
      return DiscoverMapper.mapToApiPlace(place);
    } catch (error) {
      return null;
    }
  }

  // Get filtered places based on search and filters
  static async getFilteredPlaces(filters: {
    searchQuery?: string;
    selectedFilters?: string[];
  }): Promise<any[]> {
    try {
      let places: Place[] = [];

      // If there's a search query, search first
      if (filters.searchQuery && filters.searchQuery.trim()) {
        const searchResults = await this.searchPlaces(filters.searchQuery);
        places = searchResults.map(apiPlace => ({
          place_id: apiPlace.place_id,
          name: apiPlace.name,
          image_url: apiPlace.image_url,
          description: apiPlace.description,
          type_of_food: apiPlace.type_of_food,
          subtopic: apiPlace.subtopic,
          rating: apiPlace.rating,
          price_range: apiPlace.price_range,
          hours: apiPlace.hours,
          address: apiPlace.address,
          lat: apiPlace.lat,
          lng: apiPlace.lng,
          latitude: apiPlace.latitude,
          longitude: apiPlace.longitude,
        }));
      } else {
        // Otherwise get all places
        const allPlaces = await this.fetchPlaces();
        places = allPlaces.map(apiPlace => ({
          place_id: apiPlace.place_id,
          name: apiPlace.name,
          image_url: apiPlace.image_url,
          description: apiPlace.description,
          type_of_food: apiPlace.type_of_food,
          subtopic: apiPlace.subtopic,
          rating: apiPlace.rating,
          price_range: apiPlace.price_range,
          hours: apiPlace.hours,
          address: apiPlace.address,
          lat: apiPlace.lat,
          lng: apiPlace.lng,
          latitude: apiPlace.latitude,
          longitude: apiPlace.longitude,
        }));
      }

      // Apply subtopic filters if any
      if (filters.selectedFilters && filters.selectedFilters.length > 0) {
        places = places.filter(place =>
          filters.selectedFilters!.some(filter => place.subtopic === filter)
        );
      }

      return DiscoverMapper.mapToApiPlaces(places);
    } catch (error) {
      return [];
    }
  }
} 