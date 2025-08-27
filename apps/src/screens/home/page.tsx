// home/page.tsx
import React, { useState, useEffect } from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import HomeTopNavBar from './components/NavBar';
import BottomNavBar from '../../components/BottomNavBar';
import SecondaryNavBar, { SecondaryNavBarTab } from './components/SecondaryNavBar';
import ForYouPage from './for-you/page';
import TodayPage from './today/page';
import GroupsPage from './groups/page';

const StyledView = styled(View);

export default function HomeScreen({ route }: any) {
  const currentUser = route?.params?.currentUser;
  const [activeTab, setActiveTab] = useState<SecondaryNavBarTab>('forYou');

  const handleTabChange = (tab: SecondaryNavBarTab) => {
    console.log('Tab changed to:', tab);
    setActiveTab(tab);
  };

  const renderActiveTab = () => {
    console.log('Rendering tab:', activeTab);
    switch (activeTab) {
      case 'forYou':
        return <ForYouPage currentUser={currentUser} />;
      case 'today':
        return <TodayPage currentUser={currentUser} />;
      case 'groups':
        console.log('Rendering GroupsPage');
        return <GroupsPage currentUser={currentUser} />;
      default:
        console.log('No tab matched, defaulting to ForYou');
        return <ForYouPage currentUser={currentUser} />;
    }
  };

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <HomeTopNavBar currentUser={currentUser} />
      <SecondaryNavBar activeTab={activeTab} onTabChange={handleTabChange} />
      {renderActiveTab()}
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
