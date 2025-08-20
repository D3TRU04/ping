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
    <StyledView className="px-4 pb-1 bg-white border-b border-gray-100">
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
        <StyledView className="flex-row items-center px-4 py-3">
          <Icon name="search" size={20} color="#6B7280" />
          <StyledTextInput
            className="flex-1 ml-3 text-base text-gray-900"
            placeholder="Search for people..."
            placeholderTextColor="#9CA3AF"
            value={searchQuery}
            onChangeText={setSearchQuery}
            onSubmitEditing={handleSubmitEditing}
            returnKeyType="search"
            autoCorrect={false}
            autoCapitalize="none"
            spellCheck={false}
            blurOnSubmit={false}
            style={{
              fontSize: 16,
              textAlignVertical: 'center',
              lineHeight: 20,
            }}
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
    </StyledView>
  );
});

SearchInput.displayName = 'SearchInput';

export default SearchInput; 