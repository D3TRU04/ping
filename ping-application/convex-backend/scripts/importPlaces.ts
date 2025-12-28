import { client, logProgress } from "./shared";
import fs from "fs";
import path from "path";
import { api } from "../convex/_generated/api";

const PLACE_CATEGORIES = [
  "food_drink",
  "nature_outdoors",
  "social_nightlife",
  "recreation_fitness",
  "shopping",
  "creative_arts",
  "indoor_activities",
];

const SUBCATEGORY_FIELD_MAP: Record<string, string> = {
  food_drink: "food_drink_subcategory",
  nature_outdoors: "nature_outdoors_subcategory",
  social_nightlife: "social_nightlife_subcategory",
  recreation_fitness: "recreation_fitness_subcategory",
  shopping: "shopping_subcategory",
  creative_arts: "creative_arts_subcategory",
  indoor_activities: "indoor_activities_subcategory",
};

async function importPlaces() {
  console.log("🚀 Starting places import (7 categories)...\n");

  let totalImported = 0;

  for (const category of PLACE_CATEGORIES) {
    console.log(`📂 Processing category: ${category}`);

    const filePath = path.join(process.cwd(), "exports", `${category}.json`);

    if (!fs.existsSync(filePath)) {
      console.log(`   ⚠️  File not found, skipping\n`);
      continue;
    }

    const places = JSON.parse(fs.readFileSync(filePath, "utf8"));
    console.log(`   Loaded ${places.length} places`);

    // Transform records
    const transformed = places.map((p: any) => ({
      name: p.name,
      category,
      subcategory: p[SUBCATEGORY_FIELD_MAP[category]] ?? undefined,
      location: p.location,
      lat: Number(p.lat),
      lng: Number(p.lng),
      rating: p.rating ?? undefined,
      priceRange: p.price_range ? String(p.price_range) : undefined,
      hours: Array.isArray(p.hours) ? p.hours.join("\n") : p.hours ?? undefined,
      description: p.description ?? undefined,
      imageUrl: p.image_url ?? undefined,
      websiteUrl: p.website_url ?? undefined,
      insertedAt: p.inserted_at ? Date.parse(p.inserted_at) : Date.now(),
    }));

    const BATCH_SIZE = 100;
    let categoryImported = 0;

    for (let i = 0; i < transformed.length; i += BATCH_SIZE) {
      const batch = transformed.slice(i, i + BATCH_SIZE);

      await client.mutation(api.import.places.insertPlaceBatch, {
        places: batch,
      });

      categoryImported += batch.length;
      logProgress(categoryImported, transformed.length, `${category} places imported`);
    }

    totalImported += categoryImported;
    console.log("");
  }

  console.log(`✅ Places import complete! Total: ${totalImported} across all categories\n`);
}

importPlaces()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Import failed:", err);
    process.exit(1);
  });
