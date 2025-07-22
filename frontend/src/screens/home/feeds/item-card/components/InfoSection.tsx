// home/feeds/item-card/components/InfoSection.tsx
import React from 'react';
import { View, ScrollView } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../../components/AppText';
import { COLORS } from '../../../../../theme/colors';
import HoursDisplay from './HoursDisplay';
import FooterButtons from './FooterButtons';

const StyledView = styled(View);
const StyledScrollView = styled(ScrollView);

interface InfoSectionProps {
  name: string;
  rating?: number;
  priceRange?: number;
  hours: string[];
  description?: string;
  expandedHours: boolean;
  onToggleHours: () => void;
  onDirections: () => void;
  onCall: () => void;
}

function getPriceRangeText(priceRange?: number): string {
  if (!priceRange) return '';
  return '$'.repeat(priceRange);
}

export default function InfoSection({
  name,
  rating,
  priceRange,
  hours,
  description,
  expandedHours,
  onToggleHours,
  onDirections,
  onCall
}: InfoSectionProps) {
  return (
    <StyledView className="flex-1 flex-col px-6 pt-4 min-h-0 overflow-hidden">
      <StyledScrollView
        style={{ flexGrow: 0 }}
        contentContainerStyle={{ paddingBottom: 8 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Title and Rating */}
        <StyledView className="flex-row items-center mb-4">
          <AppText className={`flex-1 mr-2 ${name.length > 28 ? 'text-lg' : 'text-2xl'} text-gray-900`}>
            {name}
          </AppText>
          <StyledView className="flex-row items-center">
            <Icon name="star" size={16} color="#FFD700" />
            <AppText className="text-sm text-gray-700 ml-1">
              {rating?.toFixed(1) || 'N/A'}
            </AppText>
          </StyledView>
        </StyledView>

        {/* Price */}
        {!!priceRange && (
          <StyledView className="mb-4">
            <AppText className="text-sm text-gray-600">{getPriceRangeText(priceRange)}</AppText>
          </StyledView>
        )}

        {/* Hours */}
        {hours.length > 0 && (
          <HoursDisplay
            hours={hours}
            expanded={expandedHours}
            onToggle={onToggleHours}
          />
        )}

        {/* Description */}
        {!!description && (
          <StyledView className="mb-4">
            <AppText className="text-gray-700 leading-5">{description}</AppText>
          </StyledView>
        )}

        {/* Footer buttons */}
        <FooterButtons
          placeName={name}
          onDirections={onDirections}
          onCall={onCall}
        />
      </StyledScrollView>
    </StyledView>
  );
}
