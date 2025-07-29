import React, { useState } from 'react';
import { View, FlatList, KeyboardAvoidingView, Platform, ActivityIndicator, StatusBar, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { useNavigation, useRoute } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { COLORS } from '../../../theme/colors';
import AppText from '../../../components/AppText';
import GroupChatHeader from './components/GroupChatHeader';
import MessageInput from '../chat-room/components/MessageInput';
import EmptyState from '../chat-room/components/EmptyState';
import DateSeparator from '../chat-room/components/DateSeparator';
import GroupMessageBubble from './components/GroupMessageBubble';
import GroupMembersList from './components/GroupMembersList';
import { useGroupMessages } from './hooks/useGroupMessages';
import { useGroupMessageActions } from './hooks/useGroupMessageActions';
import { useScrollToBottom } from '../chat-room/hooks/useScrollToBottom';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface Message {
  id: string;
  sender_id: string;
  message: { text: string };
  created_at: string;
  is_read: boolean;
}

interface User {
  id: string;
  name: string;
  avatar: string | null;
}

interface GroupChat {
  id: string;
  name: string;
  created_by: string;
  created_at: string;
  updated_at: string;
  members: User[];
}

interface ChatItem {
  type: 'message' | 'date' | 'system';
  data: Message | string;
}

export default function GroupChatScreen() {
  const navigation = useNavigation();
  const route = useRoute<any>();
  const { currentUser, groupChat } = route.params;
  const [showMembersList, setShowMembersList] = useState(false);

  // Add null checks for groupChat
  if (!groupChat || !groupChat.id) {
    return (
      <View className="flex-1 bg-gray-50 justify-center items-center">
        <AppText className="text-lg text-gray-600">Error: Group chat not found</AppText>
        <StyledTouchableOpacity
          onPress={() => navigation.goBack()}
          className="mt-4 px-4 py-2 bg-mint rounded-lg"
        >
          <AppText className="text-white">Go Back</AppText>
        </StyledTouchableOpacity>
      </View>
    );
  }

  // Custom hooks
  const {
    messages,
    setMessages,
    loading,
    optimisticMessages,
    setOptimisticMessages,
  } = useGroupMessages(groupChat.id, currentUser);

  const {
    input,
    setInput,
    sending,
    sendMessage,
  } = useGroupMessageActions(groupChat.id, currentUser, setMessages, setOptimisticMessages);

  const flatListRef = useScrollToBottom(messages, optimisticMessages);

  const allMessages = [...messages, ...optimisticMessages];

  // Handlers
  const handleGroupNamePress = () => {
    setShowMembersList(true);
  };

  const handleBackFromMembers = () => {
    setShowMembersList(false);
  };

  const handleAddMember = () => {
    // TODO: Implement add member functionality
  };

  const handleEditGroupName = () => {
    // TODO: Implement edit group name functionality
  };

  // Process messages to add date separators
  const processMessagesWithDateSeparators = (messages: Message[]): ChatItem[] => {
    if (!messages || messages.length === 0) {
      return [];
    }

    const sortedMessages = [...messages].sort((a, b) => 
      new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
    );

    const items: ChatItem[] = [];
    let lastDate = '';

    sortedMessages.forEach((message, index) => {
      if (!message || !message.created_at) {
        return;
      }

      const messageDate = new Date(message.created_at);
      const currentDate = messageDate.toDateString();

      if (currentDate !== lastDate) {
        items.push({
          type: 'date',
          data: message.created_at,
        });
        lastDate = currentDate;
      }

      items.push({
        type: 'message',
        data: message,
      });
    });

    return items;
  };

  const chatItems = processMessagesWithDateSeparators(allMessages);

  const renderItem = ({ item }: { item: ChatItem }) => {
    if (!item || !item.data) {
      return null;
    }

    if (item.type === 'date') {
      return <DateSeparator date={item.data as string} />;
    }

    const message = item.data as Message;
    if (!message || !message.id) {
      return null;
    }

    const sender = groupChat.members?.find(member => member.id === message.sender_id);
    
    return (
      <GroupMessageBubble
        message={message}
        sender={sender}
        isOwnMessage={message.sender_id === currentUser.id}
        allMessages={allMessages}
      />
    );
  };

  // Show members list if active
  if (showMembersList) {
    return (
      <GroupMembersList
        groupChat={groupChat}
        onBackPress={handleBackFromMembers}
        onAddMemberPress={handleAddMember}
        onEditGroupNamePress={handleEditGroupName}
      />
    );
  }

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />
      
      <SafeAreaView className="flex-1" edges={['top']}>
        <KeyboardAvoidingView
          className="flex-1"
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 0}
        >
          <GroupChatHeader
            groupChat={groupChat}
            messageCount={allMessages.length}
            onBackPress={() => navigation.goBack()}
            onEditPress={() => {
              // Navigate to group settings
              navigation.navigate('GroupChatSettings', { groupChat, currentUser });
            }}
            onGroupNamePress={handleGroupNamePress}
          />

          {loading ? (
            <StyledView className="flex-1 justify-center items-center">
              <ActivityIndicator size="large" color={COLORS.mint} />
              <StyledView className="mt-4">
                <AppText className="text-mint text-lg">Loading messages...</AppText>
              </StyledView>
            </StyledView>
          ) : (
            <FlatList
              ref={flatListRef}
              data={chatItems}
              renderItem={renderItem}
              keyExtractor={(item, index) => {
                if (!item || !item.data) {
                  return `empty-${index}`;
                }
                if (item.type === 'date') {
                  return `date-${item.data}-${index}`;
                }
                return `message-${(item.data as Message).id || `temp-${index}`}`;
              }}
              contentContainerStyle={{ 
                paddingVertical: 16,
                flexGrow: 1,
                paddingBottom: 100,
              }}
              showsVerticalScrollIndicator={false}
              ListEmptyComponent={() => <EmptyState groupName={groupChat.name} />}
              onContentSizeChange={() => {
                if (chatItems.length > 0) {
                  flatListRef.current?.scrollToEnd({ animated: false });
                }
              }}
            />
          )}

          <MessageInput
            input={input}
            setInput={setInput}
            sending={sending}
            onSend={sendMessage}
          />
        </KeyboardAvoidingView>
      </SafeAreaView>
    </View>
  );
} 