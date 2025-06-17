import React from 'react';
import { View, Text, Dimensions } from 'react-native';
import { styled } from 'nativewind';

const screenWidth = Dimensions.get('window').width;

const StyledView = styled(View);
const StyledText = styled(Text);

type Props = {
  rating?: number;
  priceRange?: number;
};

export default function RatingDisplay({ rating, priceRange }: Props) {
  const hasRating = typeof rating === 'number';
  const hasPrice = typeof priceRange === 'number';

  const pillWidth = screenWidth * 0.4;

  if (!hasRating && !hasPrice) return null;

  // ⭐ Both rating and priceRange exist → gap-centered layout
  if (hasRating && hasPrice) {
    return (
      <StyledView className="flex-row justify-center items-center gap-2 mb-1">
        {/* Left: Rating Pill */}
        <StyledView style={{ width: pillWidth }} className="items-end">
          <StyledView className="flex-row items-center px-2 py-0.5 bg-yellow-100 rounded-full self-end">
            <StyledText className="text-xs font-bold text-yellow-600">
              ⭐ {rating.toFixed(1)}
            </StyledText>
          </StyledView>
        </StyledView>

        {/* Right: Price Pill */}
        <StyledView style={{ width: pillWidth }} className="items-start">
          <StyledView className="flex-row items-center px-2 py-0.5 bg-gray-100 rounded-full self-start">
            <StyledText className="text-xs text-gray-700">
              {'💲'.repeat(priceRange)}
            </StyledText>
          </StyledView>
        </StyledView>
      </StyledView>
    );
  }

  // ⭐ Only rating exists → center it
  if (hasRating) {
    return (
      <StyledView className="flex-row justify-center mb-1">
        <StyledView className="flex-row items-center px-2 py-0.5 bg-yellow-100 rounded-full">
          <StyledText className="text-xs font-bold text-yellow-600">
            ⭐ {rating.toFixed(1)}
          </StyledText>
        </StyledView>
      </StyledView>
    );
  }

  // 💲 Only priceRange exists → center it
  return (
    <StyledView className="flex-row justify-center mb-1">
      <StyledView className="flex-row items-center px-2 py-0.5 bg-gray-100 rounded-full">
        <StyledText className="text-xs text-gray-700">
          {'💲'.repeat(priceRange!)}
        </StyledText>
      </StyledView>
    </StyledView>
  );
}
