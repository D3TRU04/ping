# -----------------------------
# Supabase JSON Insertion Script
# -----------------------------
# This script reads multiple JSON files (each containing food place data)
# and inserts their contents into a Supabase table.

import os
import json
import requests
from dotenv import load_dotenv

# Load Supabase credentials from .env
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")

# Supabase table and list of JSON files to insert
TABLE_NAME = "creative_arts_table"  # Change this to your Supabase table name
JSON_FILES = [
    # "boutiques.json",
    # "bridal_shops.json",
    # "designer_fashion.json",
    # "jewelry_stores.json",
    # "leather_goods.json",
    # "shoe_stores.json",
    # "streetwear.json",
    # "accessories.json",
    # "plant_shops.json",
    # "crystal_spiritual_shops.json",
    # "handmade_artisan_goods.json",
    # "pottery_ceramics_shops.json",
    # "home_decor_boutiques.json",
    # "furniture_stores.json",
    # "candle_shops.json",
    # "kitchen_cookware_stores.json",
    # "art_supply_stores.json",
    # "board_game_puzzle_stores.json",
    # "bookstores.json",
    # "comic_poster_shops.json",
    # "pop_up_markets_fairs.json",
    # "record_stores.json",
    # "toy_model_shops.json",
    # "trading_card_stores.json",
    # "art_studio_classes.json",
    # "mixed_media_collage_classes.json",
    # "pottery_ceramics_studios.json",
    # "printmaking_workshops.json",
    # "resin_art_studios.json",
    # "sculpture_workshops.json",
    # "sip_paint_studios.json",
    # "watercolor_drawing_sessions.json",

    # "candle_soap_making_workshops.json",
    # "embroidery_or_weaving_studios.json",
    # "jewelry_making_studios.json",
    # "knitting_sewing_circles.json",
    # "makerspaces_diy_labs.json",
    # "woodworking_studios.json",
    # "leather_craft_workshops.json",
    # "upcycling_repurposing_classes.json",

    "gallery_events.json",
    "public_art_tours.json",
    "art_lectures_educational_talks.json",
    "art_film_screenings_doc_nights.json",
    "museum_late_nights.json",
    "artist_studio_tours.json",
    "outdoor_art_walks.json",
    "community_art_installations.json",
    
]

# Supabase API request headers
headers = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json",
    "Prefer": "resolution=merge-duplicates",
}


# -----------------------------
# Insert Data Function
# -----------------------------
def insert_data(json_file):
    with open(json_file, "r") as f:
        places = json.load(f)

    success_count = 0
    skip_count = 0
    fail_count = 0

    for place in places:
        # Check for required fields
        if not place.get("place_id") or not place.get("name"):
            print(
                f"⚠️ Skipping: Missing place_id or name → {place.get('name', 'Unnamed')}"
            )
            skip_count += 1
            continue

        # Ensure hours is a list (for JSONB field)
        hours = place.get("hours")
        if not isinstance(hours, list):
            hours = []

        payload = {
            "place_id": place.get("place_id"),
            "name": place.get("name"),
            "location": place.get("location"),
            "lat": place.get("lat"),
            "lng": place.get("lng"),
            "rating": place.get("rating"),
            "price_range": place.get("price_range"),
            "art_type": place.get("type_of_food"),
            "art_subtype": place.get("subtopic"),
            "hours": hours,
            "description": place.get("description"),
            "image_url": place.get("image_url"),
            "website_url": place.get("menu_url"),
        }

        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/{TABLE_NAME}", headers=headers, json=payload
        )

        if response.status_code == 201:
            print(f"✅ Inserted: {place['name']}")
            success_count += 1
        else:
            print(
                f"❌ Failed: {place['name']} — {response.status_code} → {response.text}"
            )
            fail_count += 1

    print("\n=== Summary ===")
    print(f"✅ Inserted: {success_count}")
    print(f"⚠️ Skipped (missing fields): {skip_count}")
    print(f"❌ Failed (errors): {fail_count}")


# -----------------------------
# Main Entry Point
# -----------------------------
if __name__ == "__main__":
    for json_file in JSON_FILES:
        print(f"\n=== Inserting from {json_file} ===")
        insert_data(json_file)
