import os
import requests
import json
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_ANON_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

tables = [
    "social_nightlife"
]

def is_valid_image(url):
    try:
        res = requests.get(url, stream=True, timeout=5)
        content_type = res.headers.get("Content-Type", "")
        res.close()  # Important to close stream
        return res.status_code == 200 and content_type.startswith("image/")
    except Exception:
        return False


broken_images = []

for table in tables:
    print(f"\n🔍 Checking table: {table}")
    try:
        response = supabase.table(table).select("place_id, image_url").execute()
    except Exception as e:
        print(f"❌ Error fetching from {table}: {e}")
        continue


    for row in response.data:
        place_id = row.get("place_id")
        image_url = row.get("image_url")

        if not is_valid_image(image_url):
            print(f"❌ Broken image: {place_id} in {table}")
            broken_images.append({
                "table": table,
                "place_id": place_id,
                "image_url": image_url
            })

# Save to JSON file
if broken_images:
    with open("broken_images_log.json", "w") as f:
        json.dump(broken_images, f, indent=2)
    print(f"\n📁 Saved {len(broken_images)} broken image(s) to broken_images_log.json")
else:
    print("\n✅ All images are valid!")
