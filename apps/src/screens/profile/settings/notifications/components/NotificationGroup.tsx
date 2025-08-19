import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../../components/AppText';
import NotificationToggle from './NotificationToggle';

const StyledView = styled(View);

interface NotificationItem {
  icon: string;
  label: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
}

interface NotificationGroupProps {
  title: string;
  items: NotificationItem[];
}

export default function NotificationGroup({ title, items }: NotificationGroupProps) {
  return (
    <StyledView className="mb-6">
      <StyledView className="mb-3 px-2">
        <AppText className="text-sm font-medium text-gray-600">{title}</AppText>
      </StyledView>
      
      <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden">
        {items.map((item, index) => (
          <NotificationToggle
            key={index}
            icon={item.icon}
            label={item.label}
            value={item.value}
            onValueChange={item.onValueChange}
            isLast={index === items.length - 1}
          />
        ))}
      </StyledView>
    </StyledView>
  );
} 