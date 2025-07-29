import React from 'react';
import { View, TextInput } from 'react-native';
import { styled } from 'nativewind';

const StyledView = styled(View);
const StyledTextInput = styled(TextInput);

interface SearchBarProps {
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  searchBarTop: number;
}

const SearchBar: React.FC<SearchBarProps> = ({ searchQuery, setSearchQuery, searchBarTop }) => {
  return (
    <StyledView
      style={{
        position: 'absolute',
        top: searchBarTop,
        left: 16,
        right: 16,
        zIndex: 10,
      }}
    >
      <StyledView
        style={{
          backgroundColor: 'white',
          borderRadius: 25,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: 0.1,
          shadowRadius: 8,
          elevation: 4,
          borderWidth: 1,
          borderColor: '#E5E7EB',
        }}
      >
        <StyledTextInput
          className="px-4 py-3 text-gray-900"
          placeholder="Search places, cuisines..."
          placeholderTextColor="#9CA3AF"
          value={searchQuery}
          onChangeText={setSearchQuery}
          style={{
            fontSize: 16,
          }}
        />
      </StyledView>
    </StyledView>
  );
};

export default SearchBar; 