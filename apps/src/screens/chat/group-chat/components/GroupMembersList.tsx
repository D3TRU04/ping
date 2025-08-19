import React, { useState } from 'react';
import { View, TouchableOpacity, Image, FlatList, TextInput, Alert } from 'react-native';
import { styled } from 'nativewind';
import { SafeAreaView } from 'react-native-safe-area-context';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';
import { supabase } from '../../../../../lib/supabase';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledSafeAreaView = styled(SafeAreaView);
const StyledTextInput = styled(TextInput);

interface User {
  id: string;
  name: string;
  avatar: string | null;
}

interface GroupChat {
  id: string;
  name: string;
  members: User[];
  created_at: string;
}

interface GroupMembersListProps {
  groupChat: GroupChat;
  onBackPress: () => void;
  onAddMemberPress: () => void;
  onEditGroupNamePress: () => void;
}

const GroupMembersList = ({ 
  groupChat, 
  onBackPress, 
  onAddMemberPress,
  onEditGroupNamePress
}: GroupMembersListProps) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editedName, setEditedName] = useState(groupChat.name);
  const [saving, setSaving] = useState(false);

  const handleEditPress = () => {
    setIsEditing(true);
    setEditedName(groupChat.name);
  };

  const handleSave = async () => {
    if (!editedName.trim()) {
      Alert.alert('Error', 'Group name cannot be empty');
      return;
    }

    if (editedName.trim() === groupChat.name) {
      setIsEditing(false);
      return;
    }

    setSaving(true);
    try {
      const { error } = await supabase
        .from('group_chats')
        .update({ name: editedName.trim() })
        .eq('id', groupChat.id);

      if (error) {
        throw error;
      }

      // Update the local group chat name
      groupChat.name = editedName.trim();
      setIsEditing(false);
      Alert.alert('Success', 'Group name updated successfully');
    } catch (error) {
      Alert.alert('Error', 'Failed to update group name');
      setEditedName(groupChat.name);
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    setIsEditing(false);
    setEditedName(groupChat.name);
  };

  const renderMember = ({ item, index }: { item: User; index: number }) => (
    <StyledView className="flex-row items-center px-4 py-3 border-b border-gray-100">
      {/* Avatar */}
      <StyledView className="w-12 h-12 rounded-full mr-4">
        {item.avatar ? (
          <Image
            source={{ uri: item.avatar }}
            className="w-full h-full rounded-full"
          />
        ) : (
          <StyledView className="w-full h-full rounded-full bg-gray-200 items-center justify-center">
            <AppText className="text-lg text-gray-700 font-semibold">
              {item.name.charAt(0).toUpperCase()}
            </AppText>
          </StyledView>
        )}
      </StyledView>
      
      {/* Member Info */}
      <StyledView className="flex-1">
        <AppText className="text-base font-medium text-gray-900">
          {item.name}
        </AppText>
      </StyledView>
      
      {/* Remove Button (if not the creator) */}
      <StyledTouchableOpacity className="p-2">
        <Icon name="more-vert" size={20} color={COLORS.mint} />
      </StyledTouchableOpacity>
    </StyledView>
  );

  return (
    <StyledSafeAreaView className="flex-1 bg-white" edges={['top']}>
      {/* Header */}
      <StyledView className="flex-row items-center justify-between px-4 py-4 bg-white border-b border-gray-100">
        <StyledTouchableOpacity onPress={onBackPress} className="p-2">
          <Icon name="arrow-back" size={24} color={COLORS.mint} />
        </StyledTouchableOpacity>
        
        <StyledView className="flex-1 items-center">
          {isEditing ? (
            <StyledView className="flex-row items-center">
              <StyledTextInput
                value={editedName}
                onChangeText={setEditedName}
                className="text-lg font-semibold text-gray-900 text-center px-2 py-1 border border-gray-300 rounded"
                autoFocus
                maxLength={50}
              />
              <StyledTouchableOpacity 
                onPress={handleSave} 
                disabled={saving}
                className="ml-2 p-1"
              >
                <Icon name="check" size={20} color={saving ? COLORS.gray : COLORS.mint} />
              </StyledTouchableOpacity>
              <StyledTouchableOpacity 
                onPress={handleCancel} 
                className="ml-1 p-1"
              >
                <Icon name="close" size={20} color={COLORS.gray} />
              </StyledTouchableOpacity>
            </StyledView>
          ) : (
            <AppText className="text-lg font-semibold text-gray-900">
              {groupChat.name}
            </AppText>
          )}
          <AppText className="text-sm text-gray-500">
            {groupChat.members.length} members
          </AppText>
        </StyledView>
        
        {!isEditing && (
          <StyledTouchableOpacity onPress={handleEditPress} className="p-2">
            <Icon name="edit" size={24} color={COLORS.mint} />
          </StyledTouchableOpacity>
        )}
      </StyledView>

      {/* Action Buttons */}
      <StyledView className="flex-row justify-around py-4 border-b border-gray-100">
        <StyledTouchableOpacity className="items-center">
          <StyledView className="w-12 h-12 rounded-full items-center justify-center mb-2">
            <Icon name="person-add" size={24} color={COLORS.mint} />
          </StyledView>
          <AppText className="text-xs text-gray-600 font-medium">Add</AppText>
        </StyledTouchableOpacity>
        
        <StyledTouchableOpacity className="items-center">
          <StyledView className="w-12 h-12 rounded-full items-center justify-center mb-2">
            <Icon name="notifications-off" size={24} color={COLORS.mint} />
          </StyledView>
          <AppText className="text-xs text-gray-600 font-medium">Unmute</AppText>
        </StyledTouchableOpacity>
        
        <StyledTouchableOpacity className="items-center">
          <StyledView className="w-12 h-12 rounded-full items-center justify-center mb-2">
            <Icon name="exit-to-app" size={24} color={COLORS.mint} />
          </StyledView>
          <AppText className="text-xs text-gray-600 font-medium">Leave</AppText>
        </StyledTouchableOpacity>
      </StyledView>

      {/* Members List */}
      <FlatList
        data={groupChat.members}
        renderItem={renderMember}
        keyExtractor={(item) => item.id}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 20 }}
      />
    </StyledSafeAreaView>
  );
};

export default GroupMembersList; 