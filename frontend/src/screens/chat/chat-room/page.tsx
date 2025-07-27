import React from 'react';
import { View, FlatList, KeyboardAvoidingView, Platform, ActivityIndicator, SafeAreaView, StatusBar } from 'react-native';
import { styled } from 'nativewind';
import { useNavigation, useRoute } from '@react-navigation/native';
import { COLORS } from '../../../theme/colors';
import AppText from '../../../components/AppText';
import MessageBubble from './components/MessageBubble';
import ChatHeader from './components/ChatHeader';
import MessageInput from './components/MessageInput';
import EmptyState from './components/EmptyState';
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

  return (
    <SafeAreaView className="flex-1" style={{ backgroundColor: '#FAF6F2' }}>
      <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />
      
      <KeyboardAvoidingView
        className="flex-1"
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 90 : 0}
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
            data={allMessages}
            renderItem={({ item, index }) => (
              <MessageBubble
                message={item}
                index={index}
                currentUser={currentUser}
                otherUser={otherUser}
                allMessages={allMessages}
              />
            )}
            keyExtractor={(item) => item.id}
            contentContainerStyle={{ 
              paddingVertical: 16,
              flexGrow: 1,
            }}
            showsVerticalScrollIndicator={false}
            ListEmptyComponent={() => <EmptyState otherUserName={otherUser.name} />}
            onContentSizeChange={() => {
              if (allMessages.length > 0) {
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
  );
} 