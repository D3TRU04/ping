import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Image,
  TouchableOpacity,
  Platform,
  ImageBackground,
  Modal,
  TextInput,
  Share,
  Alert,
  FlatList,
  Dimensions,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { COLORS } from '../theme/colors';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const { width } = Dimensions.get('window');
const PIN_SIZE = width / 2 - 24;

// Define interfaces for our data types
interface Board {
  id: number;
  name: string;
  pinCount: number;
  coverImage: string;
}

interface Pin {
  id: number;
  image: string;
  likes: number;
  comments: number;
}

const ProfileScreen = () => {
  const insets = useSafeAreaInsets();
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [activeTab, setActiveTab] = useState('created');
  
  const [profileData, setProfileData] = useState({
    name: 'Dan Truong',
    username: 'dantruongg_',
    avatar: 'https://i.pravatar.cc/300',
    birthday: 'October',
    joinDate: 'Apr \'24',
    bio: 'Coffee enthusiast and adventure seeker. Always looking for new experiences and hidden gems in the city.',
    followers: '256',
    following: '189',
  });
  
  const [editForm, setEditForm] = useState({ ...profileData });

  // Mock data for boards/collections
  const boards = [
    { id: 1, name: 'Food Spots', pinCount: 24, coverImage: 'https://source.unsplash.com/random/300x300/?food' },
    { id: 2, name: 'Travel Ideas', pinCount: 18, coverImage: 'https://source.unsplash.com/random/300x300/?travel' },
    { id: 3, name: 'Coffee Shops', pinCount: 15, coverImage: 'https://source.unsplash.com/random/300x300/?coffee' },
    { id: 4, name: 'Weekend Activities', pinCount: 12, coverImage: 'https://source.unsplash.com/random/300x300/?weekend' },
  ];

  // Mock data for pins
  const pins = [
    { id: 1, image: 'https://source.unsplash.com/random/600x800/?cafe', likes: 45, comments: 8 },
    { id: 2, image: 'https://source.unsplash.com/random/600x600/?food', likes: 32, comments: 5 },
    { id: 3, image: 'https://source.unsplash.com/random/600x900/?travel', likes: 67, comments: 12 },
    { id: 4, image: 'https://source.unsplash.com/random/600x700/?restaurant', likes: 29, comments: 3 },
    { id: 5, image: 'https://source.unsplash.com/random/600x800/?dessert', likes: 51, comments: 7 },
    { id: 6, image: 'https://source.unsplash.com/random/600x600/?city', likes: 38, comments: 4 },
  ];

  // Function to handle sharing profile
  const handleShareProfile = async () => {
    try {
      const result = await Share.share({
        message: `Check out ${profileData.name}'s profile on Ping! @${profileData.username}`,
        url: 'https://ping-app.com/profile/' + profileData.username,
        title: `${profileData.name}'s Ping Profile`,
      });
      
      if (result.action === Share.sharedAction) {
        if (result.activityType) {
          console.log(`Shared with ${result.activityType}`);
        } else {
          console.log('Shared successfully');
        }
      } else if (result.action === Share.dismissedAction) {
        console.log('Share dismissed');
      }
    } catch (error) {
      Alert.alert('Error', 'Could not share profile');
    }
  };

  // Function to handle profile editing
  const handleSaveProfile = () => {
    setProfileData(editForm);
    setEditModalVisible(false);
    Alert.alert('Success', 'Profile updated successfully!');
  };

  const stats = [
    { label: 'Matches', value: '24' },
    { label: 'Saved', value: '12' },
    { label: 'Reviews', value: '8' },
  ];

  const preferences = [
    'Coffee Shops',
    'Outdoor Activities',
    'Live Music',
    'Fine Dining',
    'Art Galleries',
  ];

  // Edit Profile Modal
  const renderEditProfileModal = () => (
    <Modal
      animationType="slide"
      transparent={true}
      visible={editModalVisible}
      onRequestClose={() => setEditModalVisible(false)}
    >
      <View style={styles.modalContainer}>
        <View style={styles.modalContent}>
          <View style={styles.modalHeader}>
            <Text style={styles.modalTitle}>Edit Profile</Text>
            <TouchableOpacity onPress={() => setEditModalVisible(false)}>
              <Icon name="close" size={24} color="#000" />
            </TouchableOpacity>
          </View>
          
          <ScrollView>
            <View style={styles.formGroup}>
              <Text style={styles.formLabel}>Display Name</Text>
              <TextInput
                style={styles.formInput}
                value={editForm.name}
                onChangeText={(text) => setEditForm({...editForm, name: text})}
                placeholder="Your name"
              />
            </View>
            
            <View style={styles.formGroup}>
              <Text style={styles.formLabel}>Username</Text>
              <TextInput
                style={styles.formInput}
                value={editForm.username}
                onChangeText={(text) => setEditForm({...editForm, username: text})}
                placeholder="Your username"
              />
            </View>
            
            <View style={styles.formGroup}>
              <Text style={styles.formLabel}>Bio</Text>
              <TextInput
                style={[styles.formInput, styles.bioInput]}
                value={editForm.bio}
                onChangeText={(text) => setEditForm({...editForm, bio: text})}
                placeholder="Tell us about yourself"
                multiline
                numberOfLines={4}
              />
            </View>
            
            <View style={styles.formGroup}>
              <Text style={styles.formLabel}>Avatar URL</Text>
              <TextInput
                style={styles.formInput}
                value={editForm.avatar}
                onChangeText={(text) => setEditForm({...editForm, avatar: text})}
                placeholder="URL to your profile image"
              />
            </View>
            
            <View style={styles.formGroup}>
              <Text style={styles.formLabel}>Birthday Month</Text>
              <TextInput
                style={styles.formInput}
                value={editForm.birthday}
                onChangeText={(text) => setEditForm({...editForm, birthday: text})}
                placeholder="Your birthday month"
              />
            </View>
            
            <TouchableOpacity style={styles.saveButton} onPress={handleSaveProfile}>
              <Text style={styles.saveButtonText}>Save Changes</Text>
            </TouchableOpacity>
          </ScrollView>
        </View>
      </View>
    </Modal>
  );

  // Render a board item
  const renderBoardItem = ({ item }: { item: Board }) => (
    <TouchableOpacity style={styles.boardItem}>
      <ImageBackground
        source={{ uri: item.coverImage }}
        style={styles.boardCover}
        imageStyle={{ borderRadius: 12 }}
      >
        <View style={styles.boardOverlay}>
          <Text style={styles.boardPinCount}>{item.pinCount} Pins</Text>
        </View>
      </ImageBackground>
      <Text style={styles.boardName}>{item.name}</Text>
    </TouchableOpacity>
  );

  // Render a pin item
  const renderPinItem = ({ item }: { item: Pin }) => (
    <TouchableOpacity style={styles.pinItem}>
      <Image
        source={{ uri: item.image }}
        style={[styles.pinImage, { height: item.id % 2 === 0 ? PIN_SIZE : PIN_SIZE * 1.25 }]}
      />
      <View style={styles.pinOverlay}>
        <TouchableOpacity style={styles.savePin}>
          <Text style={styles.savePinText}>Save</Text>
        </TouchableOpacity>
        <View style={styles.pinStats}>
          <View style={styles.pinStat}>
            <Icon name="favorite" size={16} color="#fff" />
            <Text style={styles.pinStatText}>{item.likes}</Text>
          </View>
          <View style={styles.pinStat}>
            <Icon name="chat-bubble" size={16} color="#fff" />
            <Text style={styles.pinStatText}>{item.comments}</Text>
          </View>
        </View>
      </View>
    </TouchableOpacity>
  );

  // Render different content based on active tab
  const renderTabContent = () => {
    switch (activeTab) {
      case 'created':
        return (
          <View style={styles.pinsGrid}>
            <FlatList
              data={pins}
              renderItem={renderPinItem}
              keyExtractor={(item) => item.id.toString()}
              numColumns={2}
              columnWrapperStyle={styles.pinsRow}
              scrollEnabled={false}
            />
          </View>
        );
      case 'saved':
        return (
          <View style={styles.boardsContainer}>
            <FlatList
              data={boards}
              renderItem={renderBoardItem}
              keyExtractor={(item) => item.id.toString()}
              horizontal={false}
              numColumns={2}
              columnWrapperStyle={styles.boardsRow}
              scrollEnabled={false}
            />
          </View>
        );
      default:
        return null;
    }
  };

  return (
    <ScrollView style={styles.container}>
      {/* Header with profile info */}
      <View style={[styles.header, { paddingTop: insets.top }]}>
        <View style={styles.userInfoHeader}>
          <View style={styles.usernameContainer}>
            <Text style={styles.username}>{profileData.name}</Text>
            <Icon name="keyboard-arrow-down" size={24} color="#000" />
          </View>
          <View style={styles.headerButtons}>
            <TouchableOpacity style={styles.iconButton} onPress={() => setEditModalVisible(true)}>
              <Icon name="edit" size={24} color="#000" />
            </TouchableOpacity>
            <TouchableOpacity style={styles.iconButton}>
              <Icon name="settings" size={24} color="#000" />
            </TouchableOpacity>
          </View>
        </View>
      </View>

      {/* Profile picture section */}
      <View style={styles.profileSection}>
        <View style={styles.profileImageContainer}>
          <Image
            source={{ uri: profileData.avatar }}
            style={styles.profileImage}
          />
          <TouchableOpacity style={styles.cameraButton} onPress={() => setEditModalVisible(true)}>
            <Icon name="photo-camera" size={24} color="#fff" />
          </TouchableOpacity>
        </View>

        <Text style={styles.displayName}>{profileData.name}</Text>
        
        <View style={styles.usernameRow}>
          <Icon name="alternate-email" size={20} color="#000" />
          <Text style={styles.handle}>{profileData.username}</Text>
        </View>

        {/* Bio section */}
        <Text style={styles.bio}>{profileData.bio}</Text>
        
        {/* Followers/Following stats */}
        <View style={styles.followStats}>
          <TouchableOpacity style={styles.followStat}>
            <Text style={styles.followCount}>{profileData.followers}</Text>
            <Text style={styles.followLabel}>followers</Text>
          </TouchableOpacity>
          <View style={styles.followDivider} />
          <TouchableOpacity style={styles.followStat}>
            <Text style={styles.followCount}>{profileData.following}</Text>
            <Text style={styles.followLabel}>following</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.profileButtonsContainer}>
          <TouchableOpacity 
            style={styles.profileButton}
            onPress={() => setEditModalVisible(true)}>
            <Text style={styles.profileButtonText}>Edit profile</Text>
          </TouchableOpacity>
          <TouchableOpacity 
            style={styles.profileButton}
            onPress={handleShareProfile}>
            <Text style={styles.profileButtonText}>Share profile</Text>
          </TouchableOpacity>
        </View>
        
        <View style={styles.birthdayRow}>
          <Text style={styles.infoText}>
            <Icon name="cake" size={18} color="#000" /> {profileData.birthday} birthday •
          </Text>
          <Text style={styles.infoText}>
            <Icon name="egg" size={18} color="#000" /> Joined {profileData.joinDate}
          </Text>
        </View>
      </View>

      {/* Tab navigation */}
      <View style={styles.tabContainer}>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'created' && styles.activeTab]}
          onPress={() => setActiveTab('created')}
        >
          <Text style={[styles.tabText, activeTab === 'created' && styles.activeTabText]}>Created</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'saved' && styles.activeTab]}
          onPress={() => setActiveTab('saved')}
        >
          <Text style={[styles.tabText, activeTab === 'saved' && styles.activeTabText]}>Saved</Text>
        </TouchableOpacity>
      </View>

      {/* Tab content */}
      {renderTabContent()}

      {/* Bottom navigation */}
      <View style={styles.bottomNavSpacer} />

      {/* Edit Profile Modal */}
      {renderEditProfileModal()}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  userInfoHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  usernameContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  username: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
  },
  headerButtons: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  iconButton: {
    marginLeft: 16,
  },
  profileSection: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  profileImageContainer: {
    position: 'relative',
    marginBottom: 20,
  },
  profileImage: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: '#f0f0f0',
  },
  cameraButton: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    backgroundColor: '#000',
    padding: 8,
    borderRadius: 20,
    borderWidth: 2,
    borderColor: '#fff',
  },
  displayName: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 8,
  },
  usernameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  handle: {
    fontSize: 16,
    color: '#000',
    marginLeft: 4,
  },
  bio: {
    fontSize: 16,
    color: '#333',
    textAlign: 'center',
    paddingHorizontal: 40,
    marginBottom: 20,
    lineHeight: 22,
  },
  followStats: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 20,
  },
  followStat: {
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  followCount: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#000',
  },
  followLabel: {
    fontSize: 14,
    color: '#666',
  },
  followDivider: {
    width: 1,
    height: 24,
    backgroundColor: '#ddd',
  },
  profileButtonsContainer: {
    flexDirection: 'row',
    width: '90%',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  profileButton: {
    flex: 1,
    padding: 12,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    alignItems: 'center',
    marginHorizontal: 8,
  },
  profileButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#000',
  },
  birthdayRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
  },
  infoText: {
    fontSize: 14,
    color: '#555',
    marginHorizontal: 4,
  },
  tabContainer: {
    flexDirection: 'row',
    marginTop: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  tab: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 12,
  },
  tabText: {
    fontSize: 16,
    color: '#666',
  },
  activeTab: {
    borderBottomWidth: 2,
    borderBottomColor: '#000',
  },
  activeTabText: {
    color: '#000',
    fontWeight: 'bold',
  },
  pinsGrid: {
    padding: 12,
  },
  pinsRow: {
    justifyContent: 'space-between',
  },
  pinItem: {
    width: PIN_SIZE,
    marginBottom: 16,
    position: 'relative',
  },
  pinImage: {
    width: PIN_SIZE,
    borderRadius: 16,
  },
  pinOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    padding: 8,
    justifyContent: 'space-between',
  },
  savePin: {
    alignSelf: 'flex-end',
    backgroundColor: '#E60023',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 16,
  },
  savePinText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 12,
  },
  pinStats: {
    flexDirection: 'row',
  },
  pinStat: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0.5)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
    marginRight: 8,
  },
  pinStatText: {
    color: '#fff',
    fontSize: 12,
    marginLeft: 4,
  },
  boardsContainer: {
    padding: 12,
  },
  boardsRow: {
    justifyContent: 'space-between',
  },
  boardItem: {
    width: PIN_SIZE,
    marginBottom: 16,
  },
  boardCover: {
    width: PIN_SIZE,
    height: PIN_SIZE,
    marginBottom: 8,
    justifyContent: 'flex-end',
  },
  boardOverlay: {
    backgroundColor: 'rgba(0,0,0,0.3)',
    padding: 8,
  },
  boardName: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#000',
  },
  boardPinCount: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  bottomNavSpacer: {
    height: 80,
  },
  modalContainer: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    maxHeight: '80%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#000',
  },
  formGroup: {
    marginBottom: 20,
  },
  formLabel: {
    fontSize: 16,
    fontWeight: '500',
    color: '#000',
    marginBottom: 8,
  },
  formInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  bioInput: {
    height: 100,
    textAlignVertical: 'top',
  },
  saveButton: {
    backgroundColor: '#000',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginVertical: 10,
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  statsSection: {
    padding: 16,
    marginTop: 8,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 16,
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    backgroundColor: '#f5f5f5',
    borderRadius: 12,
    padding: 16,
  },
  statItem: {
    alignItems: 'center',
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
  },
  statLabel: {
    fontSize: 14,
    color: '#666',
    marginTop: 4,
  },
  preferencesSection: {
    padding: 16,
    marginTop: 8,
  },
  preferencesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  preferenceTag: {
    backgroundColor: '#f0f0f0',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    marginRight: 8,
    marginBottom: 8,
  },
  preferenceText: {
    color: '#000',
    fontWeight: '500',
  },
});

export default ProfileScreen; 