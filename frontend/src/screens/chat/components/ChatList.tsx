import React, { memo } from 'react';
import { View, FlatList, RefreshControl } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import ChatItem from './ChatItem';
import { COLORS } from '../../../theme/colors';
import AppText from '../../../components/AppText';

const StyledView = styled(View);

// Memoized ChatItem renderer to prevent unnecessary re-renders
const MemoizedChatItem = memo(({ 
  item, 
  onPress, 
  isSelectionMode, 
  isSelected, 
  onSelect 
}: { 
  item: any; 
  onPress: (chat: any) => void;
  isSelectionMode?: boolean;
  isSelected?: boolean;
  onSelect?: (chat: any) => void;
}) => (
  <ChatItem 
    item={item} 
    onPress={onPress} 
    isSelectionMode={isSelectionMode}
    isSelected={isSelected}
    onSelect={onSelect}
  />
));

MemoizedChatItem.displayName = 'MemoizedChatItem';

interface ChatListProps {
  data: any[];
  onChatPress: (chat: any) => void;
  isSelectionMode: boolean;
  selectedChats: Set<string>;
  onChatSelect: (chat: any) => void;
  refreshing: boolean;
  onRefresh: () => void;
}

export default function ChatList({
  data,
  onChatPress,
  isSelectionMode,
  selectedChats,
  onChatSelect,
  refreshing,
  onRefresh,
}: ChatListProps) {
  return (
    <FlatList
      data={data}
      renderItem={({ item }) => (
        <MemoizedChatItem 
          item={item} 
          onPress={onChatPress}
          isSelectionMode={isSelectionMode}
          isSelected={selectedChats.has(item.id)}
          onSelect={onChatSelect}
        />
      )}
      keyExtractor={(item) => item.id}
      contentContainerStyle={{ flexGrow: 1 }}
      ListEmptyComponent={() => (
        <StyledView className="flex-1 justify-center items-center px-8 py-12">
          <StyledView className="w-16 h-16 bg-mint/10 rounded-full items-center justify-center mb-4">
            <Icon name="chat-bubble-outline" size={24} color={COLORS.mint} />
          </StyledView>
          <AppText className="text-lg font-semibold text-gray-900 mb-2 text-center">
            No conversations yet
          </AppText>
          <AppText className="text-gray-600 text-center leading-5 text-sm">
            Start a new chat to begin messaging!
          </AppText>
        </StyledView>
      )}
      refreshControl={
        <RefreshControl
          refreshing={refreshing}
          onRefresh={onRefresh}
          colors={[COLORS.mint]}
          tintColor={COLORS.mint}
        />
      }
      showsVerticalScrollIndicator={false}
      removeClippedSubviews={true}
      maxToRenderPerBatch={10}
      windowSize={10}
    />
  );
} 