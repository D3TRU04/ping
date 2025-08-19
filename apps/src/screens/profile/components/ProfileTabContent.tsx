import React from 'react';
import { View, Animated } from 'react-native';
import ProfileEmptyState from './ProfileEmptyState';
import AppText from '../../../components/AppText';

export type TabType = 'Saved' | 'Been' | 'Likes';

export default function ProfileTabContent({
  activeTab,
  currentUser,
  scrollY,
  isOwnProfile = false,
}: {
  activeTab: TabType;
  currentUser: any;
  scrollY: Animated.Value;
  isOwnProfile?: boolean;
}) {
  switch (activeTab) {
    case 'Saved':
      if (!currentUser.saved || currentUser.saved.length === 0) {
        return isOwnProfile ? (
          <ProfileEmptyState
            icon="🔖"
            title="Your saved places will show up here!"
            subtitle="Tap the save icon on a place to add it to your collection."
          />
        ) : (
          <ProfileEmptyState
            icon="🔖"
            title="No saved places"
            subtitle="This user hasn't saved any places yet."
          />
        );
      }
      return (
        <Animated.ScrollView
          scrollEventThrottle={16}
          onScroll={Animated.event(
            [{ nativeEvent: { contentOffset: { y: scrollY } } }],
            { useNativeDriver: true }
          )}
          className="p-4"
        >
          <View className="flex-row justify-between">
            <Animated.View
              style={{
                transform: [
                  {
                    translateY: scrollY.interpolate({
                      inputRange: [0, 100],
                      outputRange: [200, -50],
                      extrapolate: 'clamp',
                    }),
                  },
                ],
              }}
              className="w-1/2 pr-2"
            >
              {currentUser.saved.map((item: string, idx: number) =>
                idx % 2 === 0 ? (
                  <View
                    key={idx}
                    className="mb-4 h-40 bg-[#FF5C5C]/10 rounded-lg justify-center items-center"
                  >
                    <AppText>{item}</AppText>
                  </View>
                ) : null
              )}
            </Animated.View>
            <Animated.View
              style={{
                transform: [
                  {
                    translateY: scrollY.interpolate({
                      inputRange: [0, 300],
                      outputRange: [-10, 0],
                      extrapolate: 'clamp',
                    }),
                  },
                ],
              }}
              className="w-1/2 pl-3"
            >
              {currentUser.saved.map((item: string, idx: number) =>
                idx % 2 !== 0 ? (
                  <View
                    key={idx}
                    className="mb-4 h-40 bg-[#FF5C5C]/10 rounded-lg justify-center items-center"
                  >
                    <AppText>{item}</AppText>
                  </View>
                ) : null
              )}
            </Animated.View>
          </View>
        </Animated.ScrollView>
      );
    case 'Been':
      if (!currentUser.been || currentUser.been.length === 0) {
        return isOwnProfile ? (
          <ProfileEmptyState
            icon="📍"
            title="Places you've been will show up here!"
            subtitle="Mark places as visited to keep track of your adventures."
          />
        ) : (
          <ProfileEmptyState
            icon="📍"
            title="No been places"
            subtitle="This user hasn't marked any places as visited yet."
          />
        );
      }
      return (
        <View className="p-4">
          {currentUser.been.map((item: string, index: number) => (
            <AppText key={index} className="text-base mb-2 text-gray-800">
              {item}
            </AppText>
          ))}
        </View>
      );
    case 'Likes':
      if (!currentUser.likes || currentUser.likes.length === 0) {
        return isOwnProfile ? (
          <ProfileEmptyState
            icon="❤️"
            title="Liked places will show up here!"
            subtitle="Tap the heart on a place to add it to your likes."
          />
        ) : (
          <ProfileEmptyState
            icon="❤️"
            title="No likes"
            subtitle="This user hasn't liked any places yet."
          />
        );
      }
      return (
        <View className="p-4">
          {currentUser.likes.map((item: string, index: number) => (
            <AppText key={index} className="text-base mb-2 text-gray-800">
              {item}
            </AppText>
          ))}
        </View>
      );
    default:
      return null;
  }
} 