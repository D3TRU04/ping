import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../../components/AppText';
import AppearanceToggle from './AppearanceToggle';

const StyledView = styled(View);

interface AppearanceItem {
  icon: string;
  label: string;
  subtitle: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
}

interface AppearanceGroupProps {
  title: string;
  items: AppearanceItem[];
}

export default function AppearanceGroup({ title, items }: AppearanceGroupProps) {
  return (
    <StyledView className="mb-6">
      <StyledView className="mb-3 px-2">
        <AppText className="text-sm font-medium text-gray-600">{title}</AppText>
      </StyledView>
      
      <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden">
        {items.map((item, index) => (
          <AppearanceToggle
            key={index}
            icon={item.icon}
            label={item.label}
            subtitle={item.subtitle}
            value={item.value}
            onValueChange={item.onValueChange}
            isLast={index === items.length - 1}
          />
        ))}
      </StyledView>
    </StyledView>
  );
} 