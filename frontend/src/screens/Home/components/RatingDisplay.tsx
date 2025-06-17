import React from 'react';
import { View, Text } from 'react-native';
import { styled } from 'nativewind';

const StyledView = styled(View);
const StyledText = styled(Text);

type Props = {
  rating?: number;
  priceRange?: number;
};

export default function RatingDisplay({ rating, priceRange }: Props) {
  return (
    <StyledView className="flex-row justify-center gap-2 mb-1">
      {/* Rating Pill */}
      <StyledView className="flex-row items-center px-2 py-0.5 bg-yellow-100 rounded-full">
        <StyledText className="text-xs font-bold text-yellow-600">
          ⭐ {rating ? rating.toFixed(1) : 'N/A'}
        </StyledText>
      </StyledView>

      {/* Price Pill */}
      {priceRange ? (
        <StyledView className="flex-row items-center px-2 py-0.5 bg-gray-100 rounded-full">
          <StyledText className="text-xs text-gray-700">
            {'💲'.repeat(priceRange)}
          </StyledText>
        </StyledView>
      ) : null}
    </StyledView>
  );
}
