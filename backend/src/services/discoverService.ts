import { supabase } from '../../lib/supabase';
import { Place, FilterOption } from '../types';

export class DiscoverService {
  // Fetch all food places
  static async fetchPlaces(): Promise<Place[]> {
    try {
      const { data, error } = await supabase
        .from('food_places')
        .select('*')
        .limit(50);
        
      if (error) {
        throw error;
      }
      
      // Transform the data to match the Place interface
      const transformedPlaces = data?.map((place: any) => {
        const latitude = place.lat || place.latitude;
        const longitude = place.lng || place.longitude;
        return {
          ...place,
          image_url: place.image_url?.trim() || null,
          description: place.description || 'No description available',
          hours: place.hours || [],
          latitude: latitude,
          longitude: longitude,
          lat: latitude,
          lng: longitude,
        };
      }) || [];
      
      return transformedPlaces;
    } catch (error) {
      return [];
    }
  }

  // Search places by query
  static async searchPlaces(query: string): Promise<Place[]> {
    try {
      const { data, error } = await supabase
        .from('food_places')
        .select('*')
        .or(`name.ilike.%${query}%,description.ilike.%${query}%,type_of_food.ilike.%${query}%`)
        .limit(50);
        
      if (error) {
        throw error;
      }
      
      // Transform the data
      const transformedPlaces = data?.map((place: any) => {
        const latitude = place.lat || place.latitude;
        const longitude = place.lng || place.longitude;
        return {
          ...place,
          image_url: place.image_url?.trim() || null,
          description: place.description || 'No description available',
          hours: place.hours || [],
          latitude: latitude,
          longitude: longitude,
          lat: latitude,
          lng: longitude,
        };
      }) || [];
      
      return transformedPlaces;
    } catch (error) {
      return [];
    }
  }

  // Filter places by subtopic
  static async filterPlacesBySubtopic(subtopics: string[]): Promise<Place[]> {
    try {
      const { data, error } = await supabase
        .from('food_places')
        .select('*')
        .in('subtopic', subtopics)
        .limit(50);
        
      if (error) {
        throw error;
      }
      
      // Transform the data
      const transformedPlaces = data?.map((place: any) => {
        const latitude = place.lat || place.latitude;
        const longitude = place.lng || place.longitude;
        return {
          ...place,
          image_url: place.image_url?.trim() || null,
          description: place.description || 'No description available',
          hours: place.hours || [],
          latitude: latitude,
          longitude: longitude,
          lat: latitude,
          lng: longitude,
        };
      }) || [];
      
      return transformedPlaces;
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
  static async getPlaceById(placeId: string): Promise<Place | null> {
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
      
      // Transform the data
      const latitude = data.lat || data.latitude;
      const longitude = data.lng || data.longitude;
      const transformedPlace = {
        ...data,
        image_url: data.image_url?.trim() || null,
        description: data.description || 'No description available',
        hours: data.hours || [],
        latitude: latitude,
        longitude: longitude,
        lat: latitude,
        lng: longitude,
      };
      
      return transformedPlace;
    } catch (error) {
      return null;
    }
  }
} 