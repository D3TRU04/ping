import React from 'react';
import { View, TouchableOpacity, Image } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface Group {
  id: string;
  name: string;
  description: string | null;
  creator_id: string;
  created_at: string;
  updated_at: string;
  is_public: boolean;
  max_members: number;
  category: string | null;
  image_url: string | null;
  member_count: number;
  is_active: boolean;
  creator?: {
    username: string;
    full_name: string;
    profile_picture: string | null;
  };
}

interface GroupCardProps {
  group: Group;
  onPress: () => void;
}

export default function GroupCard({ group, onPress }: GroupCardProps) {
  const getCategoryIcon = (category: string | null) => {
    switch (category) {
      case 'Food & Dining':
        return 'restaurant';
      case 'Fitness & Sports':
        return 'fitness-center';
      case 'Music & Arts':
        return 'music-note';
      case 'Outdoors & Adventure':
        return 'landscape';
      case 'Technology':
        return 'computer';
      case 'Business & Networking':
        return 'business';
      case 'Hobbies & Crafts':
        return 'palette';
      case 'Travel':
        return 'flight';
      case 'Education':
        return 'school';
      case 'Health & Wellness':
        return 'favorite';
      case 'Entertainment':
        return 'movie';
      default:
        return 'group';
    }
  };

  const getCategoryColor = (category: string | null) => {
    switch (category) {
      case 'Food & Dining':
        return '#FF6B6B';
      case 'Fitness & Sports':
        return '#4ECDC4';
      case 'Music & Arts':
        return '#45B7D1';
      case 'Outdoors & Adventure':
        return '#96CEB4';
      case 'Technology':
        return '#FFEAA7';
      case 'Business & Networking':
        return '#DDA0DD';
      case 'Hobbies & Crafts':
        return '#FFB347';
      case 'Travel':
        return '#98D8C8';
      case 'Education':
        return '#F7DC6F';
      case 'Health & Wellness':
        return '#BB8FCE';
      case 'Entertainment':
        return '#F1948A';
      default:
        return COLORS.mint;
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - date.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays === 1) return 'Today';
    if (diffDays === 2) return 'Yesterday';
    if (diffDays < 7) return `${diffDays - 1} days`;
    if (diffDays < 30) return `${Math.floor(diffDays / 7)} weeks`;
    if (diffDays < 365) return `${Math.floor(diffDays / 30)} months`;
    return date.toLocaleDateString();
  };

  return (
    <StyledTouchableOpacity
      onPress={onPress}
      className="bg-white rounded-2xl mb-4 overflow-hidden shadow-sm"
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
      }}
    >
      {/* Header */}
      <StyledView className="flex-row items-center justify-between p-4 border-b border-gray-100">
        <StyledView className="flex-row items-center flex-1">
          {/* Group Icon */}
          <StyledView 
            className="w-12 h-12 rounded-full items-center justify-center mr-3"
            style={{ backgroundColor: getCategoryColor(group.category) }}
          >
            <Icon 
              name={getCategoryIcon(group.category) as any} 
              size={24} 
              color="white" 
            />
          </StyledView>
          
          {/* Group Info */}
          <StyledView className="flex-1">
            <AppText className="text-lg font-semibold text-gray-900 mb-1">
              {group.name}
            </AppText>
            <AppText className="text-sm text-gray-500">
              {group.category}
            </AppText>
          </StyledView>
        </StyledView>

        {/* Privacy Badge */}
        <StyledView className={`px-2 py-1 rounded-full ${
          group.is_public ? 'bg-green-100' : 'bg-orange-100'
        }`}>
          <AppText className={`text-xs font-medium ${
            group.is_public ? 'text-green-700' : 'text-orange-700'
          }`}>
            {group.is_public ? 'Public' : 'Private'}
          </AppText>
        </StyledView>
      </StyledView>

      {/* Description */}
      {group.description && (
        <StyledView className="px-4 py-3">
          <AppText className="text-gray-700 leading-5">
            {group.description}
          </AppText>
        </StyledView>
      )}

      {/* Footer */}
      <StyledView className="flex-row items-center justify-between px-4 py-3 bg-gray-50">
        <StyledView className="flex-row items-center">
          <Icon name="people" size={16} color="#666" />
          <AppText className="text-sm text-gray-600 ml-1">
            {group.member_count} / {group.max_members} members
          </AppText>
        </StyledView>
        
        <StyledView className="flex-row items-center">
          <Icon name="schedule" size={16} color="#666" />
          <AppText className="text-sm text-gray-600 ml-1">
            {formatDate(group.created_at)}
          </AppText>
        </StyledView>
      </StyledView>
    </StyledTouchableOpacity>
  );
}
