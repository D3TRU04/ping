import { useCallback } from 'react';
import { useFocusEffect } from '@react-navigation/native';

interface UseFocusRefreshProps {
  currentUser: any;
  fetchChats: () => Promise<void>;
}

export function useFocusRefresh({ currentUser, fetchChats }: UseFocusRefreshProps) {
  const handleFocusRefresh = useCallback(() => {
    if (currentUser?.id) {
      fetchChats();
    }
  }, [currentUser?.id, fetchChats]);

  useFocusEffect(
    useCallback(() => {
      handleFocusRefresh();
    }, [handleFocusRefresh])
  );
} 