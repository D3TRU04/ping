import { useState, useEffect, useCallback, useRef } from 'react';

export function useSearch(searchUsers: (query: string) => void) {
  const [searchQuery, setSearchQuery] = useState('');
  const [userSearchQuery, setUserSearchQuery] = useState('');
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Memoized search function to prevent unnecessary re-renders
  const debouncedSearch = useCallback((query: string) => {
    if (query.trim()) {
      searchUsers(query);
    }
  }, [searchUsers]);

  // Debounced search with proper cleanup
  useEffect(() => {
    // Clear any existing timeout
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    // Set new timeout
    timeoutRef.current = setTimeout(() => {
      debouncedSearch(userSearchQuery);
    }, 300);

    // Cleanup function
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, [userSearchQuery, debouncedSearch]);

  // Memoized setter functions
  const handleSetSearchQuery = useCallback((query: string) => {
    setSearchQuery(query);
  }, []);

  const handleSetUserSearchQuery = useCallback((query: string) => {
    setUserSearchQuery(query);
  }, []);

  return {
    searchQuery,
    setSearchQuery: handleSetSearchQuery,
    userSearchQuery,
    setUserSearchQuery: handleSetUserSearchQuery,
  };
} 