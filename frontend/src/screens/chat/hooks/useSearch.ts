import { useState, useEffect } from 'react';

export function useSearch(searchUsers: (query: string) => void) {
  const [searchQuery, setSearchQuery] = useState('');
  const [userSearchQuery, setUserSearchQuery] = useState('');

  // Debounced search
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      if (userSearchQuery.trim()) {
        searchUsers(userSearchQuery);
      }
    }, 300);

    return () => clearTimeout(timeoutId);
  }, [userSearchQuery, searchUsers]);

  return {
    searchQuery,
    setSearchQuery,
    userSearchQuery,
    setUserSearchQuery,
  };
} 