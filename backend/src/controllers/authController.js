const supabase = require('../config/supabase');

/**
 * Get user profile from Supabase
 */
const getUserProfile = async (req, res) => {
  try {
    const { user } = req;
    
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single();

    if (error) {
      console.error('Error fetching profile:', error);
      return res.status(500).json({ error: 'Failed to fetch profile' });
    }

    res.json({ profile });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Update user profile during onboarding
 */
const updateUserProfile = async (req, res) => {
  try {
    const { user } = req;
    const { 
      fullName, 
      birthday, 
      username, 
      phoneNumber, 
      profilePictureUrl,
      categoryPreferences 
    } = req.body;

    // Check if username is available (if provided)
    if (username) {
      const { data: existingUser, error: checkError } = await supabase
        .from('profiles')
        .select('username')
        .eq('username', username)
        .neq('id', user.id) // Exclude current user
        .single();

      if (existingUser) {
        return res.status(400).json({ error: 'Username already taken' });
      }
    }

    // Prepare profile data
    const profileData = {
      id: user.id,
      updated_at: new Date().toISOString()
    };

    if (fullName) profileData.full_name = fullName;
    if (birthday) profileData.birthday = birthday;
    if (username) profileData.username = username;
    if (phoneNumber) profileData.phone_number = phoneNumber;
    if (profilePictureUrl) profileData.profile_picture_url = profilePictureUrl;
    if (categoryPreferences) profileData.category_preferences = categoryPreferences;

    // Update profile in Supabase
    const { data, error } = await supabase
      .from('profiles')
      .upsert(profileData)
      .select()
      .single();

    if (error) {
      console.error('Profile update error:', error);
      return res.status(500).json({ error: 'Failed to update profile' });
    }

    res.json({ 
      message: 'Profile updated successfully',
      profile: data 
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Check if username is available
 */
const checkUsernameAvailability = async (req, res) => {
  try {
    const { username } = req.params;
    
    if (!username || username.length < 3) {
      return res.status(400).json({ error: 'Username must be at least 3 characters' });
    }

    const { data, error } = await supabase
      .from('profiles')
      .select('username')
      .eq('username', username)
      .single();

    if (error && error.code !== 'PGRST116') { // PGRST116 = no rows returned
      console.error('Username check error:', error);
      return res.status(500).json({ error: 'Failed to check username' });
    }

    const isAvailable = !data; // If no data found, username is available
    
    res.json({ 
      username,
      available: isAvailable 
    });
  } catch (error) {
    console.error('Username availability check error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getUserProfile,
  updateUserProfile,
  checkUsernameAvailability
}; 