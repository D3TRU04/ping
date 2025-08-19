import { useState, useEffect } from 'react';

interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

export function useUserFiltering(
  searchQuery: string,
  suggestedUsers: User[],
  allUsers: User[]
) {
  const [filteredUsers, setFilteredUsers] = useState<User[]>([]);

  // Filter users based on search query and ensure uniqueness
  useEffect(() => {
    if (!searchQuery.trim()) {
      // Remove duplicates from allUsers
      const uniqueUsers = allUsers.filter((user, index, self) => 
        index === self.findIndex(u => u.id === user.id)
      );
      setFilteredUsers(uniqueUsers);
    } else {
      const filtered = allUsers.filter(user =>
        user.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        user.username?.toLowerCase().includes(searchQuery.toLowerCase())
      );
      // Remove duplicates from filtered results
      const uniqueFiltered = filtered.filter((user, index, self) => 
        index === self.findIndex(u => u.id === user.id)
      );
      setFilteredUsers(uniqueFiltered);
    }
  }, [searchQuery, allUsers]);

  // Get unique suggested users
  const uniqueSuggestedUsers = suggestedUsers.filter((user, index, self) => 
    index === self.findIndex(u => u.id === user.id)
  );

  return {
    filteredUsers,
    uniqueSuggestedUsers,
  };
} 