# -----------------------------
# Google Places API Automation
# -----------------------------
# This script queries Google Places for various food subcategories in Austin, Texas,
# and saves the results to separate JSON files for each subcategory.

import os
import time
import json
import requests
from dotenv import load_dotenv

# Load API key from .env
load_dotenv()
API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")

# Google Places API endpoints
TEXT_SEARCH_URL = "https://maps.googleapis.com/maps/api/place/textsearch/json"
PLACE_DETAILS_URL = "https://maps.googleapis.com/maps/api/place/details/json"
PHOTO_URL_TEMPLATE = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference={}&key={}"

# List of categories to search for
CATEGORIES = [
   
   "Hiking Trails",
   "Lakes & Rivers",
   "Parks & Gardens",
   "Scenic Viewpoints",
   "Nature Trails",
   "Picnic Areas",
   "Walking Paths / Greenbelts",
   "Sunset / Sunrise Spots",
   "Nature Preserves & Refuges",
   "Beachfront Parks",

]

# -----------------------------
# Helper Functions
# -----------------------------


def get_photo_url(photo_reference):
    return PHOTO_URL_TEMPLATE.format(photo_reference, API_KEY)


# Food subtopic classification based on name and types
def classify_subtopic(name, types):
    name = name.lower()
    types = [t.lower() for t in types]


    # Reference keywords for classification
            # dessert_keywords = [
            #     "ice cream", "donut", "doughnut", "frozen yogurt", "cupcake", "cake",
            #     "bakery", "pastry", "patisserie", "dessert", "sweet", "cookie", "brownie",
            #     "treat", "crepe", "gelato", "froyo", "mochi"
            # ]


    
#    - [ ]  Hiking
# - [ ]  Lakes & Rivers
# - [ ]  Parks & Gardens *(Parks & Botanical Gardens)*
# - [ ]  Scenic Viewpoints
# - [ ]  Nature Trails
# - [ ]  Picnic Areas
# - [ ]  Walking Paths / Greenbelts
# - [ ]  Sunset / Sunrise Spots
# - [ ]  Nature Preserves & Refuges
# - [ ]  Beachfront Parks

    hiking_keywords = ["hiking", "trail", "nature trail", "hiking trail"]
    lakes_rivers_keywords = ["lake", "river", "waterfront", "pond", "creek", "stream"]
    parks_gardens_keywords = ["park", "botanical garden", "garden", "nature reserve"]
    scenic_viewpoints_keywords = ["viewpoint", "scenic overlook", "scenic view"]
    nature_trails_keywords = ["nature trail", "walking trail", "hiking path"]
    picnic_areas_keywords = ["picnic area", "picnic spot", "picnic grove"]
    walking_paths_keywords = ["walking path", "greenbelt", "trail", "pathway"]
    sunset_spots_keywords = ["sunset spot", "sunset view", "sunrise spot", "sunrise view"]
    nature_preserves_keywords = ["nature preserve", "nature refuge", "wildlife refuge"]
    beachfront_parks_keywords = ["beachfront park", "beach park", "beachfront area", "coastal park"]





    if any(keyword in name for keyword in hiking_keywords) or \
         any(keyword in name for keyword in lakes_rivers_keywords) or \
            any(keyword in name for keyword in parks_gardens_keywords) or \
            any(keyword in name for keyword in scenic_viewpoints_keywords) or \
            any(keyword in name for keyword in nature_trails_keywords) or \
            any(keyword in name for keyword in picnic_areas_keywords) or \
            any(keyword in name for keyword in walking_paths_keywords) or \
            any(keyword in name for keyword in sunset_spots_keywords) or \
            any(keyword in name for keyword in nature_preserves_keywords) or \
            any(keyword in name for keyword in beachfront_parks_keywords):
        return "Scenic & Relaxing" # Subcategory
    return "Nature & Outdoors"  # Root Category 
    # if "ice cream" in name or "donut" in name or "doughnut" in name \
    #     or "frozen yogurt" in name or "cupcake" in name or "cake" in name or "bakery" in name \
    #         or "pastry" in name or "patisserie" in name or "dessert" in name or \
    #             "sweet" in name or "cookie" in name or "brownie" in name or "treat" in name or "Crepe" in name:
    #     return "Dessert Cafes"
    # if "truck" in name or "trailer" in name:
    #     return "Street / Food Trucks"
    # if "cafe" in name or "coffee" in name or "espresso" in name or "latte" in name:
    #     return "Coffee Shops"
    # if "bagel" in name or "bagels" in name or "breakfast" in name or "brunch" in name or "breakfast & brunch" in name \
    #     or "diner" in name:
    #     return "Breakfast & Brunch"
    # if "food hall" in name or "food court" in name or "market" in name:
    #     return "Food Halls / Markets"
    # if "juice" in name or "smoothie" in name or "tea" in name or "bubble tea" in name or "boba" in name:
    #     return "Juice / Smoothie Bars"
    # if "meal prep" in name or "meal kit" in name or "meal delivery" in name:
    #     return "Meal Prep / Delivery"
    # if "healthy" in name or "salad" in name or "vegan" in name or "vegetarian" in name \
    #     or "gluten free" in name or "organic" in name: 
    #     return "Healthy / Vegan Options"
    # else:
    #     return "Restaurants"


