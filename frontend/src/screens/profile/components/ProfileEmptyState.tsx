import React from 'react';
import { View } from 'react-native';
import AppText from '../../../components/AppText';

export default function ProfileEmptyState({ icon, title, subtitle }: { icon: string; title: string; subtitle: string }) {
  return (
    <View className="flex-1 items-center mt-10 mb-10">
      <AppText className="text-3xl text-gray-400 mb-2">{icon}</AppText>
      <AppText className="text-xl text-gray-700 text-center font-semibold">{title}</AppText>
      <AppText className="text-base text-gray-400 text-center mt-1">{subtitle}</AppText>
    </View>
  );
} 