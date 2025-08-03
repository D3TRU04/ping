import React from 'react';
import { View, Image, Dimensions, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface Place {
  place_id: string;
  name: string;
  image_url?: string;
  description?: string;
  type_of_food?: string;
  subtopic?: string;
  rating?: number;
  price_range?: number;
  hours: string[];
  address?: string;
  lat?: number;
  lng?: number;
  latitude?: number;
  longitude?: number;
}

interface PlacePopupProps {
  selectedPlace: Place | null;
  isSheetDown: boolean;
  sheetCollapsedTop: number;
  getCategoryColor: (categoryId: string) => string;
  getCategoryFromSubtopic: (subtopic: string) => string;
  COLORS: any;
}

const PlacePopup: React.FC<PlacePopupProps> = ({
  selectedPlace,
  isSheetDown,
  sheetCollapsedTop,
  getCategoryColor,
  getCategoryFromSubtopic,
  COLORS,
}) => {
  if (!selectedPlace || !isSheetDown) return null;
  return (
    <StyledView
      className="absolute left-0 right-0 items-center"
      style={{
        bottom: Dimensions.get('window').height - sheetCollapsedTop - 95,
        zIndex: 10,
      }}
      pointerEvents="none"
    >
      <StyledView className="w-80 bg-white rounded-2xl shadow-lg border border-gray-200 overflow-hidden">
        <StyledTouchableOpacity
          className="absolute top-2 right-2 bg-white border-mint p-2 rounded-full z-20"
          onPress={() => {}}
        >
          <Icon name="favorite-border" size={18} color={COLORS.mint} />
        </StyledTouchableOpacity>
        {/* Image Section */}
        <StyledView className="h-36 bg-gray-100 justify-center items-center relative">
          {selectedPlace.image_url ? (
            <Image
              source={{ uri: selectedPlace.image_url }}
              style={{ width: '100%', height: '100%', resizeMode: 'cover' }}
            />
          ) : (
            <StyledView className="items-center">
              <Icon name="restaurant" size={40} color="#9CA3AF" />
              <AppText className="text-gray-400 mt-2 text-base">No image available</AppText>
            </StyledView>
          )}

          <StyledTouchableOpacity
            className="flex-1 bg-gray-100 py-2 rounded-lg items-center flex-row justify-center"
            onPress={() => {}}
          >
            <Icon name="favorite-border" size={14} color={COLORS.mint} />
            <AppText className="text-mint font-semibold ml-1 text-xs">Save</AppText>
          </StyledTouchableOpacity>
          {/* Category Badge */}
          <StyledView
            className="absolute top-3 left-3 px-2 py-1 rounded-lg"
            style={{ backgroundColor: getCategoryColor(getCategoryFromSubtopic(selectedPlace.subtopic || '')) }}
          >
            <AppText className="text-white text-xs font-bold uppercase">
              {selectedPlace.subtopic || 'Food'}
            </AppText>
          </StyledView>
        </StyledView>
        {/* Content Section */}
        <StyledView className="flex-row w-80 p-3">
          {/* Right: Info and Actions */}
          <StyledView className="flex-1 justify-between">
            {/* Title and Rating Row */}
            <StyledView className="flex-row items-center mb-1">
              <AppText className="font-bold text-base text-gray-900 flex-1 mr-2" numberOfLines={1}>
                {selectedPlace.name}
              </AppText>
              <StyledTouchableOpacity
                className="bg-mint px-2 py-1 rounded-lg items-center flex-row justify-center"
                onPress={() => {}}
              >
                <Icon name="directions" size={12} color="white" />
                <AppText className="text-white font-semibold ml-1 text-xs">Directions</AppText>
              </StyledTouchableOpacity>
            </StyledView>
            {/* Second row: rating and price side by side */}
            <StyledView className="flex-row items-center space-x-2 mb-1">
              <StyledView className="flex-row items-center bg-yellow-100 px-2 py-1 rounded-lg">
                <Icon name="star" size={12} color="#F59E0B" />
                <AppText className="text-yellow-800 text-xs font-semibold ml-1">
                  {selectedPlace.rating?.toFixed(1) || 'N/A'}
                </AppText>
              </StyledView>
              {selectedPlace.price_range && (
                <AppText className="text-green-600 font-bold">
                  {'$'.repeat(selectedPlace.price_range)}
                </AppText>
              )}
            </StyledView>
            {/* Description */}
            <AppText className="text-gray-500 text-xs mb-2" numberOfLines={2}>
              {selectedPlace.description || 'No description available'}
            </AppText>
          </StyledView>
        </StyledView>
      </StyledView>
    </StyledView>
  );
};

export default PlacePopup; 