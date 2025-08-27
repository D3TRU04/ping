import React, { useRef, useState } from 'react';
import {
  View,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

export type SecondaryNavBarTab = 'forYou' | 'today' | 'friends' | 'following' | 'groups';

interface SecondaryNavBarProps {
  activeTab: SecondaryNavBarTab;
  onTabChange: (tab: SecondaryNavBarTab) => void;
}

const MINT = '#1FC9C3';

// Clean SecondaryNavBar with no dropdown logic - just direct tab switching
const SecondaryNavBar: React.FC<SecondaryNavBarProps> = ({ 
  activeTab, 
  onTabChange 
}) => {
  const insets = useSafeAreaInsets();
  const scrollRef = useRef<ScrollView>(null);
  const didScrollRef = useRef(false);

  // Keep the order: Groups, For You
  const tabs = [
    { id: 'groups' as SecondaryNavBarTab, label: 'Groups' },
    { id: 'forYou' as SecondaryNavBarTab, label: 'For You' },
  ];

  // Scroll to the end (rightmost) on first render
  const handleContentSizeChange = (w: number, h: number) => {
    if (!didScrollRef.current && scrollRef.current) {
      scrollRef.current.scrollTo({ x: w, animated: false });
      didScrollRef.current = true;
    }
  };

  // Order tabs manually: Groups, For You
  const orderedTabs = ['groups', 'forYou']
    .map(id => tabs.find(tab => tab.id === id))
    .filter((tab): tab is typeof tabs[0] => Boolean(tab));

  const handleTabPress = (tabId: SecondaryNavBarTab) => {
    console.log('Tab pressed:', tabId);
    onTabChange(tabId);
  };

  let tabNodes: React.ReactNode;
  if (orderedTabs.length === 1) {
    // Only one tab, center it
    tabNodes = (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        {tabs.map((tab) => {
          const isActive = activeTab === tab.id;
          return (
            <TouchableOpacity
              key={tab.id}
              onPress={() => handleTabPress(tab.id)}
              activeOpacity={0.7}
              style={{
                alignItems: 'center',
                justifyContent: 'center',
                paddingVertical: 6,
              }}
            >
              <AppText
                className={`font-semibold`}
                style={{
                  color: isActive ? MINT : '#b3b3b3',
                  fontSize: 18,
                  textAlign: 'center',
                }}
              >
                {tab.label}
              </AppText>
              <View
                style={{
                  marginTop: 6,
                  width: 24,
                  height: 3,
                  backgroundColor: isActive ? MINT : 'transparent',
                  borderRadius: 2,
                }}
              />
            </TouchableOpacity>
          );
        })}
      </View>
    );
  } else {
    // Multiple tabs: Groups first, then For You
    tabNodes = orderedTabs.map((tab) => {
      const isActive = activeTab === tab.id;
      return (
        <TouchableOpacity
          key={tab.id}
          onPress={() => handleTabPress(tab.id)}
          activeOpacity={0.7}
          style={{
            alignItems: 'center',
            justifyContent: 'center',
            paddingVertical: 6,
          }}
        >
          <AppText
            className={`font-semibold`}
            style={{
              color: isActive ? MINT : '#b3b3b3',
              fontSize: 18,
              textAlign: 'center',
            }}
          >
            {tab.label}
          </AppText>
          <View
            style={{
              marginTop: 6,
              width: 24,
              height: 3,
              backgroundColor: isActive ? MINT : 'transparent',
              borderRadius: 2,
            }}
          />
        </TouchableOpacity>
      );
    });
  }

  return (
    <StyledView
      className="w-full items-center px-0 py-2"
      style={{
        backgroundColor: 'transparent',
        borderBottomWidth: 0,
        marginBottom: 2,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <ScrollView
        ref={scrollRef}
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{
          paddingHorizontal: 12,
          gap: 12,
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'center',
          minWidth: '100%',
        }}
        onContentSizeChange={handleContentSizeChange}
        centerContent={true}
      >
        {tabNodes}
      </ScrollView>
    </StyledView>
  );
};

export default SecondaryNavBar; 