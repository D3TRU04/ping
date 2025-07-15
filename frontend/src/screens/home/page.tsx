import React, { useState, useEffect } from 'react';
import { View } from 'react-native';
import { styled } from 'nativewind';
import HomeTopNavBar from '../../components/navbar/HomeTopNavBar';
import BottomNavBar from '../../components/navbar/BottomNavBar';
import SecondaryNavBar, { SecondaryNavBarTab } from '../../components/navbar/SecondaryNavBar';
import ForYouPage from './for-you/page';
import MatchmakingPage from './matchmaking/page';
import FeedView from './feeds/FeedView'; // we'll use this directly instead of TodayFeedPage
import { FoodPlace } from '../../types/FoodPlace';

const StyledView = styled(View);

export default function HomeScreen({ route }: any) {
  const currentUser = route?.params?.currentUser;
  const [activeTab, setActiveTab] = useState<SecondaryNavBarTab>('forYou');

  // Store Today tab feed data
  const [todayFeedItems, setTodayFeedItems] = useState<FoodPlace[] | null>(null);

  // Reset Today feed if user switches away from the tab
  useEffect(() => {
    if (activeTab !== 'today') {
      setTodayFeedItems(null);
    }
  }, [activeTab]);

  const renderActiveTab = () => {
    switch (activeTab) {
      case 'forYou':
        return <ForYouPage currentUser={currentUser} />;
      case 'today':
        return todayFeedItems ? (
          <FeedView
            items={todayFeedItems}
            liked={new Set()}
            savedMap={{}}
            refreshing={false}
            loading={false}
            onRefresh={() => {}}
            erroredImages={new Set()}
            setErroredImages={() => {}}
            setCurrentIndex={() => {}}
            currentUserId={currentUser?.id}
            setLikedPlaces={() => {}}
            setSavedMap={() => {}}
          />
        ) : (
          <MatchmakingPage
            currentUser={currentUser}
            onFinished={(items) => setTodayFeedItems(items)}
          />
        );
      default:
        return null;
    }
  };

  return (
    <StyledView className="flex-1 bg-[#FAF6F2]">
      <HomeTopNavBar currentUser={currentUser} />
      <SecondaryNavBar activeTab={activeTab} onTabChange={setActiveTab} />
      {renderActiveTab()}
      <BottomNavBar currentUser={currentUser} />
    </StyledView>
  );
}
