import React, { useState } from 'react';
import { View, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';
import CreateGroupModal from './components/CreateGroupModal';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

export default function GroupsPage({ currentUser }: { currentUser: any }) {
  const [showCreateModal, setShowCreateModal] = useState(false);

  const handleCreateGroup = () => {
    console.log('Create group button pressed!');
    setShowCreateModal(true);
  };

  const onGroupCreated = () => {
    setShowCreateModal(false);
  };

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      {/* Header */}
      <StyledView className="flex-row items-center justify-between px-4 py-3 bg-white border-b border-gray-100">
        <AppText className="text-xl font-semibold text-gray-900">My Groups</AppText>
        <StyledTouchableOpacity
          onPress={handleCreateGroup}
          className="bg-mint px-4 py-2 rounded-lg flex-row items-center"
        >
          <Icon name="add" size={20} color="white" />
          <AppText className="text-white font-medium ml-2">Create Group</AppText>
        </StyledTouchableOpacity>
      </StyledView>

      {/* Empty State */}
      <StyledView className="flex-1 justify-center items-center py-20">
        <Icon name="group" size={80} color={COLORS.mint} />
        <AppText className="text-xl text-gray-900 mt-4 text-center">
          No groups yet
        </AppText>
        <AppText className="text-gray-600 text-center mt-2 leading-6">
          Create your first group to start connecting with people who share your interests.
        </AppText>
        <StyledTouchableOpacity
          onPress={handleCreateGroup}
          className="bg-mint px-6 py-3 rounded-2xl mt-6"
        >
          <AppText className="text-white font-medium">Create Group</AppText>
        </StyledTouchableOpacity>
      </StyledView>

      {/* Create Group Modal */}
      <CreateGroupModal
        visible={showCreateModal}
        onClose={() => setShowCreateModal(false)}
        onGroupCreated={onGroupCreated}
        currentUser={currentUser}
      />
    </StyledView>
  );
}
