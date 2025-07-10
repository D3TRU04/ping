import React from 'react';
import { View, Pressable } from 'react-native';
import AppText from '../../../components/AppText';

export default function ProfileStats({ following, followers, onPressFollowing, onPressFollowers }: {
  following: number;
  followers: number;
  onPressFollowing?: () => void;
  onPressFollowers?: () => void;
}) {
  return (
    <View className="w-full flex-row items-center justify-center space-x-8 mt-2 mb-1">
      <Pressable className="items-center" onPress={onPressFollowing}>
        <AppText className="text-base font-bold text-gray-900">{following}</AppText>
        <AppText className="text-xs text-gray-500">Following</AppText>
      </Pressable>
      <View className="w-px h-6 bg-gray-200 mx-2" />
      <Pressable className="items-center" onPress={onPressFollowers}>
        <AppText className="text-base font-bold text-gray-900">{followers}</AppText>
        <AppText className="text-xs text-gray-500">Followers</AppText>
      </Pressable>
    </View>
  );
} 