import { DiscoverController } from '../controllers/discoverController';

export class DiscoverRoutes {
  // Get all places
  static async getPlaces(req: any, res: any) {
    try {
      const places = await DiscoverController.getPlaces();
      res.json(places);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch places' });
    }
  }

  // Search places
  static async searchPlaces(req: any, res: any) {
    try {
      const { query } = req.query;
      
      if (!query) {
        return res.status(400).json({ error: 'Search query is required' });
      }
      
      const places = await DiscoverController.searchPlaces(query);
      res.json(places);
    } catch (error) {
      res.status(500).json({ error: 'Failed to search places' });
    }
  }

  // Filter places by subtopic
  static async filterPlacesBySubtopic(req: any, res: any) {
    try {
      const { subtopics } = req.body;
      
      if (!subtopics || !Array.isArray(subtopics)) {
        return res.status(400).json({ error: 'Subtopics array is required' });
      }
      
      const places = await DiscoverController.filterPlacesBySubtopic(subtopics);
      res.json(places);
    } catch (error) {
      res.status(500).json({ error: 'Failed to filter places' });
    }
  }

  // Get available subtopics
  static async getAvailableSubtopics(req: any, res: any) {
    try {
      const subtopics = await DiscoverController.getAvailableSubtopics();
      res.json(subtopics);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch subtopics' });
    }
  }

  // Get place by ID
  static async getPlaceById(req: any, res: any) {
    try {
      const { placeId } = req.params;
      
      if (!placeId) {
        return res.status(400).json({ error: 'Place ID is required' });
      }
      
      const place = await DiscoverController.getPlaceById(placeId);
      
      if (!place) {
        return res.status(404).json({ error: 'Place not found' });
      }
      
      res.json(place);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch place' });
    }
  }

  // Get filtered places
  static async getFilteredPlaces(req: any, res: any) {
    try {
      const { searchQuery, selectedFilters } = req.body;
      
      const places = await DiscoverController.getFilteredPlaces({
        searchQuery,
        selectedFilters,
      });
      
      res.json(places);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch filtered places' });
    }
  }
} 