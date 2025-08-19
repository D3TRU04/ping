import React from 'react';
import { View, Pressable } from 'react-native';
import { styled } from 'nativewind';
import AppText from '../../../components/AppText';

const StyledView = styled(View);
const StyledPressable = styled(Pressable);

export type TabType = 'Saved' | 'Been' | 'Likes';

export default function ProfileTabs({
  activeTab,
  setActiveTab,
  tabs = ['Saved', 'Been', 'Likes'],
}: {
  activeTab: TabType;
  setActiveTab: (tab: TabType) => void;
  tabs?: TabType[];
}) {
  return (
    <StyledView className="flex-row justify-center items-end w-full mt-4 mb-2">
      {tabs.map((tab) => (
        <StyledPressable
          key={tab}
          onPress={() => setActiveTab(tab)}
          className="px-6 pb-2 mx-1"
          style={({ pressed }) => [
            {
              alignItems: 'center',
              opacity: pressed ? 0.8 : 1,
              transform: [{ scale: pressed ? 0.98 : 1 }],
            },
          ]}
        >
          <AppText
            className={`text-base font-semibold mb-2 ${
              activeTab === tab 
                ? 'text-gray-900' 
                : 'text-gray-500'
            }`}
          >
            {tab}
          </AppText>
          <StyledView className="h-1 w-8 rounded-full overflow-hidden">
            {activeTab === tab ? (
              <StyledView 
                className="h-full w-full bg-gray-900 rounded-full"
                style={{
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 1 },
                  shadowOpacity: 0.1,
                  shadowRadius: 2,
                  elevation: 2,
                }}
              />
            ) : (
              <StyledView className="h-full w-full bg-transparent" />
            )}
          </StyledView>
        </StyledPressable>
      ))}
    </StyledView>
  );
} 