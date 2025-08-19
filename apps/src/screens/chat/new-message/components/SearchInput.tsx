import React, { useCallback, memo } from 'react';
import { View, TouchableOpacity, TextInput } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);

interface SearchInputProps {
  searchQuery: string;
  setSearchQuery?: (query: string) => void;
  onSearch?: () => void;
}

const SearchInput = memo(({ 
  searchQuery, 
  setSearchQuery, 
  onSearch 
}: SearchInputProps) => {
  const handleClearSearch = useCallback(() => {
    setSearchQuery?.('');
  }, [setSearchQuery]);

  const handleSubmitEditing = useCallback(() => {
    onSearch?.();
  }, [onSearch]);

  return (
    <StyledView className="px-4 py-2 bg-white border-b border-gray-100">
      <StyledView className="flex-row items-center bg-gray-50 rounded-xl px-4 py-5 border border-gray-200">
        <Icon name="search" size={20} color="#6B7280" />
        <StyledTextInput
          className="flex-1 ml-3 text-base text-gray-900"
          placeholder="To: Search"
          placeholderTextColor="#9CA3AF"
          value={searchQuery}
          onChangeText={setSearchQuery}
          onSubmitEditing={handleSubmitEditing}
          returnKeyType="search"
          autoCorrect={false}
          autoCapitalize="none"
          spellCheck={false}
          blurOnSubmit={false}
        />
        {searchQuery.length > 0 && (
          <StyledTouchableOpacity
            onPress={handleClearSearch}
            className="ml-2 p-1"
          >
            <Icon name="close" size={18} color="#6B7280" />
          </StyledTouchableOpacity>
        )}
      </StyledView>
    </StyledView>
  );
});

SearchInput.displayName = 'SearchInput';

export default SearchInput; 