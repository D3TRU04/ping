import React, { useRef, useState, useEffect } from 'react';
import {
  View,
  TouchableOpacity,
  ScrollView,
  Modal,
  FlatList,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../components/AppText';
import { supabase } from '../../../../lib/supabase';



const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

export type SecondaryNavBarTab = 'forYou' | 'today' | 'friends' | 'following' | 'groups';

interface SecondaryNavBarProps {
  activeTab: SecondaryNavBarTab;
  onTabChange: (tab: SecondaryNavBarTab) => void;
  currentUser?: any;
  onCreateGroupRequest?: () => void;
  onGroupSelect?: (group: any) => void;
}

const MINT = '#1FC9C3';



const SecondaryNavBar: React.FC<SecondaryNavBarProps> = ({ 
  activeTab, 
  onTabChange,
  currentUser,
  onCreateGroupRequest,
  onGroupSelect
}) => {
  const insets = useSafeAreaInsets();
  const scrollRef = useRef<ScrollView>(null);
  const didScrollRef = useRef(false);
  const [showGroupsDropdown, setShowGroupsDropdown] = useState(false);
  const [userGroups, setUserGroups] = useState<any[]>([]);

  const groupsButtonRef = useRef<TouchableOpacity>(null);
  const [dropdownPosition, setDropdownPosition] = useState({ top: 0, left: 0 });

  // Keep the order: Groups (dropdown), For You
  const tabs = [
    { id: 'groups' as SecondaryNavBarTab, label: 'Groups', isDropdown: true },
    { id: 'forYou' as SecondaryNavBarTab, label: 'For You', isDropdown: false },
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
    if (tabId === 'groups') {
      // Calculate dropdown position before showing
      if (groupsButtonRef.current) {
        groupsButtonRef.current.measure((x, y, width, height, pageX, pageY) => {
          setDropdownPosition({
            top: pageY + height + 10, // 10px below the button
            left: pageX + (width / 2) - 100, // Center the dropdown (200px width / 2)
          });
        });
      }
      setShowGroupsDropdown(!showGroupsDropdown);
    } else {
      console.log('Tab pressed:', tabId);
      onTabChange(tabId);
    }
  };

  // Fetch user groups
  const fetchUserGroups = async () => {
    if (!currentUser?.id) return;
    
    try {
      const { data: groupMemberships, error } = await supabase
        .from('group_members')
        .select(`
          group_id,
          groups (
            id,
            name
          )
        `)
        .eq('user_id', currentUser.id)
        .eq('is_active', true);

      if (error) {
        console.error('Error fetching user groups:', error);
        return;
      }

      const groups = groupMemberships
        ?.map(membership => membership.groups)
        .filter(Boolean) || [];
      
      setUserGroups(groups);
    } catch (error) {
      console.error('Error fetching user groups:', error);
    }
  };

  // Fetch groups when dropdown opens
  useEffect(() => {
    if (showGroupsDropdown && currentUser?.id) {
      fetchUserGroups();
    }
  }, [showGroupsDropdown, currentUser?.id]);

  const handleGroupsOptionPress = (optionId: string) => {
    setShowGroupsDropdown(false);
    
    if (optionId === 'createGroup' && onCreateGroupRequest) {
      onCreateGroupRequest();
    }
  };

  const renderGroupsDropdown = () => {
    return (
      <Modal
        visible={showGroupsDropdown}
        transparent={true}
        animationType="none"
        onRequestClose={() => setShowGroupsDropdown(false)}
      >
        <StyledView className="flex-1">
          {/* Position the dropdown using calculated position */}
          <StyledView 
            className="absolute z-50"
            style={{
              top: dropdownPosition.top,
              left: dropdownPosition.left,
            }}
          >
            <StyledView className="bg-white rounded-xl shadow-lg border border-gray-200 w-[240px] max-h-[400px]">
              {/* Create Group Option */}
              <StyledTouchableOpacity
                onPress={() => handleGroupsOptionPress('createGroup')}
                className="flex-row items-center px-4 py-3 border-b border-gray-100"
                activeOpacity={0.7}
              >
                <Icon name="add-circle" size={20} color="#666" />
                <AppText className="text-gray-900 font-medium ml-3">Create Group</AppText>
              </StyledTouchableOpacity>

              {/* User Groups */}
              {userGroups.length > 0 && (
                <>
                  <StyledView className="px-4 py-2 bg-gray-50">
                    <AppText className="text-xs text-gray-500 font-medium">YOUR GROUPS</AppText>
                  </StyledView>
                  {userGroups.map((group, index) => (
                                         <StyledTouchableOpacity
                       key={group.id}
                       onPress={() => {
                         setShowGroupsDropdown(false);
                         // Use the parent's group selection handler
                         if (onGroupSelect) {
                           onGroupSelect(group);
                         }
                       }}
                       className={`flex-row items-center px-4 py-3 ${
                         index < userGroups.length - 1 ? 'border-b border-gray-100' : ''
                       }`}
                       activeOpacity={0.7}
                     >
                      <StyledView className="w-6 h-6 bg-mint rounded-full items-center justify-center mr-3">
                        <Icon name="group" size={14} color="white" />
                      </StyledView>
                      <AppText className="text-gray-900 font-medium flex-1">{group.name}</AppText>
                    </StyledTouchableOpacity>
                  ))}
                </>
              )}

              {/* No Groups Message */}
              {userGroups.length === 0 && (
                <StyledView className="px-4 py-3">
                  <AppText className="text-gray-500 text-sm text-center">No groups yet</AppText>
                </StyledView>
              )}
            </StyledView>
          </StyledView>
          
          {/* Invisible touch area to close dropdown when tapping outside */}
          <TouchableOpacity
            style={{ flex: 1 }}
            activeOpacity={1}
            onPress={() => setShowGroupsDropdown(false)}
          />
        </StyledView>
      </Modal>
    );
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
              <StyledView className="flex-row items-center">
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
                {tab.isDropdown && (
                  <Icon 
                    name="keyboard-arrow-down" 
                    size={20} 
                    color={isActive ? MINT : '#b3b3b3'} 
                    style={{ marginLeft: 4 }}
                  />
                )}
              </StyledView>
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
          ref={tab.id === 'groups' ? groupsButtonRef : undefined}
          onPress={() => handleTabPress(tab.id)}
          activeOpacity={0.7}
          style={{
            alignItems: 'center',
            justifyContent: 'center',
            paddingVertical: 6,
          }}
        >
          <StyledView className="flex-row items-center">
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
            {tab.isDropdown && (
              <Icon 
                name="keyboard-arrow-down" 
                size={20} 
                color={isActive ? MINT : '#b3b3b3'} 
                style={{ marginLeft: 4 }}
              />
            )}
          </StyledView>
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



  // Otherwise render the normal navigation bar
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
      
      {/* Groups Dropdown Modal */}
      {renderGroupsDropdown()}
      

    </StyledView>
  );
};

export default SecondaryNavBar; 