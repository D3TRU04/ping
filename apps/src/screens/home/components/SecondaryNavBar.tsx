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
  onGroupSelect?: (group: any) => void;
}

const MINT = '#1FC9C3';



const SecondaryNavBar: React.FC<SecondaryNavBarProps> = ({ 
  activeTab, 
  onTabChange,
  currentUser,
  onGroupSelect
}) => {
  const insets = useSafeAreaInsets();
  const scrollRef = useRef<ScrollView>(null);
  const didScrollRef = useRef(false);
  const [showGroupsDropdown, setShowGroupsDropdown] = useState(false);
  const [userGroups, setUserGroups] = useState<any[]>([]);
  const [groupsLoading, setGroupsLoading] = useState(false);
  const [groupsFetched, setGroupsFetched] = useState(false);

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
      onTabChange(tabId);
    }
  };

  // Fetch user groups with caching and loading state
  const fetchUserGroups = async (forceRefresh = false) => {
    if (!currentUser?.id || groupsLoading) return;
    
    // If we already fetched groups for this user and not forcing refresh, don't fetch again
    if (groupsFetched && !forceRefresh) return;
    
    setGroupsLoading(true);
    
    try {
      const { data: groupChats, error } = await supabase
        .from('groups')
        .select(`
          id,
          name,
          group_members!inner(user_id)
        `)
        .eq('group_members.user_id', currentUser.id);

      if (error) {
        console.error('Error fetching user group chats:', error);
        return;
      }

      const groups = groupChats || [];
      setUserGroups(groups);
      setGroupsFetched(true);
    } catch (error) {
      console.error('Error fetching user group chats:', error);
    } finally {
      setGroupsLoading(false);
    }
  };

  // Reset groups when user changes
  useEffect(() => {
    setUserGroups([]);
    setGroupsFetched(false);
    setGroupsLoading(false);
  }, [currentUser?.id]);

  // Pre-fetch groups when component mounts or user changes
  useEffect(() => {
    if (currentUser?.id) {
      // Small delay to avoid blocking the UI
      const timer = setTimeout(() => {
        fetchUserGroups();
      }, 100);
      return () => clearTimeout(timer);
    }
  }, [currentUser?.id]);

  // Fetch groups when dropdown opens (fallback)
  useEffect(() => {
    if (showGroupsDropdown && currentUser?.id && !groupsFetched) {
      fetchUserGroups();
    }
  }, [showGroupsDropdown, currentUser?.id, groupsFetched]);


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
              top: dropdownPosition.top || 100,
              left: dropdownPosition.left || 50,
            }}
          >
            <StyledView className="bg-white rounded-xl shadow-lg border border-gray-200 w-[240px] max-h-[400px]">
              {/* Header with refresh button */}
              <StyledView className="flex-row items-center justify-between px-4 py-2 bg-gray-50 border-b border-gray-100">
                <AppText className="text-xs text-gray-500 font-medium">GROUPS</AppText>
                <StyledTouchableOpacity
                  onPress={() => fetchUserGroups(true)}
                  disabled={groupsLoading}
                  className="p-1"
                  activeOpacity={0.7}
                >
                  <Icon 
                    name="refresh" 
                    size={14} 
                    color={groupsLoading ? "#ccc" : "#666"} 
                    style={{ 
                      transform: groupsLoading ? [{ rotate: '180deg' }] : [{ rotate: '0deg' }] 
                    }}
                  />
                </StyledTouchableOpacity>
              </StyledView>

              {/* Loading State */}
              {groupsLoading && (
                <StyledView className="px-4 py-3 flex-row items-center justify-center">
                  <Icon name="refresh" size={16} color="#666" />
                  <AppText className="text-gray-500 text-sm ml-2">Loading groups...</AppText>
                </StyledView>
              )}

              {/* User Groups */}
              {!groupsLoading && userGroups.length > 0 && (
                <>
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
              {!groupsLoading && userGroups.length === 0 && groupsFetched && (
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