import csv
import os
import json
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_ANON_KEY")
supabase: Client = create_client(url, key)

TABLE_NAME = "nature_outdoors"
CSV_FILE = "nature_outdoors_data.csv"  # Change to your actual CSV file name
PRIMARY_KEY = "place_id"  # Supabase table's unique ID column

# Step 1: Get all existing place_id values
existing_rows = supabase.table(TABLE_NAME).select(PRIMARY_KEY).execute()
existing_ids = {row[PRIMARY_KEY] for row in existing_rows.data}

# Step 2: Read CSV and insert only new rows
with open(CSV_FILE, newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    new_rows = []

    for row in reader:
        if row[PRIMARY_KEY] in existing_ids:
            continue

        # Fix 'hours' field
        if 'hours' in row and row['hours']:
            try:
                row['hours'] = json.loads(row['hours'])
            except json.JSONDecodeError:
                row['hours'] = []

        # Fix empty strings in integer fields
        INTEGER_FIELDS = ['price_range', 'rating']  # Add more if needed
        for field in INTEGER_FIELDS:
            if field in row and row[field] == "":
                row[field] = None
            elif field in row:
                try:
                    row[field] = int(row[field])
                except ValueError:
                    row[field] = None

        new_rows.append(row)


    # Insert in batches
    if new_rows:
        for i in range(0, len(new_rows), 100):
            batch = new_rows[i:i+100]
            response = supabase.table(TABLE_NAME).insert(batch).execute()
        print(f"✅ Inserted {len(new_rows)} new rows.")
    else:
        print("⚠️ No new rows to insert.")
