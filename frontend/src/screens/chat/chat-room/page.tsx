import React from 'react';
import { View, FlatList, KeyboardAvoidingView, Platform, ActivityIndicator, StatusBar } from 'react-native';
import { styled } from 'nativewind';
import { useNavigation, useRoute } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { COLORS } from '../../../theme/colors';
import AppText from '../../../components/AppText';
import MessageBubble from './components/MessageBubble';
import ChatHeader from './components/ChatHeader';
import MessageInput from './components/MessageInput';
import EmptyState from './components/EmptyState';
import DateSeparator from './components/DateSeparator';
import { useMessages } from './hooks/useMessages';
import { useMessageActions } from './hooks/useMessageActions';
import { useScrollToBottom } from './hooks/useScrollToBottom';

const StyledView = styled(View);

interface Message {
  id: string;
  sender_id: string;
  receiver_id: string;
  message: { text: string };
  created_at: string;
  is_read: boolean;
}

interface User {
  id: string;
  name: string;
  avatar: string | null;
}

interface ChatItem {
  type: 'message' | 'date';
  data: Message | string;
}

export default function ChatRoomScreen() {
  const navigation = useNavigation();
  const route = useRoute<any>();
  const { currentUser, otherUser, conversationId } = route.params;

  // Custom hooks
  const {
    messages,
    setMessages,
    loading,
    optimisticMessages,
    setOptimisticMessages,
  } = useMessages(conversationId, currentUser);

  const {
    input,
    setInput,
    sending,
    sendMessage,
  } = useMessageActions(conversationId, currentUser, otherUser, setMessages, setOptimisticMessages);

  const flatListRef = useScrollToBottom(messages, optimisticMessages);

  // Handle profile navigation
  const handleProfilePress = () => {
    // @ts-ignore - Navigation type issue
    navigation.navigate('publicProfileScreen', {
      userId: otherUser.id,
      currentUser: currentUser,
    });
  };

  const allMessages = [...messages, ...optimisticMessages];

  // Process messages to add date separators
  const processMessagesWithDateSeparators = (messages: Message[]): ChatItem[] => {
    // Sort messages by created_at timestamp (oldest first)
    const sortedMessages = [...messages].sort((a, b) => 
      new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
    );

    const items: ChatItem[] = [];
    let lastDate = '';

    sortedMessages.forEach((message) => {
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
    if (item.type === 'date') {
      return <DateSeparator date={item.data as string} />;
    }

    const message = item.data as Message;
    return (
      <MessageBubble
        message={message}
        index={0} // We'll handle this differently since we're mixing items
        currentUser={currentUser}
        otherUser={otherUser}
        allMessages={allMessages}
      />
    );
  };

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />
      
      <SafeAreaView className="flex-1" edges={['top']}>
        <KeyboardAvoidingView
          className="flex-1"
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 0}
        >
          <ChatHeader
            otherUser={otherUser}
            messageCount={allMessages.length}
            onBackPress={() => navigation.goBack()}
            onProfilePress={handleProfilePress}
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
              keyExtractor={(item, index) => 
                item.type === 'date' 
                  ? `date-${item.data}` 
                  : `message-${(item.data as Message).id}`
              }
              contentContainerStyle={{ 
                paddingVertical: 16,
                flexGrow: 1,
                paddingBottom: 100, // Reduced padding for new input design
              }}
              showsVerticalScrollIndicator={false}
              ListEmptyComponent={() => <EmptyState otherUserName={otherUser.name} />}
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