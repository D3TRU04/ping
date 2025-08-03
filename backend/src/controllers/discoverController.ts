import { DiscoverService } from '../services/discoverService';
import { DiscoverMapper } from '../mappers/discoverMapper';
import { Place, FilterOption } from '../types';

export class DiscoverController {
  // Get all places
  static async getPlaces(): Promise<any[]> {
    const places = await DiscoverService.fetchPlaces();
    return DiscoverMapper.mapToApiPlaces(places);
  }

  // Search places
  static async searchPlaces(query: string): Promise<any[]> {
    const places = await DiscoverService.searchPlaces(query);
    return DiscoverMapper.mapToApiPlaces(places);
  }

  // Filter places by subtopic
  static async filterPlacesBySubtopic(subtopics: string[]): Promise<any[]> {
    const places = await DiscoverService.filterPlacesBySubtopic(subtopics);
    return DiscoverMapper.mapToApiPlaces(places);
  }

  // Get available subtopics
  static async getAvailableSubtopics(): Promise<string[]> {
    return await DiscoverService.getAvailableSubtopics();
  }

  // Get place by ID
  static async getPlaceById(placeId: string): Promise<any | null> {
    const place = await DiscoverService.getPlaceById(placeId);
    return place ? DiscoverMapper.mapToApiPlace(place) : null;
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

      return DiscoverMapper.mapToApiPlaces(places);
    } catch (error) {
      return [];
    }
  }
} 