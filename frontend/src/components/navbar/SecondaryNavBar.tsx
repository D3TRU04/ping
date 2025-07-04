import React, { useRef } from 'react';
import {
  View,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import AppText from '../AppText';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

export type SecondaryNavBarTab = 'forYou' | 'friends' | 'following' | 'groupA' | 'groupB';

interface SecondaryNavBarProps {
  activeTab: SecondaryNavBarTab;
  onTabChange: (tab: SecondaryNavBarTab) => void;
}

const MINT = '#1FC9C3';

const SecondaryNavBar: React.FC<SecondaryNavBarProps> = ({ 
  activeTab, 
  onTabChange 
}) => {
  const insets = useSafeAreaInsets();
  const scrollRef = useRef<ScrollView>(null);
  const didScrollRef = useRef(false);

  // Keep the order: Group B, Group A, Following, Friends, For You
  const tabs = [
    { id: 'groupB' as SecondaryNavBarTab, label: 'Group B' },
    { id: 'groupA' as SecondaryNavBarTab, label: 'Group A' },
    { id: 'following' as SecondaryNavBarTab, label: 'Following' },
    { id: 'friends' as SecondaryNavBarTab, label: 'Friends' },
    { id: 'forYou' as SecondaryNavBarTab, label: 'For You' },
  ];

  // Scroll to the end (rightmost) on first render
  const handleContentSizeChange = (w: number, h: number) => {
    if (!didScrollRef.current && scrollRef.current) {
      scrollRef.current.scrollTo({ x: w, animated: false });
      didScrollRef.current = true;
    }
  };

  return (
    <StyledView
      className="w-full flex-row items-center px-0 py-2"
      style={{
        backgroundColor: 'transparent',
        borderBottomWidth: 0,
        marginBottom: 2,
      }}
    >
      <ScrollView
        ref={scrollRef}
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{
          paddingHorizontal: 12,
          gap: 24,
        }}
        onContentSizeChange={handleContentSizeChange}
      >
        {tabs.map((tab) => {
          const isActive = activeTab === tab.id;
          return (
            <TouchableOpacity
              key={tab.id}
              onPress={() => onTabChange(tab.id)}
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
      </ScrollView>
    </StyledView>
  );
};

export default SecondaryNavBar; 