def get_place_details(place_id):
    params = {"place_id": place_id, "key": API_KEY}
    response = requests.get(PLACE_DETAILS_URL, params=params)
    if response.status_code == 200:
        return response.json().get("result", {})
    return {}


# -----------------------------
# Main Query Logic
# -----------------------------


def get_all_places_for_query(query, type_of_food, existing_place_ids):
    all_results = []
    url = TEXT_SEARCH_URL
    params = {"query": query, "key": API_KEY}

    for _ in range(3):  # Max 3 pages of results
        response = requests.get(url, params=params)
        if response.status_code != 200:
            print("Error:", response.status_code, response.text)
            break

        data = response.json()
        results = data.get("results", [])

        for place in results:
            place_id = place["place_id"]

            if place_id in existing_place_ids:
                print(f"Skipping duplicate: {place['name']}")
                continue

            details = get_place_details(place_id)
            subtopic = classify_subtopic(place.get("name", ""), place.get("types", []))
            photo_url = (
                get_photo_url(place["photos"][0]["photo_reference"])
                if "photos" in place
                else None
            )

            record = {
                "place_id": place_id,
                "name": place.get("name"),
                "location": place.get("formatted_address"),
                "lat": place["geometry"]["location"]["lat"],
                "lng": place["geometry"]["location"]["lng"],
                "rating": place.get("rating"),
                "price_range": place.get("price_level"),
                "type_of_food": type_of_food,
                "subtopic": subtopic,
                "hours": details.get("opening_hours", {}).get("weekday_text", []),
                "description": details.get("editorial_summary", {}).get("overview", ""),
                "image_url": photo_url,
                "menu_url": details.get("website"),
            }

            all_results.append(record)
            existing_place_ids.add(place_id)

        next_page_token = data.get("next_page_token")
        if not next_page_token:
            break
        time.sleep(2)  # Google requires delay
        params = {"pagetoken": next_page_token, "key": API_KEY}

    return all_results


# -----------------------------
# Per-Subcategory Runner
# -----------------------------


def run_for_subcategory(subcategory):
    query = f"{subcategory} in Austin, Texas"
    type_of_food = subcategory
    output_file = (
        subcategory.lower()
        .replace(" & ", "_")
        .replace(" / ", "_")
        .replace(" ", "_")
        .replace("-", "_")
        + ".json"
    )

    # Load existing data and place IDs
    existing_place_ids = set()
    if os.path.exists(output_file):
        with open(output_file, "r") as f:
            existing_data = json.load(f)
            for place in existing_data:
                existing_place_ids.add(place["place_id"])
    else:
        existing_data = []

    # Get only NEW places
    new_places = get_all_places_for_query(query, type_of_food, existing_place_ids)

    # Merge and save
    combined = existing_data + new_places
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(combined, f, ensure_ascii=False, indent=4)

    print(
        f"✅ [{subcategory}] Added {len(new_places)} new places. Total now: {len(combined)}"
    )


# -----------------------------
# Main Entry Point
# -----------------------------

if __name__ == "__main__":
    for subcat in CATEGORIES:
        run_for_subcategory(subcat)
