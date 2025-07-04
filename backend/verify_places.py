import csv
import os

# ---- File paths ----
CSV_INPUT_PATH = "food_places_rows.csv"  # Your original data
APPLE_PREP_PATH = "places_for_apple_maps_check.csv"  # Fill this manually later
MISMATCH_OUTPUT_PATH = "places_to_verify.csv"  # Final mismatches after comparison

# ---- Step 1: Prepare for Apple Maps lookup ----
def prepare_for_apple_maps_check():
    if not os.path.exists(CSV_INPUT_PATH):
        print(f"❌ Input file not found: {CSV_INPUT_PATH}")
        return

    with open(CSV_INPUT_PATH, "r", encoding="utf-8") as infile:
        reader = csv.DictReader(infile)
        rows = [row for row in reader]

    output_headers = ["name", "location", "stored_category", "apple_maps_category", "notes"]

    with open(APPLE_PREP_PATH, "w", newline="", encoding="utf-8") as outfile:
        writer = csv.DictWriter(outfile, fieldnames=output_headers)
        writer.writeheader()
        for row in rows:
            writer.writerow({
                "name": row.get("name", ""),
                "location": row.get("location", ""),
                "stored_category": row.get("category", ""),  # Update this if your CSV uses a different column name
                "apple_maps_category": "",
                "notes": "Fill this in after checking Apple Maps"
            })

    print(f"✅ Prepared CSV for manual Apple Maps lookup: {APPLE_PREP_PATH}")

# ---- Step 2: Compare stored vs Apple Maps categories ----
def compare_categories():
    if not os.path.exists(APPLE_PREP_PATH):
        print(f"❌ Filled file not found: {APPLE_PREP_PATH}")
        return

    with open(APPLE_PREP_PATH, "r", encoding="utf-8") as infile:
        reader = csv.DictReader(infile)
        mismatches = []
        for row in reader:
            stored = row.get("subtopic", "").strip().lower()
            apple = row.get("apple_maps_category", "").strip().lower()
            if stored and apple and stored != apple:
                mismatches.append(row)

    if mismatches:
        with open(MISMATCH_OUTPUT_PATH, "w", newline="", encoding="utf-8") as outfile:
            writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
            writer.writeheader()
            writer.writerows(mismatches)
        print(f"❗ Found {len(mismatches)} mismatches. Saved to: {MISMATCH_OUTPUT_PATH}")
    else:
        print("✅ No mismatches found!")

# ---- Main flow ----
def main():
    print("📦 Step 1: Preparing file for Apple Maps verification...")
    prepare_for_apple_maps_check()
    print("\n📝 After filling in 'apple_maps_category' column manually, re-run this script and uncomment Step 2 below.\n")

    # Uncomment the next two lines after you've filled in the Apple Maps column:
    # print("🔍 Step 2: Comparing stored vs Apple Maps categories...")
    # compare_categories()

if __name__ == "__main__":
    main()
