import { useEffect, useCallback } from 'react';

interface UseSearchStateProps {
  searchResults: any[];
  userSearchQuery: string;
  setUserSearchQuery: (query: string) => void;
  searchUsers: (query: string) => void;
  setSearchHookQuery: (query: string) => void;
}

export function useSearchState({
  searchResults,
  userSearchQuery,
  setUserSearchQuery,
  searchUsers,
  setSearchHookQuery,
}: UseSearchStateProps) {
  // Create suggested users list (different from search results)
  const suggestedUsers = searchResults.slice(0, 5); // Only show first 5 as suggestions

  // Sync search states between hooks
  useEffect(() => {
    setSearchHookQuery(userSearchQuery);
  }, [userSearchQuery, setSearchHookQuery]);

  // Memoized search handlers
  const handleUserSearch = useCallback(() => {
    searchUsers(userSearchQuery);
  }, [searchUsers, userSearchQuery]);

  return {
    suggestedUsers,
    handleUserSearch,
  };
} 