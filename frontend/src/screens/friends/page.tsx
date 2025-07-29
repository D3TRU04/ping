import React from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import SearchUsersScreen from './search/page';

const StyledView = styled(View);

const FriendsPage = () => {
  return (
    <StyledView className="flex-1">
      <SearchUsersScreen />
    </StyledView>
  );
};

export default FriendsPage; 