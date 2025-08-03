import { Place } from '../types';

export class DiscoverMapper {
  // Transform raw database place to Place interface
  static mapToPlace(rawPlace: any): Place {
    const latitude = rawPlace.lat || rawPlace.latitude;
    const longitude = rawPlace.lng || rawPlace.longitude;
    
    return {
      place_id: rawPlace.place_id,
      name: rawPlace.name,
      image_url: rawPlace.image_url?.trim() || null,
      description: rawPlace.description || 'No description available',
      type_of_food: rawPlace.type_of_food,
      subtopic: rawPlace.subtopic,
      rating: rawPlace.rating,
      price_range: rawPlace.price_range,
      hours: rawPlace.hours || [],
      address: rawPlace.address,
      lat: latitude,
      lng: longitude,
      latitude: latitude,
      longitude: longitude,
    };
  }

  // Transform array of raw database places to Place array
  static mapToPlaces(rawPlaces: any[]): Place[] {
    return rawPlaces?.map(place => this.mapToPlace(place)) || [];
  }

  // Transform place for API response (with additional fields if needed)
  static mapToApiPlace(place: Place): any {
    return {
      ...place,
      // Add any API-specific transformations here
      display_name: place.name,
      formatted_address: place.address,
      formatted_rating: place.rating?.toFixed(1) || 'N/A',
      formatted_price: place.price_range ? '$'.repeat(place.price_range) : null,
    };
  }

  // Transform array of places for API response
  static mapToApiPlaces(places: Place[]): any[] {
    return places.map(place => this.mapToApiPlace(place));
  }

  // Transform search/filter parameters
  static mapSearchParams(query: string): string {
    return query.trim().toLowerCase();
  }

  // Transform filter parameters
  static mapFilterParams(subtopics: string[]): string[] {
    return subtopics.filter(Boolean);
  }
} 