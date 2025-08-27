import React, { useState, useEffect } from 'react';
import { View, Modal, TouchableOpacity, TextInput, FlatList, Alert, ScrollView } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { supabase } from '../../../../../lib/supabase';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);

interface User {
  id: string;
  username: string;
  full_name: string;
  profile_picture: string | null;
}

interface AddMembersModalProps {
  visible: boolean;
  onClose: () => void;
  onMembersAdded: () => void;
  groupId: string;
  currentUser: any;
  existingMemberIds: string[];
}

export default function AddMembersModal({
  visible,
  onClose,
  onMembersAdded,
  groupId,
  currentUser,
  existingMemberIds,
}: AddMembersModalProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<User[]>([]);
  const [selectedUsers, setSelectedUsers] = useState<User[]>([]);
  const [searching, setSearching] = useState(false);
  const [adding, setAdding] = useState(false);

  useEffect(() => {
    if (visible && searchQuery.trim()) {
      searchUsers();
    } else {
      setSearchResults([]);
    }
  }, [searchQuery, visible]);

  const searchUsers = async () => {
    if (!searchQuery.trim()) {
      setSearchResults([]);
      return;
    }

    try {
      setSearching(true);
      
      const { data: users, error } = await supabase
        .from('profiles')
        .select('id, username, full_name, profile_picture')
        .or(`username.ilike.%${searchQuery}%,full_name.ilike.%${searchQuery}%`)
        .neq('id', currentUser.id)
        .not('id', 'in', `(${existingMemberIds.join(',')})`)
        .limit(20);

      if (error) throw error;

      setSearchResults(users || []);
    } catch (error) {
      console.error('Error searching users:', error);
      setSearchResults([]);
    } finally {
      setSearching(false);
    }
  };

  const toggleUserSelection = (user: User) => {
    setSelectedUsers(prev => {
      const isSelected = prev.some(u => u.id === user.id);
      if (isSelected) {
        return prev.filter(u => u.id !== user.id);
      } else {
        return [...prev, user];
      }
    });
  };

  const isUserSelected = (userId: string) => {
    return selectedUsers.some(u => u.id === userId);
  };

  const handleAddMembers = async () => {
    if (selectedUsers.length === 0) {
      Alert.alert('Error', 'Please select at least one user to add');
      return;
    }

    try {
      setAdding(true);

      // Add members to group
      const { error: membersError } = await supabase
        .from('group_members')
        .insert(
          selectedUsers.map(user => ({
            group_id: groupId,
            user_id: user.id,
            role: 'member',
            joined_at: new Date().toISOString(),
          }))
        );

      if (membersError) throw membersError;

      // Update group member count
      const { error: groupError } = await supabase
        .from('groups')
        .update({ member_count: existingMemberIds.length + selectedUsers.length + 1 })
        .eq('id', groupId);

      if (groupError) throw groupError;

      Alert.alert('Success', `Added ${selectedUsers.length} member(s) to the group`);
      
      // Reset and close
      setSelectedUsers([]);
      setSearchQuery('');
      onMembersAdded();

    } catch (error) {
      Alert.alert('Error', `Failed to add members: ${error.message || 'Unknown error'}`);
    } finally {
      setAdding(false);
    }
  };

  const handleClose = () => {
    if (!adding) {
      setSelectedUsers([]);
      setSearchQuery('');
      onClose();
    }
  };

  const renderUser = ({ item }: { item: User }) => {
    const isSelected = isUserSelected(item.id);
    const userName = item.full_name || item.username || 'Unknown User';
    const userInitial = userName.charAt(0).toUpperCase();

    return (
      <StyledTouchableOpacity
        onPress={() => toggleUserSelection(item)}
        className={`flex-row items-center p-4 border-b border-gray-100 ${
          isSelected ? 'bg-mint/10' : 'bg-white'
        }`}
      >
        <StyledView className="w-10 h-10 rounded-full bg-gray-300 items-center justify-center mr-3">
          {item.profile_picture ? (
            <Icon name="person" size={20} color="#666" />
          ) : (
            <AppText className="text-sm text-gray-600 font-medium">
              {userInitial}
            </AppText>
          )}
        </StyledView>
        
        <StyledView className="flex-1">
          <AppText className="text-base font-medium text-gray-900">
            {userName}
          </AppText>
          <AppText className="text-sm text-gray-500">
            @{item.username}
          </AppText>
        </StyledView>

        <StyledView className={`w-6 h-6 rounded-full border-2 items-center justify-center ${
          isSelected ? 'border-mint bg-mint' : 'border-gray-300'
        }`}>
          {isSelected && <Icon name="check" size={16} color="white" />}
        </StyledView>
      </StyledTouchableOpacity>
    );
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      presentationStyle="pageSheet"
      onRequestClose={handleClose}
    >
      <StyledView className="flex-1 bg-[#FAF6F2]">
        {/* Header */}
        <StyledView className="flex-row items-center justify-between px-4 py-3 bg-white border-b border-gray-100">
          <StyledTouchableOpacity onPress={handleClose} className="p-2">
            <Icon name="close" size={24} color="#666" />
          </StyledTouchableOpacity>
          <AppText className="text-lg font-semibold text-gray-900">Add Members</AppText>
          <StyledTouchableOpacity
            onPress={handleAddMembers}
            disabled={adding || selectedUsers.length === 0}
            className={`px-4 py-2 rounded-lg ${
              adding || selectedUsers.length === 0
                ? 'bg-gray-300'
                : 'bg-mint'
            }`}
          >
            <AppText className={`font-medium ${adding || selectedUsers.length === 0 ? 'text-gray-500' : 'text-white'}`}>
              {adding ? 'Adding...' : `Add (${selectedUsers.length})`}
            </AppText>
          </StyledTouchableOpacity>
        </StyledView>

        {/* Search */}
        <StyledView className="p-4 bg-white border-b border-gray-100">
          <StyledView className="relative">
            <StyledTextInput
              value={searchQuery}
              onChangeText={setSearchQuery}
              placeholder="Search users by name or username..."
              className="bg-gray-100 rounded-lg px-4 py-3 pl-10 text-gray-900"
            />
            <Icon 
              name="search" 
              size={20} 
              color="#666" 
              style={{ position: 'absolute', left: 12, top: 12 }}
            />
          </StyledView>
        </StyledView>

        {/* Selected Users */}
        {selectedUsers.length > 0 && (
          <StyledView className="px-4 py-3 bg-mint/10 border-b border-mint/20">
            <AppText className="text-sm font-medium text-mint mb-2">
              Selected Users ({selectedUsers.length})
            </AppText>
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
              {selectedUsers.map((user) => (
                <StyledView
                  key={user.id}
                  className="bg-white rounded-full px-3 py-1 mr-2 flex-row items-center"
                >
                  <AppText className="text-sm text-gray-700 mr-2">
                    {user.full_name || user.username}
                  </AppText>
                  <TouchableOpacity onPress={() => toggleUserSelection(user)}>
                    <Icon name="close" size={16} color="#666" />
                  </TouchableOpacity>
                </StyledView>
              ))}
            </ScrollView>
          </StyledView>
        )}

        {/* Search Results */}
        <FlatList
          data={searchResults}
          renderItem={renderUser}
          keyExtractor={(item) => item.id}
          ListEmptyComponent={
            searchQuery.trim() ? (
              <StyledView className="flex-1 justify-center items-center py-20">
                {searching ? (
                  <AppText className="text-gray-600">Searching...</AppText>
                ) : (
                  <AppText className="text-gray-600">No users found</AppText>
                )}
              </StyledView>
            ) : (
              <StyledView className="flex-1 justify-center items-center py-20">
                <Icon name="search" size={80} color={COLORS.mint} />
                <AppText className="text-xl text-gray-900 mt-4 text-center">
                  Search for users
                </AppText>
                <AppText className="text-gray-600 text-center mt-2 leading-6">
                  Enter a name or username to find people to add to your group.
                </AppText>
              </StyledView>
            )
          }
        />
      </StyledView>
    </Modal>
  );
}
