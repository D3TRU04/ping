import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

// Use environment variables for Supabase configuration
const supabaseUrl = process.env.SUPABASE_URL || 'https://tghdxomcwphdmnapeuxs.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseServiceKey) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY is required in backend/.env file');
  console.error('Please add your service role key from Supabase dashboard');
  process.exit(1);
}

// Use service role key to bypass RLS policies
export const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
}); 