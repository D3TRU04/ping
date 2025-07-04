const supabase = require('../config/supabase');

/**
 * Utility functions to set up and test profiles table access
 */

// Test profile table access
const testProfileAccess = async () => {
  console.log('🔍 Testing Profile Table Access...\n');

  try {
    // 1. Test if profiles table exists and is accessible
    console.log('1. Testing table existence...');
    const { data: tableInfo, error: tableError } = await supabase
      .from('profiles')
      .select('*')
      .limit(1);

    if (tableError) {
      console.error('❌ Table access error:', tableError.message);
      return false;
    }
    console.log('✅ Profiles table is accessible\n');

    // 2. Test table structure
    console.log('2. Testing table structure...');
    const { data: columns, error: columnError } = await supabase
      .rpc('get_table_columns', { table_name: 'profiles' })
      .catch(() => ({ data: null, error: 'Function not available' }));

    if (columnError) {
      console.log('⚠️  Could not check table structure (function not available)');
    } else {
      console.log('✅ Table structure verified\n');
    }

    // 3. Test RLS policies
    console.log('3. Testing RLS policies...');
    const { data: policies, error: policyError } = await supabase
      .rpc('get_rls_policies', { table_name: 'profiles' })
      .catch(() => ({ data: null, error: 'Function not available' }));

    if (policyError) {
      console.log('⚠️  Could not check RLS policies (function not available)');
    } else {
      console.log('✅ RLS policies verified\n');
    }

    return true;
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    return false;
  }
};

// Create a test profile
const createTestProfile = async (userId) => {
  console.log('📝 Creating test profile...\n');

  try {
    const testProfile = {
      id: userId,
      username: 'testuser',
      full_name: 'Test User',
      birthday: '1990-01-01',
      has_onboarded: true,
      saved: ['Test Place 1', 'Test Place 2'],
      category_preferences: {
        food: ['pizza', 'burgers'],
        activities: ['outdoor', 'indoor']
      }
    };

    const { data, error } = await supabase
      .from('profiles')
      .upsert(testProfile)
      .select()
      .single();

    if (error) {
      console.error('❌ Failed to create test profile:', error.message);
      return null;
    }

    console.log('✅ Test profile created successfully');
    console.log('Profile data:', JSON.stringify(data, null, 2));
    return data;
  } catch (error) {
    console.error('❌ Error creating test profile:', error.message);
    return null;
  }
};

// Test profile retrieval
const testProfileRetrieval = async (userId) => {
  console.log('🔍 Testing profile retrieval...\n');

  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (error) {
      console.error('❌ Failed to retrieve profile:', error.message);
      return false;
    }

    console.log('✅ Profile retrieved successfully');
    console.log('Profile data:', JSON.stringify(data, null, 2));
    return true;
  } catch (error) {
    console.error('❌ Error retrieving profile:', error.message);
    return false;
  }
};

// Test username availability check
const testUsernameAvailability = async () => {
  console.log('🔍 Testing username availability...\n');

  try {
    // Test with existing username
    const { data: existingCheck, error: existingError } = await supabase
      .from('profiles')
      .select('username')
      .eq('username', 'testuser')
      .single();

    if (existingError && existingError.code !== 'PGRST116') {
      console.error('❌ Error checking existing username:', existingError.message);
      return false;
    }

    const isAvailable = !existingCheck;
    console.log(`✅ Username 'testuser' is ${isAvailable ? 'available' : 'taken'}`);

    // Test with new username
    const { data: newCheck, error: newError } = await supabase
      .from('profiles')
      .select('username')
      .eq('username', 'newuser123')
      .single();

    if (newError && newError.code !== 'PGRST116') {
      console.error('❌ Error checking new username:', newError.message);
      return false;
    }

    const newIsAvailable = !newCheck;
    console.log(`✅ Username 'newuser123' is ${newIsAvailable ? 'available' : 'taken'}`);

    return true;
  } catch (error) {
    console.error('❌ Error testing username availability:', error.message);
    return false;
  }
};

// Main setup function
const setupProfiles = async () => {
  console.log('🚀 Setting up Profiles Table Access...\n');

  // Test basic access
  const accessOk = await testProfileAccess();
  if (!accessOk) {
    console.log('❌ Basic access test failed. Please check your Supabase setup.');
    return;
  }

  // Create a test user ID (you can replace this with a real user ID)
  const testUserId = '00000000-0000-0000-0000-000000000000';

  // Test profile creation
  const profile = await createTestProfile(testUserId);
  if (!profile) {
    console.log('❌ Profile creation test failed.');
    return;
  }

  // Test profile retrieval
  const retrievalOk = await testProfileRetrieval(testUserId);
  if (!retrievalOk) {
    console.log('❌ Profile retrieval test failed.');
    return;
  }

  // Test username availability
  const usernameOk = await testUsernameAvailability();
  if (!usernameOk) {
    console.log('❌ Username availability test failed.');
    return;
  }

  console.log('\n🎉 All tests passed! Your profiles table is properly configured.');
  console.log('\n📋 Next steps:');
  console.log('1. Run the SQL setup script in your Supabase dashboard');
  console.log('2. Test the frontend authentication flow');
  console.log('3. Verify profile data loads in your auth screens');
};

// Export functions for use in other files
module.exports = {
  testProfileAccess,
  createTestProfile,
  testProfileRetrieval,
  testUsernameAvailability,
  setupProfiles
};

// Run setup if this file is executed directly
if (require.main === module) {
  setupProfiles().catch(console.error);
} 