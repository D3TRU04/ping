import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../components/AppText';

const StyledView = styled(View);

interface DateSeparatorProps {
  date: string;
}

export default function DateSeparator({ date }: DateSeparatorProps) {
  // Format date with smart display using the actual date prop
  const formatDate = (timestamp: string) => {
    const messageDate = new Date(timestamp);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const messageDay = new Date(messageDate.getFullYear(), messageDate.getMonth(), messageDate.getDate());
    
    // Check if message is from today
    if (messageDay.getTime() === today.getTime()) {
      return 'Today';
    }
    
    // Check if message is from yesterday
    if (messageDay.getTime() === yesterday.getTime()) {
      return 'Yesterday';
    }
    
    // Check if message is from this year
    if (messageDate.getFullYear() === now.getFullYear()) {
      return messageDate.toLocaleDateString('en-US', { 
        month: 'long', 
        day: 'numeric' 
      });
    }
    
    // Message is from a different year
    return messageDate.toLocaleDateString('en-US', { 
      month: 'long', 
      day: 'numeric',
      year: 'numeric'
    });
  };

  return (
    <StyledView className="flex-row items-center justify-center my-4">
      <StyledView className="flex-1 h-px bg-gray-300" />
      <StyledView className="px-4 py-1 mx-4">
        <AppText className="text-xs text-gray-500 font-medium">
          {formatDate(date)}
        </AppText>
      </StyledView>
      <StyledView className="flex-1 h-px bg-gray-300" />
    </StyledView>
  );
} 