import os
from dotenv import load_dotenv
from supabase import create_client, Client

# Load Supabase credentials
load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_ANON_KEY")
supabase: Client = create_client(url, key)

# --------------------------------------------
# Known subcategory → category mapping
# --------------------------------------------
subcategory_to_category = {
    "Study Cafés / Quiet Spaces": "Cafes & Coffee",
    "Matcha Cafes": "Cafes & Coffee",
    "Coffee Roasters": "Cafes & Coffee",
    "Espresso Bars": "Cafes & Coffee",
    "Coffee Shops": "Cafes & Coffee",

    # Restaurants
    "Steakhouses & Grills": "Restaurants",
    "Seafood & Fish Cuisine": "Restaurants",
    "Indian & Curry Houses": "Restaurants",
    "Italian Cuisine": "Restaurants",
    "Taco & Mexican Cuisine": "Restaurants",
    "Burger Joint": "Restaurants",
    "Pizzerias & Italian Cuisine": "Restaurants",
    "Vegetarian Cuisine": "Restaurants",
    "Mediterranean & Middle Eastern Cuisine": "Restaurants",

    # Asian Cuisine
    "Chinese Cuisine": "Asian Cuisine",
    "Thai & Southeast Asian Cuisine": "Asian Cuisine",
    "Sushi & Japanese Cuisine": "Asian Cuisine",
    "Korean Cuisine": "Asian Cuisine",
    "Ramen & Noodles Shops": "Asian Cuisine",

    # Street / Food Trucks
    "Burger Joints": "Street / Food Trucks",
    "Hot Dog Joint": "Street / Food Trucks",
    "BBQ Street Trucks": "Street / Food Trucks",
    "Mexican Food Street Trucks": "Street / Food Trucks",

    # Breakfast & Brunch
    "Bagel Shops": "Breakfast & Brunch",
    "Pancake Houses": "Breakfast & Brunch",
    "Waffle / Crepes": "Breakfast & Brunch",
    "Diners": "Breakfast & Brunch",

    # Healthy Options
    "Vegan / Vegetarian Speciality": "Healthy Options",
    "Tea Houses": "Healthy Options",
    "Salad Bars": "Healthy Options",

    # Fine Dining
    "Wine Bars": "Fine Dining",
    "Steakhouses & Grills": "Fine Dining",
    "Seafood & Fish Cuisine": "Fine Dining",
    "Italian Cuisine": "Fine Dining",

    # Dessert Cafes
    "Donut Shops & Specialty Bakeries": "Dessert Cafes",
    "Cupcake Shops": "Dessert Cafes",
    "Bakeries": "Dessert Cafes",
    "Cake Shops": "Dessert Cafes",
    "Ice Cream Shops": "Dessert Cafes",
    "Bubble Tea / Boba": "Dessert Cafes",
    "Mochi Shops": "Dessert Cafes",
    "Frozen Yogurt": "Dessert Cafes"
}

# Optional existing alias map
subcategory_aliases = {
    "study cafes": "Study Cafés / Quiet Spaces",
    "espresso": "Espresso Bars",
    "matcha": "Matcha Cafes",
    "coffee shop": "Coffee Shops",
    "tea": "Tea Houses",
    "salads": "Salad Bars",
    "steakhouse": "Steakhouses & Grills",
    "ice cream": "Ice Cream Shops",
    "boba": "Bubble Tea / Boba",
    "froyo": "Frozen Yogurt",
    "mochi": "Mochi Shops"
    # ... existing aliases
}

# Normalize and map
def normalize_subcategory(raw: str) -> str:
    key = raw.lower().strip().replace("_", " ")
    return subcategory_aliases.get(key, raw.title())

# --------------------------------------------
# Scanner function
# --------------------------------------------
def find_unmapped_subcategories():
    print("🔎 Scanning `food_drink_subcategory` values from `food_drink`...\n")

    response = supabase.table("food_drink").select("food_drink_subcategory").execute()
    rows = response.data

    seen_raw = set()
    unmapped = set()

    for row in rows:
        raw = row.get("food_drink_subcategory", "").strip()
        if not raw or raw in seen_raw:
            continue

        seen_raw.add(raw)
        normalized = normalize_subcategory(raw)

        if normalized not in subcategory_to_category:
            unmapped.add(raw)

    if not unmapped:
        print("✅ All subcategories are recognized and mapped!")
        return

    print("⚠️  Unmapped `food_drink_subcategory` values found:")
    for val in sorted(unmapped):
        print(f"  • '{val}'")

    print("\n💡 Suggested aliases to add to `subcategory_aliases`:")
    for val in sorted(unmapped):
        key = val.lower().strip().replace("_", " ")
        suggestion = val.title()
        print(f'    "{key}": "{suggestion}",')

# --------------------------------------------
# Run it
# --------------------------------------------
if __name__ == "__main__":
    find_unmapped_subcategories()
