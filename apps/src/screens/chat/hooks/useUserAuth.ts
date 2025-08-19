import { useState, useEffect } from 'react';
import { supabase } from '../../../../lib/supabase';

export function useUserAuth(routeCurrentUser: any) {
  const [currentUser, setCurrentUser] = useState<any>(routeCurrentUser);

  // Get currentUser from Supabase auth if not provided via route params
  useEffect(() => {
    const getCurrentUser = async () => {
      if (currentUser?.id) {
        return;
      }

      try {
        const { data: { session }, error } = await supabase.auth.getSession();
        
        if (error) {
          return;
        }

        if (session?.user) {
          // Get user profile from profiles table
          const { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', session.user.id)
            .single();

          if (profileError) {
            return;
          }

          const user = {
            id: session.user.id,
            name: profile?.full_name || session.user.email || 'User',
            avatar: profile?.profile_picture || null,
          };

          setCurrentUser(user);
        }
      } catch (error) {
        // Handle error silently
      }
    };

    getCurrentUser();
  }, []);

  return { currentUser, setCurrentUser };
} 