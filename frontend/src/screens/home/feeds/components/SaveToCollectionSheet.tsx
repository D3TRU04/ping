// home/feeds/SaveToCollectionSheet.tsx
import React from 'react';
import {
  Modal,
  View,
  TouchableOpacity,
  Pressable,
  Dimensions,
  ScrollView,
} from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../components/AppText';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);

const SCREEN_HEIGHT = Dimensions.get('window').height;

interface SaveToCollectionSheetProps {
  visible: boolean;
  onClose: () => void;
  savedMap: Record<string, string[]>;
}

export default function SaveToCollectionSheet({
  visible,
  onClose,
  savedMap,
}: SaveToCollectionSheetProps) {
  const collections = Object.entries(savedMap); // [['all_saved', ['id1', 'id2']]]

  return (
    <Modal
      animationType="slide"
      transparent
      visible={visible}
      onRequestClose={onClose}
    >
      <Pressable
        className="flex-1 bg-black/30"
        onPress={onClose}
      >
        <View style={{ height: SCREEN_HEIGHT / 2 }} className="mt-auto bg-white rounded-t-2xl p-4">
          {/* Header */}
          <View className="flex-row justify-between items-center mb-2">
            <AppText className="text-base font-semibold">Save to a collection</AppText>
            <TouchableOpacity onPress={onClose}>
              <Icon name="close" size={24} color={COLORS.dislike} />
            </TouchableOpacity>
          </View>

          {/* Divider */}
          <View className="h-px bg-gray-300 mb-3" />

          {/* Create New */}
          <TouchableOpacity
            onPress={() => console.log('Create new collection')}
            className="flex-row justify-between items-center py-2 px-1"
          >
            <AppText className="text-base">Create new collection</AppText>
            <Icon name="chevron-right" size={20} color={COLORS.mint} />
          </TouchableOpacity>

          {/* Collections */}
          <ScrollView className="mt-2">
            {collections.map(([name, items]) => (
              <View key={name} className="py-2 px-1 border-b border-gray-200">
                <AppText className="text-base font-medium capitalize">
                  {name.replace('_', ' ')}
                </AppText>
                <AppText className="text-sm text-gray-600">
                  {items.length} item{items.length === 1 ? '' : 's'}
                </AppText>
              </View>
            ))}
          </ScrollView>
        </View>
      </Pressable>
    </Modal>
  );
}
