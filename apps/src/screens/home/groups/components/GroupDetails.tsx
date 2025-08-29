import React, { useState, useEffect } from 'react';
import { View, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { supabase } from '../../../../../lib/supabase';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';
import AddMembersModal from './AddMembersModal';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface GroupMember {
  id: string;
  user_id: string;
  role: string;
  joined_at: string;
  user: {
    username: string;
    full_name: string;
    profile_picture: string | null;
  };
}

interface Group {
  id: string;
  name: string;
  description: string | null;
  creator_id: string;
  created_at: string;
  updated_at: string;
  is_public: boolean;
  max_members: number;
  category: string | null;
  image_url: string | null;
  member_count: number;
  is_active: boolean;
  creator?: {
    username: string;
    full_name: string;
    profile_picture: string | null;
  };
}

export default function GroupDetails() {
  const navigation = useNavigation();
  const route = useRoute<any>();
  const { currentUser, group } = route.params;
  
  const [groupMembers, setGroupMembers] = useState<GroupMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddMembers, setShowAddMembers] = useState(false);
  const [userRole, setUserRole] = useState<string>('member');

  useEffect(() => {
    fetchGroupMembers();
  }, []);

  const fetchGroupMembers = async () => {
    try {
      setLoading(true);
      
      const { data: members, error } = await supabase
        .from('group_members')
        .select(`
          *,
          user:user_id(username, full_name, profile_picture)
        `)
        .eq('group_id', group.id)
        .eq('is_active', true)
        .order('joined_at', { ascending: true });

      if (error) throw error;

      setGroupMembers(members || []);
      
      // Find current user's role
      const currentUserMember = members?.find(m => m.user_id === currentUser.id);
      if (currentUserMember) {
        setUserRole(currentUserMember.role);
      }
    } catch (error) {
      console.error('Error fetching group members:', error);
      Alert.alert('Error', 'Failed to load group members');
    } finally {
      setLoading(false);
    }
  };

  const handleLeaveGroup = async () => {
    Alert.alert(
      'Leave Group',
      `Are you sure you want to leave "${group.name}"?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Leave',
          style: 'destructive',
          onPress: async () => {
            try {
              const { error } = await supabase
                .from('group_members')
                .update({ is_active: false })
                .eq('group_id', group.id)
                .eq('user_id', currentUser.id);

              if (error) throw error;

              // Update member count
              await supabase
                .from('groups')
                .update({ member_count: group.member_count - 1 })
                .eq('id', group.id);

              navigation.goBack();
            } catch (error) {
              Alert.alert('Error', 'Failed to leave group');
            }
          },
        },
      ]
    );
  };

  const handleAddMembers = () => {
    setShowAddMembers(true);
  };

  const onMembersAdded = () => {
    setShowAddMembers(false);
    fetchGroupMembers();
  };

  const getCategoryIcon = (category: string | null) => {
    switch (category) {
      case 'Food & Dining':
        return 'restaurant';
      case 'Fitness & Sports':
        return 'fitness-center';
      case 'Music & Arts':
        return 'music-note';
      case 'Outdoors & Adventure':
        return 'landscape';
      case 'Technology':
        return 'computer';
      case 'Business & Networking':
        return 'business';
      case 'Hobbies & Crafts':
        return 'palette';
      case 'Travel':
        return 'flight';
      case 'Education':
        return 'school';
      case 'Health & Wellness':
        return 'favorite';
      case 'Entertainment':
        return 'movie';
      default:
        return 'group';
    }
  };

  const getCategoryColor = (category: string | null) => {
    switch (category) {
      case 'Food & Dining':
        return '#FF6B6B';
      case 'Fitness & Sports':
        return '#4ECDC4';
      case 'Music & Arts':
        return '#45B7D1';
      case 'Outdoors & Adventure':
        return '#96CEB4';
      case 'Technology':
        return '#FFEAA7';
      case 'Business & Networking':
        return '#DDA0DD';
      case 'Hobbies & Crafts':
        return '#FFB347';
      case 'Travel':
        return '#98D8C8';
      case 'Education':
        return '#F7DC6F';
      case 'Health & Wellness':
        return '#BB8FCE';
      case 'Entertainment':
        return '#F1948A';
      default:
        return COLORS.mint;
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  const isAdmin = userRole === 'admin' || userRole === 'moderator';
  const isCreator = group.creator_id === currentUser.id;

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      {/* Header */}
      <StyledView className="bg-white border-b border-gray-100">
        <StyledView className="flex-row items-center justify-between px-4 py-3">
          <StyledTouchableOpacity onPress={() => navigation.goBack()} className="p-2">
            <Icon name="arrow-back" size={24} color={COLORS.mint} />
          </StyledTouchableOpacity>
          <AppText className="text-lg font-semibold text-gray-900">Group Details</AppText>
          <StyledTouchableOpacity className="p-2">
            <Icon name="more-vert" size={24} color="#666" />
          </StyledTouchableOpacity>
        </StyledView>
      </StyledView>

      <ScrollView className="flex-1">
        {/* Group Info Card */}
        <StyledView className="bg-white mx-4 mt-4 rounded-2xl overflow-hidden shadow-sm">
          {/* Group Header */}
          <StyledView className="p-6">
            <StyledView className="flex-row items-center mb-4">
              <StyledView 
                className="w-16 h-16 rounded-full items-center justify-center mr-4"
                style={{ backgroundColor: getCategoryColor(group.category) }}
              >
                <Icon 
                  name={getCategoryIcon(group.category) as any} 
                  size={32} 
                  color="white" 
                />
              </StyledView>
              
              <StyledView className="flex-1">
                <AppText className="text-2xl font-bold text-gray-900 mb-1">
                  {group.name}
                </AppText>
                <AppText className="text-base text-gray-600">
                  {group.category}
                </AppText>
              </StyledView>
            </StyledView>

            {/* Privacy Badge */}
            <StyledView className={`self-start px-3 py-1 rounded-full mb-4 ${
              group.is_public ? 'bg-green-100' : 'bg-orange-100'
            }`}>
              <AppText className={`text-sm font-medium ${
                group.is_public ? 'text-green-700' : 'text-orange-700'
              }`}>
                {group.is_public ? 'Public Group' : 'Private Group'}
              </AppText>
            </StyledView>

            {/* Description */}
            {group.description && (
              <AppText className="text-gray-700 leading-6 mb-4">
                {group.description}
              </AppText>
            )}

            {/* Stats */}
            <StyledView className="flex-row justify-between">
              <StyledView className="items-center">
                <AppText className="text-2xl font-bold text-gray-900">
                  {group.member_count}
                </AppText>
                <AppText className="text-sm text-gray-600">Members</AppText>
              </StyledView>
              <StyledView className="items-center">
                <AppText className="text-2xl font-bold text-gray-900">
                  {group.max_members}
                </AppText>
                <AppText className="text-sm text-gray-600">Max</AppText>
              </StyledView>
              <StyledView className="items-center">
                <AppText className="text-sm text-gray-600">
                  Created {formatDate(group.created_at)}
                </AppText>
              </StyledView>
            </StyledView>
          </StyledView>
        </StyledView>

        {/* Action Buttons */}
        <StyledView className="mx-4 mt-4 flex-row space-x-3">
          {(isAdmin || isCreator) && (
            <StyledTouchableOpacity
              onPress={handleAddMembers}
              className="flex-1 bg-mint py-3 rounded-xl flex-row items-center justify-center"
            >
              <Icon name="person-add" size={20} color="white" />
              <AppText className="text-white font-medium ml-2">Add Members</AppText>
            </StyledTouchableOpacity>
          )}
          
          <StyledTouchableOpacity
            onPress={handleLeaveGroup}
            className="flex-1 bg-red-500 py-3 rounded-xl flex-row items-center justify-center"
          >
            <Icon name="exit-to-app" size={20} color="white" />
            <AppText className="text-white font-medium ml-2">Leave Group</AppText>
          </StyledTouchableOpacity>
        </StyledView>

        {/* Members List */}
        <StyledView className="mx-4 mt-6">
          <StyledView className="flex-row items-center justify-between mb-4">
            <AppText className="text-lg font-semibold text-gray-900">
              Members ({groupMembers.length})
            </AppText>
          </StyledView>

          {loading ? (
            <StyledView className="items-center py-8">
              <AppText className="text-gray-600">Loading members...</AppText>
            </StyledView>
          ) : (
            <StyledView className="bg-white rounded-2xl overflow-hidden">
              {groupMembers.map((member, index) => (
                <StyledView
                  key={member.id}
                  className={`flex-row items-center p-4 ${
                    index < groupMembers.length - 1 ? 'border-b border-gray-100' : ''
                  }`}
                >
                  <StyledView className="w-10 h-10 rounded-full bg-gray-300 items-center justify-center mr-3">
                    <AppText className="text-sm text-gray-600 font-medium">
                      {member.user.full_name?.charAt(0) || member.user.username?.charAt(0) || '?'}
                    </AppText>
                  </StyledView>
                  
                  <StyledView className="flex-1">
                    <AppText className="text-base font-medium text-gray-900">
                      {member.user.full_name || member.user.username || 'Unknown User'}
                    </AppText>
                    <AppText className="text-sm text-gray-500">
                      {member.role === 'admin' ? 'Admin' : 
                       member.role === 'moderator' ? 'Moderator' : 'Member'}
                    </AppText>
                  </StyledView>

                  {member.user_id === group.creator_id && (
                    <StyledView className="bg-yellow-100 px-2 py-1 rounded-full">
                      <AppText className="text-xs font-medium text-yellow-700">
                        Creator
                      </AppText>
                    </StyledView>
                  )}
                </StyledView>
              ))}
            </StyledView>
          )}
        </StyledView>
      </ScrollView>

      {/* Add Members Modal */}
      <AddMembersModal
        visible={showAddMembers}
        onClose={() => setShowAddMembers(false)}
        onMembersAdded={onMembersAdded}
        groupId={group.id}
        currentUser={currentUser}
        existingMemberIds={groupMembers.map(m => m.user_id)}
      />
    </StyledView>
  );
}
