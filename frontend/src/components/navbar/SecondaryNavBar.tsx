import React, { useRef, useState } from 'react';
import {
  View,
  TouchableOpacity,
  ScrollView,
  Modal,
  TouchableWithoutFeedback,
  Animated,
  Easing,
  findNodeHandle,
  UIManager,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import AppText from '../AppText';
import { MaterialIcons as Icon } from '@expo/vector-icons';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

export type SecondaryNavBarTab = 'forYou' | 'friends' | 'following' | 'groups' | 'groupA' | 'groupB';

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
  const [showGroupsDropdown, setShowGroupsDropdown] = useState(false);
  const [dropdownPos, setDropdownPos] = useState({ x: 0, y: 0, width: 0 });
  const dropdownAnim = useRef(new Animated.Value(0)).current;
  const groupsTabRef = useRef<TouchableOpacity>(null);

  // Keep the order: Groups, Following, Friends, For You
  const tabs = [
    { id: 'groups' as SecondaryNavBarTab, label: 'Groups' },
    { id: 'following' as SecondaryNavBarTab, label: 'Following' },
    { id: 'friends' as SecondaryNavBarTab, label: 'Friends' },
    { id: 'forYou' as SecondaryNavBarTab, label: 'For You' },
  ];

  // Placeholder groups
  const groupOptions = [
    { id: 'groupA' as SecondaryNavBarTab, label: 'Group A' },
    { id: 'groupB' as SecondaryNavBarTab, label: 'Group B' },
  ];

  // Scroll to the end (rightmost) on first render
  const handleContentSizeChange = (w: number, h: number) => {
    if (!didScrollRef.current && scrollRef.current) {
      scrollRef.current.scrollTo({ x: w, animated: false });
      didScrollRef.current = true;
    }
  };

  // Always render For You first, then the rest
  const forYouTab = tabs.find(tab => tab.id === 'forYou');
  const otherTabs = tabs.filter(tab => tab.id !== 'forYou');
  const orderedTabs = [...otherTabs, forYouTab].filter((tab): tab is typeof tabs[0] => Boolean(tab));

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
      </View>
    );
  } else {
    // Multiple tabs: For You first, then others to the left
    let prevTabId: string | null = null;
    tabNodes = orderedTabs.map((tab, idx) => {
      let extraStyle = {};
      if (tab.id === 'following' && prevTabId === 'groups') {
        extraStyle = { marginLeft: 0 };
      }
      prevTabId = tab.id;
      if (tab.id === 'groups') {
        return (
          <View key={tab.id} style={{ position: 'relative', alignItems: 'center' }}>
                <TouchableOpacity
                  ref={groupsTabRef}
                  onPress={() => {
                    if (groupsTabRef.current) {
                      const handle = findNodeHandle(groupsTabRef.current);
                      if (handle) {
                        UIManager.measure(handle, (x, y, width, height, pageX, pageY) => {
                          setDropdownPos({ x: pageX, y: pageY + height, width });
                          setShowGroupsDropdown(true);
                          Animated.timing(dropdownAnim, {
                            toValue: 1,
                            duration: 180,
                            easing: Easing.out(Easing.ease),
                            useNativeDriver: true,
                          }).start();
                        });
                      }
                    }
                  }}
                  activeOpacity={0.7}
                  style={{
                    alignItems: 'center',
                    justifyContent: 'center',
                    paddingVertical: 6,
                    marginRight: 0, // Reduce right margin for tighter spacing to next tab
                  }}
                >
                  <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                    <AppText
                      className={`font-semibold`}
                      style={{
                        color: '#b3b3b3',
                        fontSize: 18,
                        textAlign: 'center',
                      }}
                    >
                      {tab.label}
                    </AppText>
                    <Icon
                      name="keyboard-arrow-down"
                      size={16}
                      color="#b3b3b3"
                      style={{
                        marginLeft: 1,
                        transform: [{ rotate: showGroupsDropdown ? '180deg' : '0deg' }],
                      }}
                    />
                  </View>
                  <View
                    style={{
                      marginTop: 6,
                      width: 24,
                      height: 3,
                      backgroundColor: 'transparent',
                      borderRadius: 2,
                    }}
                  />
                </TouchableOpacity>
                <Modal
                  visible={showGroupsDropdown}
                  transparent
                  animationType="none"
                  onRequestClose={() => setShowGroupsDropdown(false)}
                >
                  <TouchableWithoutFeedback onPress={() => setShowGroupsDropdown(false)}>
                    <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.1)' }}>
                      <Animated.View style={{
                        position: 'absolute',
                        top: dropdownPos.y,
                        left: dropdownPos.x,
                        backgroundColor: 'white',
                        borderRadius: 8,
                        shadowColor: '#000',
                        shadowOffset: { width: 0, height: 2 },
                        shadowOpacity: 0.1,
                        shadowRadius: 4,
                        elevation: 4,
                        zIndex: 1000,
                        minWidth: 140,
                        opacity: dropdownAnim,
                        transform: [{ translateY: dropdownAnim.interpolate({ inputRange: [0, 1], outputRange: [-10, 0] }) }],
                      }}>
                        {groupOptions.map((group) => (
                          <TouchableOpacity
                            key={group.id}
                            onPress={() => {
                              Animated.timing(dropdownAnim, {
                                toValue: 0,
                                duration: 120,
                                useNativeDriver: true,
                              }).start(() => {
                                setShowGroupsDropdown(false);
                                onTabChange(group.id);
                              });
                            }}
                            style={{ padding: 16 }}
                          >
                            <AppText style={{ color: '#333', fontSize: 16 }}>{group.label}</AppText>
                          </TouchableOpacity>
                        ))}
                      </Animated.View>
                    </View>
                  </TouchableWithoutFeedback>
                </Modal>
              </View>
            );
          }
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
            ...extraStyle,
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