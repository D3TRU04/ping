import React from 'react';
import { View, Image } from 'react-native';
import AppText from '../../../components/AppText';
import { styled } from 'nativewind';

const StyledImage = styled(Image);

export default function ProfileCard({
  profilePicture,
  fullName,
  pronouns,
  username,
  creationDate,
  bio,
  location,
  links,
  children,
}: {
  profilePicture: any;
  fullName: string;
  pronouns?: string;
  username: string;
  creationDate?: string;
  bio?: string;
  location?: string;
  links?: string;
  children?: React.ReactNode;
}) {
  return (
    <View className="mb-2 p-2 bg-white shadow-lg items-center rounded-2xl w-full" style={{ minWidth: 320 }}>
      {/* Profile Picture */}
      <View className="items-center justify-center mb-3 border-4 border-[#E0E7EF] rounded-full shadow-md bg-white" style={{ width: 90, height: 90, borderRadius: 45 }}>
        <StyledImage
          source={profilePicture}
          className="w-20 h-20 rounded-full"
        />
      </View>
      {/* Name and Pronouns */}
      <View className="flex-row items-center justify-center mb-1">
        <AppText className="text-2xl font-bold text-gray-900">
          {fullName}
        </AppText>
        {pronouns ? (
          <AppText className="text-base text-gray-500 ml-2">
            ({pronouns})
          </AppText>
        ) : null}
      </View>
      {/* Username */}
      <AppText className="text-sm text-mint font-semibold mb-1">
        @{username || ' '}
      </AppText>
      {/* Member since */}
      {creationDate && (
        <AppText className="text-sm text-gray-400 mb-2">
          Member since {creationDate}
        </AppText>
      )}
      {/* Bio */}
      {bio && (
        <AppText className="text-sm text-gray-700 text-center mb-2 px-2">
          {bio}
        </AppText>
      )}
      {/* Location and Links Row */}
      <View className="flex-row items-center justify-center space-x-2 mb-2">
        {location && (
          <View className="flex-row items-center space-x-1">
            <AppText className="text-gray-400 text-xs">📍</AppText>
            <AppText className="text-gray-500 text-xs">{location}</AppText>
          </View>
        )}
        {links && (
          <View className="flex-row items-center space-x-1">
            <AppText className="text-gray-400 text-xs">🔗</AppText>
            <AppText className="text-blue-700 underline text-xs">{links}</AppText>
          </View>
        )}
      </View>
      {children}
    </View>
  );
} 