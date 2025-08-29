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
import GroupFeedPage from './groups/components/GroupFeedPage';

const StyledView = styled(View);

export default function HomeScreen({ route }: any) {
  const currentUser = route?.params?.currentUser;
  const [activeTab, setActiveTab] = useState<SecondaryNavBarTab>('forYou');
  const [showCreateModalOnMount, setShowCreateModalOnMount] = useState(false);
  const [selectedGroup, setSelectedGroup] = useState<any>(null);
  const [showGroupFeed, setShowGroupFeed] = useState(false);

  const handleTabChange = (tab: SecondaryNavBarTab) => {
    console.log('Tab changed to:', tab);
    setActiveTab(tab);
  };

  const handleCreateGroupRequest = () => {
    setActiveTab('groups');
    setShowCreateModalOnMount(true);
  };

  const handleGroupSelect = (group: any) => {
    setSelectedGroup(group);
    setShowGroupFeed(true);
    setActiveTab('groups'); // Keep Groups tab active
  };

  const handleModalClosed = () => {
    setShowCreateModalOnMount(false);
  };

  const renderActiveTab = () => {
    console.log('Rendering tab:', activeTab);
    
    // If showing group feed, render that instead of the normal tab content
    if (showGroupFeed && selectedGroup) {
      return (
        <GroupFeedPage
          group={selectedGroup}
          currentUser={currentUser}
          onBack={() => {
            setShowGroupFeed(false);
            setSelectedGroup(null);
          }}
          hideHeader={true}
        />
      );
    }
    
    switch (activeTab) {
      case 'forYou':
        return <ForYouPage currentUser={currentUser} activeTab={activeTab} />;
      case 'today':
        return <TodayPage currentUser={currentUser} />;
      case 'groups':
        console.log('Rendering GroupsPage');
        return <GroupsPage 
          currentUser={currentUser} 
          showCreateModalOnMount={showCreateModalOnMount}
          onModalClosed={handleModalClosed}
          onGroupSelect={handleGroupSelect}
        />;
      default:
        console.log('No tab matched, defaulting to ForYou');
        return <ForYouPage currentUser={currentUser} activeTab={activeTab} />;
    }
  };

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <HomeTopNavBar currentUser={currentUser} />
      <SecondaryNavBar 
        activeTab={activeTab} 
        onTabChange={handleTabChange} 
        currentUser={currentUser}
        onCreateGroupRequest={handleCreateGroupRequest}
        onGroupSelect={handleGroupSelect}
      />
      {renderActiveTab()}
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
