import React from 'react';
import { View, TextInput } from 'react-native';
import { styled } from 'nativewind';

const StyledView = styled(View);
const StyledTextInput = styled(TextInput);

interface SearchBarProps {
  placeholder: string;
  value: string;
  onChangeText: (text: string) => void;
}

const SearchBar: React.FC<SearchBarProps> = ({ placeholder, value, onChangeText }) => {
  return (
    <StyledView className="bg-white rounded-full border border-gray-200">
      <StyledTextInput
        className="px-4 py-3 text-gray-900 text-xs font-medium"
        placeholder={placeholder}
        placeholderTextColor="#9CA3AF"
        value={value}
        onChangeText={onChangeText}
      />
    </StyledView>
  );
};

export default SearchBar; 