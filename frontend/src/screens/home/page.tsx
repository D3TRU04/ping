import React, { useState } from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import TopNavBar from '../../components/navbar/Home';
import BottomNavBar from '../../components/navbar/BottomNavBar';
import SecondaryNavBar, { SecondaryNavBarTab } from '../../components/navbar/SecondaryNavBar';
import ForYouPage from './for-you/page';
import MatchmakingPage from './matchmaking/page';

const StyledView = styled(View);

export default function HomeScreen({ route }: any) {
  const currentUser = route?.params?.currentUser;
  const [activeTab, setActiveTab] = useState<SecondaryNavBarTab>('forYou');

  const renderActiveTab = () => {
    switch (activeTab) {
      case 'forYou':
        return <ForYouPage currentUser={currentUser} />;
      // case 'matchmaking':
      //   return <MatchmakingPage currentUser={currentUser} />;
      default:
        return <ForYouPage currentUser={currentUser} />;
    }
  };

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <TopNavBar currentUser={currentUser} />
      <SecondaryNavBar activeTab={activeTab} onTabChange={setActiveTab} />
      {renderActiveTab()}
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
