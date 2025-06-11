import { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';

export interface User {
  id: string;
  email: string;
  hasOnboarded: boolean;
  preferences?: {
    nickname: string;
    ageRange: string;
    vibes: string[];
    categories: string[];
    subtopics: string[];
  };
}

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        setUser({
          id: session.user.id,
          email: session.user.email || '',
          hasOnboarded: false,
        });
      }
      setLoading(false);
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        setUser({
          id: session.user.id,
          email: session.user.email || '',
          hasOnboarded: false,
        });
      } else {
        setUser(null);
      }
      setLoading(false);
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const updateUser = async (updatedUser: User) => {
    try {
      // Update user metadata in Supabase
      const { error } = await supabase
        .from('profiles')
        .upsert({
          id: updatedUser.id,
          has_onboarded: updatedUser.hasOnboarded,
          preferences: updatedUser.preferences,
        });

      if (error) throw error;

      // Update local state
      setUser(updatedUser);
    } catch (error) {
      console.error('Error updating user:', error);
    }
  };

  return {
    user,
    loading,
    updateUser,
  };
} 