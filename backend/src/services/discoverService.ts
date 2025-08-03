import { supabase } from '../../lib/supabase';
import { Place, FilterOption } from '../types';
import { DiscoverMapper } from '../mappers/discoverMapper';

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
      
      return DiscoverMapper.mapToPlaces(data);
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
      
      return DiscoverMapper.mapToPlaces(data);
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
      
      return DiscoverMapper.mapToPlaces(data);
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
      
      return DiscoverMapper.mapToPlace(data);
    } catch (error) {
      return null;
    }
  }
} 