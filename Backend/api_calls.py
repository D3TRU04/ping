import os
import time
import json
import requests
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")

TEXT_SEARCH_URL = "https://maps.googleapis.com/maps/api/place/textsearch/json"
PLACE_DETAILS_URL = "https://maps.googleapis.com/maps/api/place/details/json"
PHOTO_URL_TEMPLATE = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference={}&key={}"

### This is has to changed, example - looking fo mexican food ?
QUERY = "Mediterranean & Middle Eastern Cuisine in Austin, Texas"  # Change this to your desired query
TYPE_OF_FOOD = (
    "Mediterranean & Middle Eastern Cuisine"  # Change this to your desired type of food
)
OUTPUT_FILE = "middle_eastern.json"  # Change this to your desired output file name, even if the file doesn't exist


# ------------------------Codebase to gather query information (from above)--------------------------


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


def get_all_places(existing_place_ids):
    all_results = []
    url = TEXT_SEARCH_URL
    params = {"query": QUERY, "key": API_KEY}

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
                "place_id": place_id,  # IMPORTANT: include in saved data
                "name": place.get("name"),
                "location": place.get("formatted_address"),
                "lat": place["geometry"]["location"]["lat"],
                "lng": place["geometry"]["location"]["lng"],
                "rating": place.get("rating"),
                "price_range": place.get("price_level"),
                "type_of_food": TYPE_OF_FOOD,
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


if __name__ == "__main__":
    # Load existing data and place IDs
    existing_place_ids = set()
    if os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, "r") as f:
            existing_data = json.load(f)
            for place in existing_data:
                existing_place_ids.add(place["place_id"])
    else:
        existing_data = []

    # Get only NEW places
    new_places = get_all_places(existing_place_ids)

    # Merge and save
    combined = existing_data + new_places
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(combined, f, ensure_ascii=False, indent=4)

    print(f"✅ Added {len(new_places)} new places. Total now: {len(combined)}")
