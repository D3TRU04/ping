import React from 'react';
import { View, Pressable } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../../components/AppText';

const StyledView = styled(View);

interface AboutItem {
  icon: string;
  label: string;
  subtitle?: string;
  onPress: () => void;
}

interface AboutSectionProps {
  title: string;
  items: AboutItem[];
}

export default function AboutSection({ title, items }: AboutSectionProps) {
  return (
    <StyledView className="mb-6">
      <StyledView className="mb-3 px-2">
        <AppText className="text-sm font-medium text-gray-600">{title}</AppText>
      </StyledView>
      
      <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden">
        {items.map((item, index) => (
          <Pressable
            key={index}
            onPress={item.onPress}
            className={`flex-row items-center px-4 py-3 ${
              index !== items.length - 1 ? 'border-b border-gray-100' : ''
            }`}
            style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}
          >
            <StyledView className="w-8 h-8 bg-[#1FC9C3]/10 rounded-lg items-center justify-center mr-3">
              <Icon name={item.icon as any} size={18} color="#1FC9C3" />
            </StyledView>
            <StyledView className="flex-1">
              <AppText className="text-base text-gray-900">{item.label}</AppText>
              {item.subtitle && (
                <AppText className="text-sm text-gray-500">{item.subtitle}</AppText>
              )}
            </StyledView>
            <Icon name="open-in-new" size={18} color="#D1D5DB" />
          </Pressable>
        ))}
      </StyledView>
    </StyledView>
  );
} 