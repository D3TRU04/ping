import { useEffect } from 'react';
import { supabase } from '../../../../lib/supabase';

interface UseDatabaseTestProps {
  currentUser: any;
}

export function useDatabaseTest({ currentUser }: UseDatabaseTestProps) {
  useEffect(() => {
    const testDatabaseSetup = async () => {
      try {
        const { data: test1 } = await supabase.from('messages').select('id').limit(1);
        const testMessage = {
          sender_id: currentUser?.id || 'test',
          receiver_id: 'test',
          conversation_id: 'test',
          message: { text: 'test' },
          created_at: new Date().toISOString(),
          is_read: false,
        };
        const { data: insertResult } = await supabase.from('messages').insert(testMessage).select();
        if (insertResult && insertResult.length > 0) {
          await supabase.from('messages').delete().eq('id', insertResult[0].id);
        }
        const { data: policyTest } = await supabase.from('messages').select('id').limit(1);
      } catch (error) {
        // Handle error silently
      }
    };
    testDatabaseSetup();
  }, [currentUser?.id]);
} 