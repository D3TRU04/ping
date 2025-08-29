import React, { useState, useCallback, useRef, useEffect } from 'react';
import { View, TouchableOpacity, TextInput, Switch, Modal, Alert } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { supabase } from '../../../../../lib/supabase';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);

interface CreateGroupModalProps {
  visible: boolean;
  onClose: () => void;
  onGroupCreated: () => void;
  currentUser: any;
}

export default function CreateGroupModal({ 
  visible, 
  onClose, 
  onGroupCreated, 
  currentUser 
}: CreateGroupModalProps) {
  const [groupName, setGroupName] = useState('');
  const [createGroupChat, setCreateGroupChat] = useState(true);
  const [creating, setCreating] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [invitedPeople, setInvitedPeople] = useState<any[]>([]);
  const [searchResults, setSearchResults] = useState<any[]>([]);
  const [searching, setSearching] = useState(false);
  
  // Debounce search to prevent excessive API calls
  const searchTimeoutRef = useRef<NodeJS.Timeout>();

  // Cleanup timeout on unmount
  useEffect(() => {
    return () => {
      if (searchTimeoutRef.current) {
        clearTimeout(searchTimeoutRef.current);
      }
    };
  }, []);

  // Reset state when modal becomes visible
  useEffect(() => {
    if (visible) {
      setGroupName('');
      setCreateGroupChat(true);
      setSearchQuery('');
      setInvitedPeople([]);
      setSearchResults([]);
    }
  }, [visible]);

  const handleClose = () => {
    if (!creating) {
      setGroupName('');
      setCreateGroupChat(true);
      setSearchQuery('');
      setInvitedPeople([]);
      setSearchResults([]);
      onClose();
    }
  };

  const handleSearchPeople = useCallback(async (query: string) => {
    setSearchQuery(query);
    
    // Clear previous timeout
    if (searchTimeoutRef.current) {
      clearTimeout(searchTimeoutRef.current);
    }
    
    // Debounce search to prevent excessive API calls
    searchTimeoutRef.current = setTimeout(async () => {
      if (query.trim().length < 2) {
        setSearchResults([]);
        return;
      }

      setSearching(true);
      try {
        const { data, error } = await supabase
          .from('profiles')
          .select('id, username, full_name')
          .or(`username.ilike.%${query}%, full_name.ilike.%${query}%`)
          .neq('id', currentUser.id)
          .limit(10);

        if (error) {
          console.error('Error searching people:', error);
          setSearchResults([]);
        } else {
          setSearchResults(data || []);
        }
      } catch (error) {
        console.error('Error searching people:', error);
        setSearchResults([]);
      } finally {
        setSearching(false);
      }
    }, 300); // 300ms debounce delay
  }, [currentUser.id]);

  const handleInvitePerson = useCallback((person: any) => {
    if (!invitedPeople.find(p => p.id === person.id)) {
      setInvitedPeople(prev => [...prev, person]);
      setSearchQuery('');
      setSearchResults([]);
    }
  }, [invitedPeople]);

  const handleRemovePerson = useCallback((personId: string) => {
    setInvitedPeople(prev => prev.filter(p => p.id !== personId));
  }, []);

  const handleCreateGroup = async () => {
    if (!groupName.trim()) {
      Alert.alert('Error', 'Please enter a group name');
      return;
    }

    try {
      setCreating(true);

      // Create the group first
      const { data: group, error: groupError } = await supabase
        .from('groups')
        .insert({
          name: groupName.trim(),
          description: null,
          category: 'Other',
          is_public: true,
          max_members: 50,
          creator_id: currentUser.id,
          member_count: 1, // Start with just creator
          is_active: true,
        })
        .select()
        .single();

      if (groupError) {
        console.error('Error creating group:', groupError);
        throw new Error(`Failed to create group: ${groupError.message}`);
      }

      // Add creator as first member
      const { error: memberError } = await supabase
        .from('group_members')
        .insert({
          group_id: group.id,
          user_id: currentUser.id,
          role: 'admin',
          joined_at: new Date().toISOString(),
          is_active: true,
        });

      if (memberError) {
        console.error('Error adding creator as member:', memberError);
        throw new Error(`Failed to add creator as member: ${memberError.message}`);
      }

      // Add invited people as members
      if (invitedPeople.length > 0) {
        const memberInserts = invitedPeople.map(person => ({
          group_id: group.id,
          user_id: person.id,
          role: 'member',
          joined_at: new Date().toISOString(),
          is_active: true,
        }));

        const { error: membersError } = await supabase
          .from('group_members')
          .insert(memberInserts);

        if (membersError) {
          console.error('Error adding invited members:', membersError);
          throw new Error(`Failed to add invited members: ${membersError.message}`);
        }
      }

      // If group chat is requested, call the database function to create it
      if (createGroupChat) {
        try {
          const { data: groupChatId, error: chatError } = await supabase
            .rpc('create_group_chat_for_group', {
              p_group_id: group.id,
              p_creator_id: currentUser.id
            });

          if (chatError) {
            console.error('Error creating group chat:', chatError);
            // Don't fail the entire operation, just log the error
          } else {
            console.log('Group chat created with ID:', groupChatId);
          }
        } catch (chatError) {
          console.error('Error calling group chat function:', chatError);
          // Don't fail the entire operation
        }
      }

      Alert.alert(
        'Success!', 
        `Group "${groupName}" created successfully with ${1 + invitedPeople.length} member(s)!${
          createGroupChat ? '\n\nA group chat has also been created for easy communication.' : ''
        }`,
        [
          {
            text: 'OK',
            onPress: () => {
              // Reset form
              setGroupName('');
              setCreateGroupChat(true);
              setSearchQuery('');
              setInvitedPeople([]);
              setSearchResults([]);
              onGroupCreated();
            }
          }
        ]
      );

    } catch (error) {
      console.error('Error creating group:', error);
      Alert.alert('Error', `Failed to create group: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setCreating(false);
    }
  };

  return (
    <Modal
      visible={visible}
      animationType="fade"
      transparent={true}
      onRequestClose={handleClose}
    >
      <StyledView className="flex-1 bg-black/50 justify-end items-center">
        <StyledView className="bg-white rounded-t-3xl w-full shadow-2xl border border-gray-100" style={{ minHeight: 420 }}>
          {/* Header */}
          <StyledView className="flex-row items-center justify-between px-5 py-4 border-b border-gray-100">
            <StyledTouchableOpacity onPress={handleClose} className="p-2 -ml-2">
              <Icon name="close" size={22} color="#666" />
            </StyledTouchableOpacity>
            <AppText className="text-lg font-semibold text-gray-900">Create New Group</AppText>
            <StyledTouchableOpacity
              onPress={handleCreateGroup}
              disabled={creating || !groupName.trim()}
              className={`px-4 py-2 rounded-xl ${
                creating || !groupName.trim()
                  ? 'bg-gray-200'
                  : 'bg-mint'
              }`}
            >
              <AppText className={`font-semibold ${
                creating || !groupName.trim()
                  ? 'text-gray-500'
                  : 'text-white'
              }`}>
                {creating ? 'Creating...' : 'Create'}
              </AppText>
            </StyledTouchableOpacity>
          </StyledView>

          {/* Form - Better proportions */}
          <StyledView className="px-5 py-5 pb-8">
            {/* Group Name */}
            <StyledView className="mb-5">
              <AppText className="text-gray-800 font-semibold mb-2.5 text-base">Group Name *</AppText>
              <StyledTextInput
                value={groupName}
                onChangeText={setGroupName}
                placeholder="Enter group name..."
                className="bg-gray-50 border border-gray-200 rounded-xl px-4 py-6 text-gray-900 text-base"
                maxLength={50}
                placeholderTextColor="#9CA3AF"
                style={{ 
                  minHeight: 72,
                  textAlignVertical: 'center',
                  includeFontPadding: false
                }}
              />
            </StyledView>

            {/* Invite People */}
            <StyledView className="mb-5">
              <AppText className="text-gray-800 font-semibold mb-2.5 text-base">Invite People</AppText>
              <StyledTextInput
                value={searchQuery}
                onChangeText={handleSearchPeople}
                placeholder="Search people to invite..."
                className="bg-gray-50 border border-gray-200 rounded-xl px-4 py-6 text-gray-900 text-base"
                placeholderTextColor="#9CA3AF"
                style={{ 
                  minHeight: 72,
                  textAlignVertical: 'center',
                  includeFontPadding: false
                }}
              />
              
              {/* Search Results */}
              {searching && (
                <AppText className="text-gray-500 text-sm mt-2">Searching...</AppText>
              )}
              {searchResults.length > 0 && (
                <StyledView className="mt-3 bg-white border border-gray-200 rounded-xl max-h-32">
                  {searchResults.map((person) => (
                    <StyledTouchableOpacity
                      key={person.id}
                      onPress={() => handleInvitePerson(person)}
                      className="px-4 py-3 border-b border-gray-100 last:border-b-0 flex-row items-center"
                    >
                      <StyledView className="w-8 h-8 bg-mint/20 rounded-full items-center justify-center mr-3">
                        <AppText className="text-mint font-semibold text-sm">
                          {person.full_name?.charAt(0) || person.username?.charAt(0) || '?'}
                        </AppText>
                      </StyledView>
                      <StyledView className="flex-1">
                        <AppText className="text-gray-900 font-medium text-sm">
                          {person.full_name || person.username}
                        </AppText>
                        {person.full_name && (
                          <AppText className="text-gray-500 text-xs">
                            @{person.username}
                          </AppText>
                        )}
                      </StyledView>
                      <Icon name="add" size={20} color="#1FC9C3" />
                    </StyledTouchableOpacity>
                  ))}
                </StyledView>
              )}

              {/* Selected People */}
              {invitedPeople.length > 0 && (
                <StyledView className="mt-3 flex-row flex-wrap gap-2">
                  {invitedPeople.map((person) => (
                    <StyledView key={person.id} className="bg-mint/10 border border-mint/20 rounded-full px-3 py-1.5 flex-row items-center">
                      <AppText className="text-mint font-medium text-sm mr-2">
                        {person.full_name || person.username}
                      </AppText>
                      <StyledTouchableOpacity onPress={() => handleRemovePerson(person.id)}>
                        <Icon name="close" size={16} color="#1FC9C3" />
                      </StyledTouchableOpacity>
                    </StyledView>
                  ))}
                </StyledView>
              )}
            </StyledView>

            {/* Group Chat Option */}
            <StyledView className="mb-2">
              <StyledView className="flex-row items-center justify-between bg-gray-50 rounded-xl p-4">
                <StyledView className="flex-1 mr-4">
                  <AppText className="text-gray-800 font-semibold text-base mb-1">Create Group Chat</AppText>
                  <AppText className="text-gray-600 text-sm leading-5">
                    Automatically create a chat room for group members to communicate
                  </AppText>
                </StyledView>
                <Switch
                  value={createGroupChat}
                  onValueChange={setCreateGroupChat}
                  trackColor={{ false: '#E5E7EB', true: '#1FC9C3' }}
                  thumbColor={createGroupChat ? '#ffffff' : '#ffffff'}
                />
              </StyledView>
            </StyledView>
          </StyledView>
        </StyledView>
      </StyledView>
    </Modal>
  );
}
