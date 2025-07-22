export interface FoodPlace {
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
    phone?: string;
    lat?: number;
    lng?: number;
    latitude?: number;
    longitude?: number;
}
