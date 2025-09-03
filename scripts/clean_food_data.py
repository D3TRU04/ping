import os
import argparse
from dotenv import load_dotenv
from supabase import create_client, Client

# Load .env credentials
load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_ANON_KEY")
supabase: Client = create_client(url, key)

# --------------------------------------------
# Subcategory → Category mapping
# --------------------------------------------
subcategory_to_category = {
    # Cafes & Coffee
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
    "Burger Joints": "Restaurants",
    "Pizzerias & Italian Cuisine": "Restaurants",
    "Vegetarian Cuisine": "Restaurants",
    "Mediterranean & Middle Eastern Cuisine": "Restaurants",
    # Asian Cuisine
    "Chinese Cuisine": "Asian Cuisine",
    "Thai & Southeast Asian Cuisine": "Asian Cuisine",
    "Sushi & Japanese Cuisine": "Asian Cuisine",
    "Korean Cuisine": "Asian Cuisine",
    "Ramen & Noodle Shops": "Asian Cuisine",
    # Street / Food Trucks
    # "Burger Joints": "Street / Food Trucks",
    "Hot Dog Joint": "Street / Food Trucks",
    "BBQ Street Trucks": "Street / Food Trucks",
    "Mexican Food Street Trucks": "Street / Food Trucks",
    "Asian Noodle Street Trucks": "Street / Food Trucks",
    "Indian Food Street Trucks": "Street / Food Trucks",
    "Fusion Street Street Trucks": "Street / Food Trucks",
    # Breakfast & Brunch
    "Bagel Shops": "Breakfast & Brunch",
    "Pancake Houses": "Breakfast & Brunch",
    "Waffle / Crepes": "Breakfast & Brunch",
    "Diners": "Breakfast & Brunch",
    # Healthy Options
    "Vegan & Vegetarian Specialty": "Healthy Options",
    "Tea Houses": "Healthy Options",
    "Salad Bars": "Healthy Options",
    "Healthy / Salad Bars": "Healthy Options",
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
    "Frozen Yogurt": "Dessert Cafes",
}

# --------------------------------------------
# Aliases for normalization
# --------------------------------------------
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
    "mochi": "Mochi Shops",
    "asian noodle street trucks": "Asian Noodle Street Trucks",
    "bbq street trucks": "Bbq Street Trucks",
    "cafes": "Cafes",
    "donut shops": "Donut Shops",
    "fast casual / takeout": "Fast Casual / Takeout",
    "food halls": "Food Halls",
    "food markets": "Food Markets",
    "fusion street street trucks": "Fusion Street Street Trucks",
    "healthy / salad bars": "Healthy / Salad Bars",
    "indian food street trucks": "Indian Food Street Trucks",
    "ramen & noodle shops": "Ramen & Noodle Shops",
    "vegan & vegetarian specialty": "Vegan & Vegetarian Specialty",
    "waffle / crepe cafésdiners": "Waffle / Crepes",
    "Waffle / Crepe CafésDiners": "Waffle / Crepes",
    "Waffle / Crepe Cafés": "Waffle / Crepes",
    "Waffle/Crepe": "Waffle / Crepes",
    "Waffles & Crepes": "Waffle / Crepes",
    "Waffle and Crepe": "Waffle / Crepes",
    "DinersWaffle / Crepes": "Waffle / Crepes",
    "Bubble Tea / Boba": "Bubble Tea / Boba",
    "Bagel Shops": "Bagel Shops",
    "Coffee Shops": "Coffee Shops",
}


# --------------------------------------------
# Normalize a subcategory using aliases
# --------------------------------------------
def normalize_subcategory(raw: str) -> str:
    key = raw.lower().strip().replace("_", " ")
    return subcategory_aliases.get(key, raw.title())

# --------------------------------------------
# Pagination support for fetching all rows
# --------------------------------------------
def fetch_all_food_rows():
    batch_size = 1000
    all_rows = []
    start = 0

    while True:
        response = (
            supabase.table("food_drink")
            .select("place_id, name, food_drink_subcategory, food_drink_category")
            .range(start, start + batch_size - 1)
            .execute()
        )
        batch = response.data
        if not batch:
            break
        all_rows.extend(batch)
        start += batch_size

    return all_rows

# --------------------------------------------
# Update all rows with normalized values
# --------------------------------------------
def update_food_drink_categories(dry_run=False):
    print("📡 Fetching rows from food_drink...")
    rows = fetch_all_food_rows()

    updated_count = 0
    skipped_count = 0

    for row in rows:
        place_id = row.get("place_id")
        raw_subcat = row.get("food_drink_subcategory", "")
        current_cat = row.get("food_drink_category", "")
        name = row.get("name", "[Unnamed]")

        normalized_subcat = normalize_subcategory(raw_subcat)
        expected_cat = subcategory_to_category.get(normalized_subcat)

        if not expected_cat:
            print(f"⚠️  Skipping '{name}' — Unknown subcategory: '{raw_subcat}'")
            skipped_count += 1
            continue

        needs_update = (
            current_cat.strip().title() != expected_cat
            or raw_subcat.strip() != normalized_subcat
        )

        if needs_update:
            print(
                f"\n🔁 {'[DRY RUN] Would update:' if dry_run else 'Updating:'} {name} ({place_id})"
            )
            if raw_subcat.strip() != normalized_subcat:
                print(f"   🏷️  food_drink_subcategory: '{raw_subcat}' → '{normalized_subcat}'")
            if current_cat.strip().title() != expected_cat:
                print(f"   🧩 food_drink_category:    '{current_cat}' → '{expected_cat}'")

            if not dry_run:
                supabase.table("food_drink").update(
                    {
                        "food_drink_subcategory": normalized_subcat,
                        "food_drink_category": expected_cat,
                    }
                ).eq("place_id", place_id).execute()

            updated_count += 1

    print(
        f"\n✅ Done. {updated_count} {'updates simulated' if dry_run else 'rows updated'}. {skipped_count} skipped."
    )

# --------------------------------------------
# CLI entry point
# --------------------------------------------
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Clean and update food_drink categories")
    parser.add_argument("--dry-run", action="store_true", help="Preview changes without updating Supabase")
    args = parser.parse_args()

    update_food_drink_categories(dry_run=args.dry_run)