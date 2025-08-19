import React from 'react';
import { View, Pressable } from 'react-native';
import AppText from '../../../components/AppText';

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
    <View className="flex-row justify-center items-end w-full mt-3 mb-1">
      {tabs.map((tab) => (
        <Pressable
          key={tab}
          onPress={() => setActiveTab(tab)}
          className="px-4 pb-1 mx-1"
          style={{ alignItems: 'center' }}
        >
          <AppText
            className={`text-sm font-semibold ${activeTab === tab ? 'text-[#1FC9C3]' : 'text-gray-500'}`}
          >
            {tab}
          </AppText>
          <View style={{ height: 6, marginTop: 2 }}>
            {activeTab === tab ? (
              <View style={{ height: 2, width: 24, borderRadius: 9999, backgroundColor: '#1FC9C3' }} />
            ) : null}
          </View>
        </Pressable>
      ))}
    </View>
  );
} 