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

# List of food subcategories to search for
SUBCATEGORIES = [
    "Pizzerias & Italian",
    "Burger Joints",
    "Steakhouses & Grills",
    "Seafood & Fish",
    "Sushi & Japanese Cuisine",
    "Ramen & Noodle Shops",
    "Taco & Mexican Cuisine",
    "Korean BBQ",
    "Chinese",
    "Indian & Curry Houses",
    "Thai & Southeast Asian",
    "Mediterranean & Middle Eastern",
    "Healthy / Salad Bars",
    "Vegan & Vegetarian Specialty",
]

# -----------------------------
# Helper Functions
# -----------------------------

def get_photo_url(photo_reference):
    return PHOTO_URL_TEMPLATE.format(photo_reference, API_KEY)


def classify_subtopic(name, types):
    name = name.lower()
    types = [t.lower() for t in types]

    if "fast" in name or "fast_food" in types:
        return "Fast Food"
    elif "truck" in name or "trailer" in name:
        return "Street / Food Trucks"
    elif "cafe" in name:
        return "Coffee Shops"
    else:
        return "Restaurants"


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
    output_file = subcategory.lower().replace(" & ", "_").replace(" / ", "_").replace(" ", "_").replace("-", "_") + ".json"

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

    print(f"✅ [{subcategory}] Added {len(new_places)} new places. Total now: {len(combined)}")

# -----------------------------
# Main Entry Point
# -----------------------------

if __name__ == "__main__":
    for subcat in SUBCATEGORIES:
        run_for_subcategory(subcat)
