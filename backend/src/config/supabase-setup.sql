-- =====================================================
-- SUPABASE PROFILES TABLE SETUP
-- =====================================================

-- 1. Create or update the profiles table structure
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    profile_picture TEXT,
    birthday DATE,
    phone_number TEXT,
    has_onboarded BOOLEAN DEFAULT FALSE,
    saved TEXT[] DEFAULT '{}',
    category_preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS Policies

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy: Users can view other profiles (for social features)
CREATE POLICY "Users can view other profiles" ON public.profiles
    FOR SELECT USING (true);

-- 4. Create indexes for better performance
CREATE INDEX IF NOT EXISTS profiles_username_idx ON public.profiles(username);
CREATE INDEX IF NOT EXISTS profiles_has_onboarded_idx ON public.profiles(has_onboarded);

-- 5. Create function to handle updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Create trigger to automatically update updated_at
CREATE TRIGGER handle_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 7. Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.profiles TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- =====================================================
-- STORAGE BUCKET SETUP FOR PROFILE PICTURES
-- =====================================================

-- Create storage bucket for profile pictures (run this in Supabase dashboard)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('profile-pictures', 'profile-pictures', true);

-- Storage policy for profile pictures
-- CREATE POLICY "Users can upload own profile picture" ON storage.objects
--     FOR INSERT WITH CHECK (bucket_id = 'profile-pictures' AND auth.uid()::text = (storage.foldername(name))[1]);

-- CREATE POLICY "Users can update own profile picture" ON storage.objects
--     FOR UPDATE USING (bucket_id = 'profile-pictures' AND auth.uid()::text = (storage.foldername(name))[1]);

-- CREATE POLICY "Profile pictures are publicly accessible" ON storage.objects
--     FOR SELECT USING (bucket_id = 'profile-pictures');

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to get user profile with fallbacks
CREATE OR REPLACE FUNCTION public.get_user_profile(user_id UUID)
RETURNS TABLE(
    id UUID,
    username TEXT,
    full_name TEXT,
    avatar_url TEXT,
    profile_picture TEXT,
    birthday DATE,
    phone_number TEXT,
    has_onboarded BOOLEAN,
    saved TEXT[],
    category_preferences JSONB,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.username,
        COALESCE(p.full_name, u.raw_user_meta_data->>'full_name') as full_name,
        p.avatar_url,
        p.profile_picture,
        p.birthday,
        p.phone_number,
        COALESCE(p.has_onboarded, false) as has_onboarded,
        COALESCE(p.saved, ARRAY[]::TEXT[]) as saved,
        COALESCE(p.category_preferences, '{}'::JSONB) as category_preferences,
        p.created_at,
        p.updated_at
    FROM public.profiles p
    LEFT JOIN auth.users u ON p.id = u.id
    WHERE p.id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check username availability
CREATE OR REPLACE FUNCTION public.check_username_availability(check_username TEXT, current_user_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE username = check_username 
        AND (current_user_id IS NULL OR id != current_user_id)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 