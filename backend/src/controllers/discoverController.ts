import { DiscoverService } from '../services/discoverService';

export class DiscoverController {
  // Get all places
  static async getPlaces(): Promise<any[]> {
    return await DiscoverService.fetchPlaces();
  }

  // Search places
  static async searchPlaces(query: string): Promise<any[]> {
    return await DiscoverService.searchPlaces(query);
  }

  // Filter places by subtopic
  static async filterPlacesBySubtopic(subtopics: string[]): Promise<any[]> {
    return await DiscoverService.filterPlacesBySubtopic(subtopics);
  }

  // Get available subtopics
  static async getAvailableSubtopics(): Promise<string[]> {
    return await DiscoverService.getAvailableSubtopics();
  }

  // Get place by ID
  static async getPlaceById(placeId: string): Promise<any | null> {
    return await DiscoverService.getPlaceById(placeId);
  }

  // Get filtered places based on search and filters
  static async getFilteredPlaces(filters: {
    searchQuery?: string;
    selectedFilters?: string[];
  }): Promise<any[]> {
    return await DiscoverService.getFilteredPlaces(filters);
  }
} 