import React from 'react';
import { View, FlatList, ActivityIndicator, RefreshControl, Dimensions, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { COLORS } from '../../../theme/colors';
import { Animated as RNAnimated } from 'react-native';

const StyledView = styled(View);
// Use StyledTouchableOpacity only for className-only cases
const StyledTouchableOpacity = styled(TouchableOpacity);

interface BottomSheetProps {
  sheetTop: any;
  panResponder: any;
  showFilters: boolean;
  setShowFilters: (show: boolean) => void;
  filters: any[];
  clearFilters: () => void;
  renderFilterChip: any;
  loading: boolean;
  activeTab: string;
  followingUsers: any[];
  renderFollowingUser: any;
  filteredPlaces: any[];
  renderPlaceCard: any;
  refreshing: boolean;
  onRefresh: () => void;
  renderEmptyState: any;
}

export default function BottomSheet({
  sheetTop,
  panResponder,
  showFilters,
  setShowFilters,
  filters,
  clearFilters,
  renderFilterChip,
  loading,
  activeTab,
  followingUsers,
  renderFollowingUser,
  filteredPlaces,
  renderPlaceCard,
  refreshing,
  onRefresh,
  renderEmptyState,
}: BottomSheetProps) {
  return (
    <RNAnimated.View 
      style={[
        {
          position: 'absolute',
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'white',
          borderTopLeftRadius: 20,
          borderTopRightRadius: 20,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: -4 },
          shadowOpacity: 0.15,
          shadowRadius: 12,
          elevation: 8,
          zIndex: 30,
        },
        { top: sheetTop },
      ]}
    >
      {/* Drag Handle and Header - Only this area is draggable */}
      <StyledView {...panResponder.panHandlers}>
        <StyledView className="w-10 h-1 bg-gray-300 rounded-full self-center mt-2 mb-4" />
        {/* Content Header */}
        <StyledView className="px-4 pb-4">
          <StyledView className="flex-row justify-between items-center mb-4">
            <AppText className="text-xl font-bold text-gray-900">
              Discover Places
            </AppText>
            <TouchableOpacity
              onPress={() => setShowFilters(!showFilters)}
              style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 9999, backgroundColor: showFilters ? '#1FC9C3' : '#F3F4F6' }}
            >
              <Icon 
                name="tune" 
                size={16} 
                color={showFilters ? 'white' : '#6B7280'} 
              />
              <AppText style={{ fontSize: 16, fontWeight: '600', marginLeft: 4, color: showFilters ? 'white' : '#6B7280' }}>Filters</AppText>
            </TouchableOpacity>
          </StyledView>
        </StyledView>
      </StyledView>

      {/* Filters Section */}
      {showFilters && (
        <>
          {/* Overlay to close filter UI when clicking outside */}
          <TouchableOpacity
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.01)', // nearly transparent
              zIndex: 1,
            }}
            activeOpacity={1}
            onPress={() => setShowFilters(false)}
          />
          <StyledView className="px-4 pb-4" style={{ zIndex: 2 }}>
            <StyledView className="bg-gray-50 rounded-2xl p-4 border border-gray-200">
              <StyledView className="flex-row justify-between items-center mb-3">
                <AppText className="text-lg font-semibold text-gray-900">
                  Filter by Category
                </AppText>
                <TouchableOpacity onPress={clearFilters}>
                  <AppText className="text-base font-semibold text-mint">Clear All</AppText>
                </TouchableOpacity>
              </StyledView>
              <FlatList
                data={filters}
                renderItem={renderFilterChip}
                keyExtractor={(item) => item.id}
                horizontal={false}
                numColumns={2}
                showsVerticalScrollIndicator={false}
                contentContainerStyle={{ paddingBottom: 8 }}
              />
            </StyledView>
          </StyledView>
        </>
      )}

      {/* Places List */}
      <StyledView className="flex-1">
        {loading ? (
          <StyledView className="flex-1 justify-center items-center">
            <ActivityIndicator size="large" color={COLORS.mint} />
            <AppText className="text-mint mt-4 text-lg font-semibold">
              Discovering amazing places...
            </AppText>
          </StyledView>
        ) : activeTab === 'following' ? (
          <FlatList
            data={followingUsers}
            renderItem={renderFollowingUser}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={{ paddingBottom: 120, paddingHorizontal: 16 }}
            style={{ flex: 1 }}
          />
        ) : (
          <FlatList
            data={filteredPlaces.slice(0, 10)}
            renderItem={renderPlaceCard}
            keyExtractor={(item) => item.place_id}
            showsVerticalScrollIndicator={false}
            refreshControl={
              <RefreshControl
                refreshing={refreshing}
                onRefresh={onRefresh}
                tintColor={COLORS.mint}
                colors={[COLORS.mint]}
              />
            }
            ListEmptyComponent={renderEmptyState}
            contentContainerStyle={{ paddingBottom: 120, paddingHorizontal: 16 }}
            style={{ flex: 1 }}
          />
        )}
      </StyledView>
    </RNAnimated.View>
  );
} 