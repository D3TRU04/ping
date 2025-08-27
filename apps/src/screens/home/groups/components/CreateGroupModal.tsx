import React, { useState } from 'react';
import { View, Modal, TouchableOpacity, TextInput, ScrollView, Alert } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../components/AppText';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);

interface CreateGroupModalProps {
  visible: boolean;
  onClose: () => void;
  onGroupCreated: () => void;
  currentUser: any;
}

const GROUP_CATEGORIES = [
  'Food & Dining',
  'Fitness & Sports',
  'Music & Arts',
  'Outdoors & Adventure',
  'Technology',
  'Business & Networking',
  'Hobbies & Crafts',
  'Travel',
  'Education',
  'Health & Wellness',
  'Entertainment',
  'Other'
];

export default function CreateGroupModal({ 
  visible, 
  onClose, 
  onGroupCreated, 
  currentUser 
}: CreateGroupModalProps) {
  const [groupName, setGroupName] = useState('');
  const [description, setDescription] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [isPublic, setIsPublic] = useState(true);
  const [maxMembers, setMaxMembers] = useState('50');
  const [creating, setCreating] = useState(false);

  const handleCreateGroup = async () => {
    if (!groupName.trim()) {
      Alert.alert('Error', 'Please enter a group name');
      return;
    }

    if (!selectedCategory) {
      Alert.alert('Error', 'Please select a category');
      return;
    }

    try {
      setCreating(true);

      // For now, just show success without database operations
      Alert.alert(
        'Success!', 
        `Group "${groupName}" created successfully!\n\nNote: Database tables need to be set up first.`,
        [
          {
            text: 'OK',
            onPress: () => {
              // Reset form
              setGroupName('');
              setDescription('');
              setSelectedCategory('');
              setIsPublic(true);
              setMaxMembers('50');
              onGroupCreated();
            }
          }
        ]
      );

    } catch (error) {
      Alert.alert('Error', 'Failed to create group');
    } finally {
      setCreating(false);
    }
  };

  const handleClose = () => {
    if (!creating) {
      setGroupName('');
      setDescription('');
      setSelectedCategory('');
      setIsPublic(true);
      setMaxMembers('50');
      onClose();
    }
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      presentationStyle="pageSheet"
      onRequestClose={handleClose}
    >
      <StyledView className="flex-1 bg-[#FAF6F2]">
        {/* Header */}
        <StyledView className="flex-row items-center justify-between px-4 py-3 bg-white border-b border-gray-100">
          <StyledTouchableOpacity onPress={handleClose} className="p-2">
            <Icon name="close" size={24} color="#666" />
          </StyledTouchableOpacity>
          <AppText className="text-lg font-semibold text-gray-900">Create New Group</AppText>
          <StyledTouchableOpacity
            onPress={handleCreateGroup}
            disabled={creating || !groupName.trim() || !selectedCategory}
            className={`px-4 py-2 rounded-lg ${
              creating || !groupName.trim() || !selectedCategory
                ? 'bg-gray-300'
                : 'bg-mint'
            }`}
          >
            <AppText className={`font-medium ${
              creating || !groupName.trim() || !selectedCategory
                ? 'text-gray-500'
                : 'text-white'
            }`}>
              {creating ? 'Creating...' : 'Create'}
            </AppText>
          </StyledTouchableOpacity>
        </StyledView>

        {/* Form */}
        <ScrollView className="flex-1 px-4 py-6">
          {/* Group Name */}
          <StyledView className="mb-6">
            <AppText className="text-gray-700 font-medium mb-2">Group Name *</AppText>
            <StyledTextInput
              value={groupName}
              onChangeText={setGroupName}
              placeholder="Enter group name"
              className="bg-white border border-gray-200 rounded-lg px-4 py-3 text-gray-900"
              maxLength={100}
            />
          </StyledView>

          {/* Description */}
          <StyledView className="mb-6">
            <AppText className="text-gray-700 font-medium mb-2">Description</AppText>
            <StyledTextInput
              value={description}
              onChangeText={setDescription}
              placeholder="What is this group about?"
              className="bg-white border border-gray-200 rounded-lg px-4 py-3 text-gray-900"
              multiline
              numberOfLines={3}
              maxLength={500}
            />
          </StyledView>

          {/* Category */}
          <StyledView className="mb-6">
            <AppText className="text-gray-700 font-medium mb-2">Category *</AppText>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row">
              {GROUP_CATEGORIES.map((category) => (
                <StyledTouchableOpacity
                  key={category}
                  onPress={() => setSelectedCategory(category)}
                  className={`mr-3 px-4 py-2 rounded-full border ${
                    selectedCategory === category
                      ? 'bg-mint border-mint'
                      : 'bg-white border-gray-200'
                  }`}
                >
                  <AppText
                    className={`font-medium ${
                      selectedCategory === category ? 'text-white' : 'text-gray-700'
                    }`}
                  >
                    {category}
                  </AppText>
                </StyledTouchableOpacity>
              ))}
            </ScrollView>
          </StyledView>

          {/* Privacy Setting */}
          <StyledView className="mb-6">
            <AppText className="text-gray-700 font-medium mb-2">Privacy</AppText>
            <StyledView className="flex-row items-center bg-white border border-gray-200 rounded-lg px-4 py-3">
              <StyledTouchableOpacity
                onPress={() => setIsPublic(true)}
                className="flex-row items-center flex-1"
              >
                <View className={`w-5 h-5 rounded-full border-2 mr-3 ${
                  isPublic ? 'border-mint bg-mint' : 'border-gray-300'
                }`}>
                  {isPublic && <View className="w-2 h-2 rounded-full bg-white m-0.5" />}
                </View>
                <AppText className="text-gray-900">Public - Anyone can find and join</AppText>
              </StyledTouchableOpacity>
            </StyledView>
            <StyledView className="flex-row items-center bg-white border border-gray-200 rounded-lg px-4 py-3 mt-2">
              <StyledTouchableOpacity
                onPress={() => setIsPublic(false)}
                className="flex-row items-center flex-1"
              >
                <View className={`w-5 h-5 rounded-full border-2 mr-3 ${
                  !isPublic ? 'border-mint bg-mint' : 'border-gray-300'
                }`}>
                  {!isPublic && <View className="w-2 h-2 rounded-full bg-white m-0.5" />}
                </View>
                <AppText className="text-gray-900">Private - Invite only</AppText>
              </StyledTouchableOpacity>
            </StyledView>
          </StyledView>

          {/* Max Members */}
          <StyledView className="mb-6">
            <AppText className="text-gray-700 font-medium mb-2">Maximum Members</AppText>
            <StyledTextInput
              value={maxMembers}
              onChangeText={setMaxMembers}
              placeholder="50"
              className="bg-white border border-gray-200 rounded-lg px-4 py-3 text-gray-900"
              keyboardType="numeric"
              maxLength={3}
            />
            <AppText className="text-gray-500 text-sm mt-1">
              Set a limit for how many people can join your group
            </AppText>
          </StyledView>
        </ScrollView>
      </StyledView>
    </Modal>
  );
}
