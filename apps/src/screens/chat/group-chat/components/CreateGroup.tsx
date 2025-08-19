import React, { useState, useCallback, memo } from 'react';
import { View, FlatList, TouchableOpacity, TextInput, Alert, Image } from 'react-native';
import { styled } from 'nativewind';
import { useNavigation, useRoute } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';
import { supabase } from '../../../../../lib/supabase';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);

interface User {
  id: string;
  name: string;
  avatar: string | null;
  full_name?: string;
  username?: string;
}

const CreateGroup = memo(() => {
  const navigation = useNavigation();
  const route = useRoute<any>();
  const { currentUser, selectedUsers = [] } = route.params;
  
  const [groupName, setGroupName] = useState('');
  const [creating, setCreating] = useState(false);

  const handleCreateGroup = useCallback(async () => {
    if (!groupName.trim()) {
      Alert.alert('Error', 'Please enter a group name');
      return;
    }

    if (selectedUsers.length < 1) {
      Alert.alert('Error', 'Please select at least 1 user');
      return;
    }

    setCreating(true);

    try {
      // Create group chat
      const { data: groupChat, error: groupError } = await supabase
        .from('group_chats')
        .insert({
          name: groupName.trim(),
          created_by: currentUser.id,
          created_at: new Date().toISOString(),
        })
        .select()
        .single();

      if (groupError) {
        throw groupError;
      }

      if (!groupChat) {
        throw new Error('Failed to create group chat - no data returned');
      }

      // Add members to group
      const memberIds = [currentUser.id, ...selectedUsers.map(user => user.id)];
      const { error: membersError } = await supabase
        .from('group_members')
        .insert(
          memberIds.map(userId => ({
            group_chat_id: groupChat.id,
            user_id: userId,
            joined_at: new Date().toISOString(),
          }))
        );

      if (membersError) {
        throw membersError;
      }

      // Send system message about group creation
      const { error: messageError } = await supabase.from('messages').insert({
        sender_id: currentUser.id,
        group_chat_id: groupChat.id,
        message: { 
          text: `${currentUser.name || currentUser.full_name || 'Someone'} created group "${groupName.trim()}"`,
          type: 'system'
        },
        created_at: new Date().toISOString(),
        is_read: false,
      });

      if (messageError) {
        throw messageError;
      }

      // Navigate to group chat
      navigation.navigate('GroupChatScreen', {
        currentUser,
        groupChat: {
          id: groupChat.id,
          name: groupChat.name,
          created_by: groupChat.created_by,
          created_at: groupChat.created_at,
          updated_at: groupChat.updated_at,
          members: [currentUser, ...selectedUsers],
        },
      });

    } catch (error) {
      Alert.alert('Error', `Failed to create group: ${error.message || 'Unknown error'}`);
    } finally {
      setCreating(false);
    }
  }, [groupName, selectedUsers, currentUser, navigation]);

  const renderSelectedUser = ({ item }: { item: User }) => {
    const userName = item.name || item.full_name || item.username || 'Unknown User';
    const userInitial = userName.charAt(0).toUpperCase();
    
    return (
      <StyledView className="flex-row items-center justify-between p-3 bg-white border-b border-gray-100">
        <StyledView className="flex-row items-center flex-1">
          <StyledView className="w-10 h-10 rounded-full bg-gray-300 items-center justify-center mr-3">
            {item.avatar ? (
              <Image
                source={{ uri: item.avatar }}
                className="w-full h-full rounded-full"
              />
            ) : (
              <StyledView className="w-full h-full rounded-full bg-gray-300 items-center justify-center">
                <AppText className="text-sm text-gray-600 font-medium">
                  {userInitial}
                </AppText>
              </StyledView>
            )}
          </StyledView>
          <AppText className="text-base text-gray-900 font-medium">
            {userName}
          </AppText>
        </StyledView>
      </StyledView>
    );
  };

  return (
    <SafeAreaView className="flex-1 bg-gray-50">
      <StyledView className="flex-row items-center justify-between px-4 py-3 bg-white border-b border-gray-100">
        <StyledTouchableOpacity onPress={() => navigation.goBack()} className="p-2">
          <Icon name="arrow-back" size={24} color={COLORS.mint} />
        </StyledTouchableOpacity>
        <AppText className="text-lg font-semibold text-gray-900">New Group</AppText>
        <StyledTouchableOpacity
          onPress={handleCreateGroup}
          disabled={creating || !groupName.trim() || selectedUsers.length < 1}
          className={`px-4 py-2 rounded-lg ${
            creating || !groupName.trim() || selectedUsers.length < 1
              ? 'bg-gray-300'
              : 'bg-mint'
          }`}
        >
          <AppText className={`font-medium ${
            creating || !groupName.trim() || selectedUsers.length < 1
              ? 'text-gray-500'
              : 'text-white'
          }`}>
            {creating ? 'Creating...' : 'Create'}
          </AppText>
        </StyledTouchableOpacity>
      </StyledView>

      <StyledView className="p-4">
        <StyledView className="bg-white rounded-lg p-4 mb-4">
          <AppText className="text-sm text-gray-600 mb-2">Group Name</AppText>
          <StyledTextInput
            value={groupName}
            onChangeText={setGroupName}
            placeholder="Enter group name..."
            className="text-base text-gray-900 border-b border-gray-200 pb-2"
            maxLength={50}
          />
        </StyledView>

        <StyledView className="bg-white rounded-lg">
          <StyledView className="p-4 border-b border-gray-100">
            <AppText className="text-lg font-semibold text-gray-900">
              {selectedUsers.length} members selected
            </AppText>
          </StyledView>
          
          <FlatList
            data={selectedUsers}
            renderItem={renderSelectedUser}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
          />
        </StyledView>
      </StyledView>
    </SafeAreaView>
  );
});

CreateGroup.displayName = 'CreateGroup';

export default CreateGroup; 