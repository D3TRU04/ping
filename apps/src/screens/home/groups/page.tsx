// home/groups/page.tsx
import React, { useState, useEffect } from 'react';
import { View, TouchableOpacity, ScrollView, RefreshControl } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';
import CreateGroupModal from './components/CreateGroupModal';
import { supabase } from '../../../../lib/supabase';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface GroupsPageProps {
  currentUser: any;
  showCreateModalOnMount?: boolean;
  onModalClosed?: () => void;
  onGroupSelect?: (group: any) => void;
}

export default function GroupsPage({ 
  currentUser, 
  showCreateModalOnMount = false, 
  onModalClosed, 
  onGroupSelect 
}: GroupsPageProps) {
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [groups, setGroups] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // Show create modal on mount if requested
  useEffect(() => {
    if (showCreateModalOnMount) {
      setShowCreateModal(true);
    }
  }, [showCreateModalOnMount]);

  // Fetch groups from database
  const fetchGroups = async () => {
    try {
      setLoading(true);
      
      const { data: groupMemberships, error: membershipError } = await supabase
        .from('group_members')
        .select(`
          group_id,
          role,
          joined_at,
          groups (
            id,
            name,
            description,
            category,
            is_public,
            member_count,
            created_at
          )
        `)
        .eq('user_id', currentUser.id)
        .eq('is_active', true);

      if (membershipError) {
        console.error('Error fetching group memberships:', membershipError);
        return;
      }

      const userGroups = groupMemberships?.map(membership => {
        const group = membership.groups;
        if (!group) return null;
        
        return {
          id: group.id,
          name: group.name,
          description: group.description || 'No description available',
          memberCount: group.member_count || 0,
          category: group.category || 'General',
          isPublic: group.is_public || false,
          role: membership.role,
          joinedAt: membership.joined_at,
          createdAt: group.created_at,
        };
      }).filter(Boolean) || [];

      setGroups(userGroups);
    } catch (error) {
      console.error('Error fetching groups:', error);
    } finally {
      setLoading(false);
    }
  };

  // Fetch groups on mount and when currentUser changes
  useEffect(() => {
    if (currentUser?.id) {
      fetchGroups();
    }
  }, [currentUser?.id]);

  // Handle refresh
  const onRefresh = async () => {
    setRefreshing(true);
    await fetchGroups();
    setRefreshing(false);
  };

  const handleCreateGroup = () => {
    setShowCreateModal(true);
  };

  const onGroupCreated = () => {
    setShowCreateModal(false);
    if (onModalClosed) {
      onModalClosed();
    }
    fetchGroups();
  };

  const handleCloseModal = () => {
    setShowCreateModal(false);
    if (onModalClosed) {
      onModalClosed();
    }
  };

  const renderGroupCard = (group: any) => (
    <StyledTouchableOpacity 
      key={group.id} 
      className="bg-white rounded-xl p-4 mb-3 shadow-sm border border-gray-100 active:opacity-80"
      onPress={() => {
        if (onGroupSelect) {
          onGroupSelect(group);
        }
      }}
    >
      <StyledView className="flex-row items-center">
        {/* Group Avatar */}
        <StyledView className="w-14 h-14 bg-mint rounded-full items-center justify-center mr-4">
          <Icon name="group" size={28} color="white" />
        </StyledView>
        
        {/* Group Info */}
        <StyledView className="flex-1">
          <AppText className="text-lg font-semibold text-gray-900 mb-1">
            {group.name}
          </AppText>
          
          <AppText className="text-gray-600 text-sm mb-2">
            {group.description}
          </AppText>
          
          <StyledView className="flex-row items-center">
            <AppText className="text-xs text-gray-500 mr-3">
              {group.memberCount} members
            </AppText>
            {group.role === 'admin' && (
              <StyledView className="bg-mint/10 px-2 py-1 rounded-full">
                <AppText className="text-xs text-mint font-medium">Admin</AppText>
              </StyledView>
            )}
          </StyledView>
        </StyledView>
        
        {/* Arrow */}
        <Icon name="chevron-right" size={24} color="#666" />
      </StyledView>
    </StyledTouchableOpacity>
  );

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      {/* Header */}
      <StyledView className="flex-row items-center justify-between px-4 py-3 bg-white border-b border-gray-100">
        <AppText className="text-xl font-semibold text-gray-900">Groups</AppText>
        <StyledTouchableOpacity
          onPress={handleCreateGroup}
          className="bg-mint px-4 py-2 rounded-lg flex-row items-center"
        >
          <Icon name="add" size={20} color="white" />
          <AppText className="text-white font-medium ml-2">Create Group</AppText>
        </StyledTouchableOpacity>
      </StyledView>

      {/* Content */}
      <ScrollView 
        className="flex-1 px-4" 
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        {loading ? (
          <StyledView className="flex-1 justify-center items-center py-20">
            <AppText className="text-gray-600">Loading your groups...</AppText>
          </StyledView>
        ) : groups.length > 0 ? (
          groups.map(renderGroupCard)
        ) : (
          /* Empty State */
          <StyledView className="flex-1 justify-center items-center py-20">
            <StyledView className="w-20 h-20 bg-mint/10 rounded-full items-center justify-center mb-6">
              <Icon name="group" size={40} color={COLORS.mint} />
            </StyledView>
            <AppText className="text-xl text-gray-900 mb-2 text-center font-semibold">
              No groups yet
            </AppText>
            <AppText className="text-gray-600 text-center mb-6 leading-6 px-8">
              Create your first group to start connecting with people who share your interests.
            </AppText>
            <StyledTouchableOpacity
              onPress={handleCreateGroup}
              className="bg-mint px-8 py-4 rounded-2xl"
            >
              <AppText className="text-white font-semibold text-base">Create Group</AppText>
            </StyledTouchableOpacity>
          </StyledView>
        )}
      </ScrollView>

      {/* Create Group Modal */}
      <CreateGroupModal
        visible={showCreateModal}
        onClose={handleCloseModal}
        onGroupCreated={onGroupCreated}
        currentUser={currentUser}
      />
    </StyledView>
  );
}
