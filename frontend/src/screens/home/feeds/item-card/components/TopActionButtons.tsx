// home/feeds/item-card/components/TopActionButtons.tsx
import React from 'react';
import { View, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { COLORS } from '../../../../../theme/colors';
import IconButton from './IconButton';

const StyledView = styled(View);

interface TopActionButtonsProps {
  isLiked: boolean;
  isSaved: boolean;
  onLike: () => void;
  onSave: () => void;
  onShare: () => void;
}

export default function TopActionButtons({
  isLiked,
  isSaved,
  onLike,
  onSave,
  onShare,
}: TopActionButtonsProps) {
  return (
    <StyledView className="absolute top-4 right-4 flex-row">
      <View style={{ marginRight: 4 }}>
        <IconButton icon={isSaved ? 'bookmark' : 'bookmark-border'} onPress={onSave} />
      </View>
      <View style={{ marginRight: 4 }}>
        <IconButton icon="share" onPress={onShare} />
      </View>
      <IconButton
        icon={isLiked ? 'favorite' : 'favorite-border'}
        color={isLiked ? '#FF5C5C' : COLORS.mint}
        onPress={onLike}
      />
    </StyledView>
  );
}
