// home/feeds/item-card/components/IconButton.tsx
import React from 'react';
import { TouchableOpacity, ViewStyle } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { COLORS } from '../../../../../theme/colors';

const StyledTouchableOpacity = styled(TouchableOpacity);

interface IconButtonProps {
  icon: string;
  onPress: () => void;
  color?: string;
  style?: ViewStyle;
}

export default function IconButton({
  icon,
  onPress,
  color = COLORS.mint,
  style = {},
}: IconButtonProps) {
  return (
    <StyledTouchableOpacity
      onPress={onPress}
      className="w-10 h-10 bg-white/90 rounded-full items-center justify-center"
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
        ...style,
      }}
    >
      <Icon name={icon as any} size={20} color={color} />
    </StyledTouchableOpacity>
  );
}
