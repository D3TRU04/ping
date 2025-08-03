import { DiscoverService } from '../services/discoverService';
import { Place, FilterOption } from '../types';

export class DiscoverController {
  // Get all places
  static async getPlaces(): Promise<Place[]> {
    return await DiscoverService.fetchPlaces();
  }

  // Search places
  static async searchPlaces(query: string): Promise<Place[]> {
    return await DiscoverService.searchPlaces(query);
  }

  // Filter places by subtopic
  static async filterPlacesBySubtopic(subtopics: string[]): Promise<Place[]> {
    return await DiscoverService.filterPlacesBySubtopic(subtopics);
  }

  // Get available subtopics
  static async getAvailableSubtopics(): Promise<string[]> {
    return await DiscoverService.getAvailableSubtopics();
  }

  // Get place by ID
  static async getPlaceById(placeId: string): Promise<Place | null> {
    return await DiscoverService.getPlaceById(placeId);
  }

  // Get filtered places based on search and filters
  static async getFilteredPlaces(filters: {
    searchQuery?: string;
    selectedFilters?: string[];
  }): Promise<Place[]> {
    try {
      let places: Place[] = [];

      // If there's a search query, search first
      if (filters.searchQuery && filters.searchQuery.trim()) {
        places = await DiscoverService.searchPlaces(filters.searchQuery);
      } else {
        // Otherwise get all places
        places = await DiscoverService.fetchPlaces();
      }

      // Apply subtopic filters if any
      if (filters.selectedFilters && filters.selectedFilters.length > 0) {
        places = places.filter(place =>
          filters.selectedFilters!.some(filter => place.subtopic === filter)
        );
      }

      return places;
    } catch (error) {
      return [];
    }
  }
} 