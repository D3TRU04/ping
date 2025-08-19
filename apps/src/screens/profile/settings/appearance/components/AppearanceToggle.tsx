import React from 'react';
import { View, Switch } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../../components/AppText';

const StyledView = styled(View);

interface AppearanceToggleProps {
  icon: string;
  label: string;
  subtitle: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
  isLast?: boolean;
}

export default function AppearanceToggle({ 
  icon, 
  label, 
  subtitle, 
  value, 
  onValueChange, 
  isLast = false 
}: AppearanceToggleProps) {
  return (
    <StyledView className={`flex-row items-center justify-between px-4 py-3 ${!isLast ? 'border-b border-gray-100' : ''}`}>
      <StyledView className="flex-row items-center">
        <StyledView className="w-8 h-8 bg-[#1FC9C3]/10 rounded-lg items-center justify-center mr-3">
          <Icon name={icon as any} size={18} color="#1FC9C3" />
        </StyledView>
        <StyledView className="flex-1">
          <AppText className="text-base text-gray-900">{label}</AppText>
          <AppText className="text-sm text-gray-500">{subtitle}</AppText>
        </StyledView>
      </StyledView>
      <Switch
        value={value}
        onValueChange={onValueChange}
        trackColor={{ false: '#E5E7EB', true: '#1FC9C3' }}
        thumbColor={value ? '#FFFFFF' : '#FFFFFF'}
      />
    </StyledView>
  );
} 