import os
import json
import requests
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")

### ---------------------------------------------------------------------------------------------------
TABLE_NAME = "food_places"  # Change this to your Supabase table name where you want to insert the data
JSON_FILE = "middle_eastern.json"  # Change this to your desired JSON file name that you created after running the API calls script


### ---------------------------Codebase to insert JSON data into Supabase--------------------------
headers = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json",
    "Prefer": "resolution=merge-duplicates",
}


def insert_data():
    with open(JSON_FILE, "r") as f:
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
            "type_of_food": place.get("type_of_food"),
            "subtopic": place.get("subtopic"),
            "hours": hours,
            "description": place.get("description"),
            "image_url": place.get("image_url"),
            "menu_url": place.get("menu_url"),
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


if __name__ == "__main__":
    insert_data()
