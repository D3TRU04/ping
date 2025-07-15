// home/feeds/item-card/components/ImageSection.tsx
import React from 'react';
import { View, Image } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../../components/AppText';
import TopActionButtons from './TopActionButtons';
import { COLORS } from '../../../../../theme/colors';
import { categories } from '../../../../auth/onboarding/data/categories';

const StyledView = styled(View);
const StyledImage = styled(Image);

function getDisplayNameFromValue(value: string): string {
  for (const cat of categories) {
    const match = cat.subcategories.find(sub => sub.value === value);
    if (match) return match.name;
  }
  return value;
}

interface ImageSectionProps {
  imageUrl?: string;
  imageFailed: boolean;
  onImageError: () => void;
  subtopic?: string;
  isLiked: boolean;
  isSaved: boolean;
  onLike: () => void;
  onSave: () => void;
  onShare: () => void;
}

export default function ImageSection({
  imageUrl,
  imageFailed,
  onImageError,
  subtopic,
  isLiked,
  isSaved,
  onLike,
  onSave,
  onShare
}: ImageSectionProps) {
  return (
    <StyledView className="relative">
      {imageUrl && !imageFailed ? (
        <StyledImage
          source={{ uri: imageUrl }}
          className="w-full h-80"
          resizeMode="cover"
          onError={onImageError}
        />
      ) : (
        <StyledView className="w-full h-80 bg-gradient-to-br from-gray-200 to-gray-300 justify-center items-center">
          <Icon name="restaurant" size={48} color="#9CA3AF" />
          <AppText className="text-gray-500 mt-2">No image available</AppText>
        </StyledView>
      )}

      {/* Action Buttons */}
      <TopActionButtons
        isLiked={isLiked}
        isSaved={isSaved}
        onLike={onLike}
        onSave={onSave}
        onShare={onShare}
      />

      {/* Category Badge */}
      {subtopic && (
        <StyledView className="absolute top-4 left-4">
          <StyledView className="bg-white/90 px-3 py-1 rounded-full">
            <AppText className="text-sm text-gray-800">
              {getDisplayNameFromValue(subtopic)}
            </AppText>
          </StyledView>
        </StyledView>
      )}
    </StyledView>
  );
}
