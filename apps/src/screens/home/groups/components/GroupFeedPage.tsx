// home/groups/components/GroupFeedPage.tsx
import React, { useState, useEffect } from 'react';
import { View, TouchableOpacity, ScrollView, RefreshControl } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface GroupFeedPageProps {
  group: any;
  currentUser: any;
  onBack: () => void;
  hideHeader?: boolean;
}

export default function GroupFeedPage({ group, currentUser, onBack, hideHeader = false }: GroupFeedPageProps) {
  const [refreshing, setRefreshing] = useState(false);
  const [places, setPlaces] = useState<any[]>([]);

  useEffect(() => {
    // Initialize with empty places array for now
    // TODO: Implement actual group places fetching
    setPlaces([]);
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    // TODO: Implement actual refresh logic
    setTimeout(() => {
      setRefreshing(false);
    }, 1000);
  };

  const renderPlaceCard = (place: any) => (
    <StyledView key={place.id} className="bg-white rounded-xl mb-4 shadow-sm border border-gray-100">
      {/* Place Image Placeholder */}
      <StyledView className="w-full h-48 bg-gray-100 items-center justify-center rounded-t-xl">
        <Icon name="place" size={48} color="#9CA3AF" />
        <AppText className="text-gray-500 mt-2 text-sm">Place Image</AppText>
      </StyledView>

      {/* Place Info */}
      <StyledView className="p-4">
        {/* Header */}
        <StyledView className="flex-row items-start justify-between mb-3">
          <StyledView className="flex-1">
            <AppText className="text-lg font-semibold text-gray-900 mb-1">
              {place.name}
            </AppText>
            <AppText className="text-gray-600 text-sm leading-5">
              {place.description}
            </AppText>
          </StyledView>
        </StyledView>

        {/* Footer */}
        <StyledView className="flex-row items-center justify-between">
          <StyledView className="flex-row items-center flex-1">
            <Icon name="location-on" size={16} color="#666" />
            <AppText className="text-gray-600 text-sm ml-1 flex-1">
              {place.address}
            </AppText>
          </StyledView>
          <StyledView className="items-end ml-3">
            <AppText className="text-gray-500 text-sm">{place.hours}</AppText>
            <StyledView className={`px-2 py-1 rounded-full mt-1 ${
              place.isOpen ? 'bg-green-100' : 'bg-red-100'
            }`}>
              <AppText className={`text-xs font-medium ${
                place.isOpen ? 'text-green-700' : 'text-red-700'
              }`}>
                {place.isOpen ? 'Open' : 'Closed'}
              </AppText>
            </StyledView>
          </StyledView>
        </StyledView>
      </StyledView>
    </StyledView>
  );

  return (
    <StyledView className="w-full bg-[#FAF6F2]">
      {/* Header - Only show if not hidden */}
      {!hideHeader && (
        <StyledView className="flex-row items-center justify-between px-4 py-3 bg-white border-b border-gray-100">
          <StyledTouchableOpacity onPress={onBack} className="p-2 -ml-2">
            <Icon name="arrow-back" size={24} color="#666" />
          </StyledTouchableOpacity>
          <StyledView className="flex-1 items-center">
            <AppText className="text-lg font-semibold text-gray-900">
              {group.name}
            </AppText>
            <AppText className="text-sm text-gray-500">
              Group Feed
            </AppText>
          </StyledView>
          <StyledView className="w-10" />
        </StyledView>
      )}

      {/* Content */}
      <ScrollView 
        className="flex-1 px-4 pt-4" 
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        {/* Feed Header */}
        <StyledView className="bg-white rounded-xl p-4 mb-4 border border-gray-100">
          <StyledView className="flex-row items-center mb-3">
            <StyledView className="w-12 h-12 bg-mint rounded-full items-center justify-center mr-3">
              <Icon name="group" size={24} color="white" />
            </StyledView>
            <StyledView className="flex-1">
              <AppText className="text-lg font-semibold text-gray-900">
                {group.name} Feed
              </AppText>
              <AppText className="text-gray-600 text-sm">
                Places recommended for your group
              </AppText>
            </StyledView>
          </StyledView>
          <AppText className="text-gray-700 text-sm leading-5">
            Places that match the preferences of everyone in your group.
          </AppText>
        </StyledView>

        {/* Places Feed */}
        {places.length > 0 ? (
          places.map(renderPlaceCard)
        ) : (
          /* Enhanced Empty State - No places found */
          <StyledView className="flex-1 justify-center items-center py-20 px-8">
            <Icon name="restaurant" size={80} color={COLORS.mint} />
            <AppText className="text-xl text-gray-900 mt-4 text-center font-semibold">
              No places found
            </AppText>
            <AppText className="text-gray-600 text-center mt-2 leading-6">
              We couldn't find any places matching your group's preferences. Try updating your interests in your profile.
            </AppText>
            <StyledTouchableOpacity 
              className="bg-mint px-6 py-3 rounded-2xl mt-6"
              onPress={() => {
                // TODO: Navigate to profile preferences
                console.log('Navigate to profile preferences');
              }}
            >
              <AppText className="text-white font-semibold">Update Preferences</AppText>
            </StyledTouchableOpacity>
          </StyledView>
        )}
      </ScrollView>
    </StyledView>
  );
}
