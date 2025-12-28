/**
 * Shared utilities for import mutations
 *
 * These helpers manage Supabase UUID -> Convex _id mappings
 * to ensure idempotency and enable foreign key resolution.
 */

import { DatabaseReader, DatabaseWriter } from "../_generated/server";
import { Id } from "../_generated/dataModel";

/**
 * Get Convex _id for a given Supabase UUID from the mapping table
 */
export async function getConvexId<TableName extends string>(
  db: DatabaseReader,
  supabaseId: string,
  tableName: TableName
): Promise<Id<TableName> | null> {
  const mapping = await db
    .query("idMappings")
    .withIndex("by_supabase_id", (q) =>
      q.eq("supabaseId", supabaseId).eq("tableName", tableName)
    )
    .first();

  return mapping ? (mapping.convexId as Id<TableName>) : null;
}

/**
 * Store a Supabase UUID -> Convex _id mapping
 */
export async function storeMapping<TableName extends string>(
  db: DatabaseWriter,
  supabaseId: string,
  convexId: Id<TableName>,
  tableName: TableName
): Promise<void> {
  await db.insert("idMappings", {
    supabaseId,
    convexId,
    tableName,
  });
}

/**
 * Progress logger for import operations
 */
export class ImportLogger {
  private processed = 0;
  private skipped = 0;
  private errors = 0;
  private startTime = Date.now();
  private readonly logInterval: number;
  private readonly tableName: string;

  constructor(tableName: string, logInterval = 100) {
    this.tableName = tableName;
    this.logInterval = logInterval;
    console.log(`\n🚀 Starting import for ${tableName}...`);
  }

  recordProcessed() {
    this.processed++;
    if (this.processed % this.logInterval === 0) {
      this.logProgress();
    }
  }

  recordSkipped() {
    this.skipped++;
  }

  recordError(error: any, record?: any) {
    this.errors++;
    console.error(`❌ Error processing record:`, {
      error: error.message || error,
      record: record ? JSON.stringify(record).slice(0, 200) : "unknown",
    });
  }

  private logProgress() {
    const elapsed = ((Date.now() - this.startTime) / 1000).toFixed(1);
    const rate = (this.processed / parseFloat(elapsed)).toFixed(1);
    console.log(
      `⏳ ${this.tableName}: ${this.processed} processed, ${this.skipped} skipped, ${this.errors} errors (${rate}/sec)`
    );
  }

  finish(total: number) {
    const elapsed = ((Date.now() - this.startTime) / 1000).toFixed(1);
    console.log(`\n✅ ${this.tableName} import complete!`);
    console.log(`   Total records: ${total}`);
    console.log(`   Inserted: ${this.processed}`);
    console.log(`   Skipped (already exists): ${this.skipped}`);
    console.log(`   Errors: ${this.errors}`);
    console.log(`   Time: ${elapsed}s`);
    console.log(`   Rate: ${(total / parseFloat(elapsed)).toFixed(1)}/sec\n`);

    if (this.errors > 0) {
      throw new Error(
        `Import completed with ${this.errors} errors. Review logs above.`
      );
    }
  }
}

/**
 * Validate required fields on a record
 */
export function validateRequired(
  record: any,
  fields: string[],
  recordType: string
): void {
  for (const field of fields) {
    if (record[field] === undefined || record[field] === null) {
      throw new Error(
        `Missing required field '${field}' in ${recordType}: ${JSON.stringify(record).slice(0, 200)}`
      );
    }
  }
}
