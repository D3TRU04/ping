import React from 'react';
import { View, TextInput } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../../../components/AppText';

const StyledView = styled(View);
const StyledTextInput = styled(TextInput);

interface PersonalInfoProps {
  isEditing: boolean;
  formData: {
    fullName: string;
    username: string;
    email: string;
    phoneNumber: string;
    bio: string;
    location: string;
  };
  onFormDataChange: (field: string, value: string) => void;
}

export default function PersonalInfo({ 
  isEditing, 
  formData, 
  onFormDataChange 
}: PersonalInfoProps) {
  return (
    <StyledView className="mb-6">
      <StyledView className="mb-3 px-2">
        <AppText className="text-sm font-medium text-gray-600">Personal Information</AppText>
      </StyledView>
      
      <StyledView className="bg-white rounded-xl shadow-sm overflow-hidden">
        <StyledView className="px-4 py-3 border-b border-gray-100">
          <AppText className="text-sm text-gray-500 mb-1">Full Name</AppText>
          {isEditing ? (
            <StyledTextInput
              value={formData.fullName}
              onChangeText={(text) => onFormDataChange('fullName', text)}
              className="text-base text-gray-900 py-2"
              placeholder="Enter your full name"
            />
          ) : (
            <AppText className="text-base text-gray-900">{formData.fullName || 'Not set'}</AppText>
          )}
        </StyledView>
        
        <StyledView className="px-4 py-3 border-b border-gray-100">
          <AppText className="text-sm text-gray-500 mb-1">Username</AppText>
          {isEditing ? (
            <StyledTextInput
              value={formData.username}
              onChangeText={(text) => onFormDataChange('username', text)}
              className="text-base text-gray-900 py-2"
              placeholder="Enter username"
            />
          ) : (
            <AppText className="text-base text-gray-900">@{formData.username || 'Not set'}</AppText>
          )}
        </StyledView>
        
        <StyledView className="px-4 py-3 border-b border-gray-100">
          <AppText className="text-sm text-gray-500 mb-1">Email</AppText>
          <AppText className="text-base text-gray-900">{formData.email}</AppText>
          <AppText className="text-xs text-gray-500 mt-1">Email cannot be changed</AppText>
        </StyledView>
        
        <StyledView className="px-4 py-3 border-b border-gray-100">
          <AppText className="text-sm text-gray-500 mb-1">Phone Number</AppText>
          {isEditing ? (
            <StyledTextInput
              value={formData.phoneNumber}
              onChangeText={(text) => onFormDataChange('phoneNumber', text)}
              className="text-base text-gray-900 py-2"
              placeholder="Enter phone number"
              keyboardType="phone-pad"
            />
          ) : (
            <AppText className="text-base text-gray-900">{formData.phoneNumber || 'Not set'}</AppText>
          )}
        </StyledView>
        
        <StyledView className="px-4 py-3 border-b border-gray-100">
          <AppText className="text-sm text-gray-500 mb-1">Bio</AppText>
          {isEditing ? (
            <StyledTextInput
              value={formData.bio}
              onChangeText={(text) => onFormDataChange('bio', text)}
              className="text-base text-gray-900 py-2"
              placeholder="Tell us about yourself"
              multiline
              numberOfLines={3}
            />
          ) : (
            <AppText className="text-base text-gray-900">{formData.bio || 'No bio added'}</AppText>
          )}
        </StyledView>
        
        <StyledView className="px-4 py-3">
          <AppText className="text-sm text-gray-500 mb-1">Location</AppText>
          {isEditing ? (
            <StyledTextInput
              value={formData.location}
              onChangeText={(text) => onFormDataChange('location', text)}
              className="text-base text-gray-900 py-2"
              placeholder="Enter your location"
            />
          ) : (
            <AppText className="text-base text-gray-900">{formData.location || 'Not set'}</AppText>
          )}
        </StyledView>
      </StyledView>
    </StyledView>
  );
} 