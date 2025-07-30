import React, { memo } from 'react';
import { View, TouchableOpacity, Image } from 'react-native';
import { styled } from 'nativewind';
import { SafeAreaView } from 'react-native-safe-area-context';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledSafeAreaView = styled(SafeAreaView);

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

interface GroupChatHeaderProps {
  groupChat: GroupChat;
  messageCount: number;
  onBackPress: () => void;
  onEditPress: () => void;
  onGroupNamePress: () => void;
}

const GroupChatHeader = memo(({ 
  groupChat, 
  messageCount, 
  onBackPress, 
  onEditPress,
  onGroupNamePress
}: GroupChatHeaderProps) => {
  // Get first 3 member avatars for display
  const memberAvatars = groupChat.members.slice(0, 3);
  const remainingCount = Math.max(0, groupChat.members.length - 3);

  return (
    <StyledView className="bg-white">
      <StyledView className="flex-row items-center justify-between px-4 py-4 bg-white border-b border-gray-100">
        {/* Back Button */}
        <StyledTouchableOpacity 
          onPress={onBackPress} 
          className="w-9 h-9 rounded-full items-center justify-center mr-3"
        >
          <Icon name="arrow-back" size={18} color={COLORS.mint} />
        </StyledTouchableOpacity>
        
        {/* Group Info */}
        <StyledTouchableOpacity 
          onPress={onEditPress}
          className="flex-row items-center flex-1"
        >
          {/* Member Avatars */}
          <StyledView className="flex-row items-center mr-3">
            {memberAvatars.map((member, index) => (
              <StyledView
                key={member.id}
                className={`w-7 h-7 rounded-full border-2 border-white shadow-sm ${
                  index > 0 ? '-ml-3' : ''
                }`}
                style={{ zIndex: memberAvatars.length - index }}
              >
                {member.avatar ? (
                  <Image
                    source={{ uri: member.avatar }}
                    className="w-full h-full rounded-full"
                  />
                ) : (
                  <StyledView className="w-full h-full rounded-full bg-gray-200 items-center justify-center">
                    <AppText className="text-xs text-gray-700 font-semibold">
                      {member.name.charAt(0).toUpperCase()}
                    </AppText>
                  </StyledView>
                )}
              </StyledView>
            ))}
            {remainingCount > 0 && (
              <StyledView className="w-7 h-7 rounded-full border-2 border-white bg-gray-100 items-center justify-center -ml-3 shadow-sm">
                <AppText className="text-xs text-gray-600 font-medium">
                  +{remainingCount}
                </AppText>
              </StyledView>
            )}
          </StyledView>
          
          {/* Group Details */}
          <StyledTouchableOpacity 
            onPress={onGroupNamePress}
            className="flex-1"
          >
            <AppText className="text-base font-semibold text-gray-900 mb-0.5">
              {groupChat.name}
            </AppText>
            <AppText className="text-xs text-gray-500 font-medium">
              {groupChat.members.length} members
            </AppText>
          </StyledTouchableOpacity>
        </StyledTouchableOpacity>
        
        {/* Edit Button */}
        {/* <StyledTouchableOpacity 
          onPress={onEditPress} 
          className="w-9 h-9 rounded-full items-center justify-center ml-2"
        >
          <Icon name="edit" size={16} color={COLORS.mint} />
        </StyledTouchableOpacity> */}
      </StyledView>
    </StyledView>
  );
});

GroupChatHeader.displayName = 'GroupChatHeader';

export default GroupChatHeader; 