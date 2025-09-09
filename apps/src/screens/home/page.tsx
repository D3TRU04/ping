// home/page.tsx
import React, { useState, useEffect } from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import HomeTopNavBar from './components/NavBar';
import BottomNavBar from '../../components/BottomNavBar';
import SecondaryNavBar, { SecondaryNavBarTab } from './components/SecondaryNavBar';
import ForYouPage from './for-you/page';
import TodayPage from './today/page';
import GroupFeedPage from './components/GroupFeedPage';
import { useUserAuth } from '../chat/hooks/useUserAuth';
import notificationsService from '../notifications/services/notificationsService';
import TestFollowNotification from '../testing/TestFollowNotification';

const StyledView = styled(View);

export default function HomeScreen({ route }: any) {
  // Use useUserAuth to properly initialize user session
  const { currentUser } = useUserAuth(route?.params?.currentUser);
  const [activeTab, setActiveTab] = useState<SecondaryNavBarTab>('forYou');
  const [showCreateModalOnMount, setShowCreateModalOnMount] = useState(false);
  const [selectedGroup, setSelectedGroup] = useState<any>(null);
  const [showGroupFeed, setShowGroupFeed] = useState(false);
  const [showTestScreen, setShowTestScreen] = useState(false);

  // Load notifications in background when component mounts
  useEffect(() => {
    if (currentUser?.id) {
      console.log('Loading notifications in background for user:', currentUser.id);
      
      notificationsService.loadNotificationsInBackground(currentUser.id)
        .then(({ notifications, counts }) => {
          console.log(`Loaded ${notifications.length} notifications for user`);
          console.log(`Notification counts:`, counts);
        })
        .catch(error => {
          console.error('Error loading notifications in background:', error);
        });
    }
  }, [currentUser?.id]);

  const handleTabChange = (tab: SecondaryNavBarTab) => {
    setActiveTab(tab);
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
    
    // Show test screen if enabled
    if (showTestScreen) {
      return (
        <TestFollowNotification />
      );
    }
    
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
    
    // Keep components mounted and use visibility - this prevents state loss
    const showForYou = activeTab === 'forYou' || activeTab === 'groups';
    const showToday = activeTab === 'today';
    
    return (
      <StyledView className="flex-1">
        {/* ForYou Page - always mounted, visibility controlled */}
        <StyledView 
          style={{ 
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            display: showForYou ? 'flex' : 'none',
            zIndex: showForYou ? 1 : 0
          }}
        >
          <ForYouPage currentUser={currentUser} activeTab={activeTab} />
        </StyledView>
        
        {/* Today Page - always mounted, visibility controlled */}
        <StyledView 
          style={{ 
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            display: showToday ? 'flex' : 'none',
            zIndex: showToday ? 1 : 0
          }}
        >
          <TodayPage currentUser={currentUser} />
        </StyledView>
      </StyledView>
    );
  };

  return (
    <StyledView 
      className="flex-1 bg-[#FAF6F2]"
      onLongPress={() => setShowTestScreen(!showTestScreen)}
    >
      <HomeTopNavBar currentUser={currentUser} />
      <SecondaryNavBar 
        activeTab={activeTab} 
        onTabChange={handleTabChange} 
        currentUser={currentUser}
        onGroupSelect={handleGroupSelect}
      />
      {renderActiveTab()}
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
