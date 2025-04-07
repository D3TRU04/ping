// HomeScreen.tsx
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  Image,
  FlatList,
  TouchableOpacity,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import Icon from 'react-native-vector-icons/MaterialIcons';
import NavBar from '../components/NavBar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const { width, height } = Dimensions.get('window');

type RootStackParamList = {
  Home: undefined;
  Profile: undefined;
  Notifications: undefined;
};

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

// Sample content data (this would typically be loaded from your backend)
const contentData = [
  {
    id: '1',
    name: 'Espoch Coffee',
    image: 'https://via.placeholder.com/800x1200?text=Espoch+Coffee',
    overview: 'A cozy coffee shop with a vibrant atmosphere and excellent brews.',
  },
  {
    id: '2',
    name: 'Sunset Concert',
    image: 'https://via.placeholder.com/800x1200?text=Sunset+Concert',
    overview: 'Enjoy live music as the sun sets, featuring popular local bands.',
  },
  {
    id: '3',
    name: 'City Art Gallery',
    image: 'https://via.placeholder.com/800x1200?text=City+Art+Gallery',
    overview: 'Explore contemporary art pieces in a modern space that inspires creativity.',
  },
  // Add more items as needed...
];

export default function HomeScreen() {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const insets = useSafeAreaInsets();

  // Render each content item as a full-screen post
  const renderItem = ({ item }: { item: typeof contentData[0] }) => (
    <View style={styles.contentContainer}>
      <Text style={styles.title}>{item.name}</Text>
      <Image source={{ uri: item.image }} style={styles.image} resizeMode="cover" />
      <Text style={styles.overview}>{item.overview}</Text>
    </View>
  );

  return (
    <View style={styles.container}>
      {/* Main scrolling feed */}
      <FlatList
        data={contentData}
        renderItem={renderItem}
        keyExtractor={(item) => item.id}
        pagingEnabled
        showsVerticalScrollIndicator={false}
        onEndReached={() => {
          console.log('Reached end of content');
          // You can add logic here to load more content for infinite scroll
        }}
        onEndReachedThreshold={0.5}
      />

      {/* Fixed Header with Profile (top left) and Notifications (top right) */}
      <View style={[styles.header, { paddingTop: insets.top + 10 }]}>
        <TouchableOpacity onPress={() => navigation.navigate('ProfileScreen')}>
          <Image
            source={{ uri: 'https://via.placeholder.com/150' }}
            style={styles.profileImage}
          />
        </TouchableOpacity>
        <TouchableOpacity onPress={() => navigation.navigate('Notifications')}>
          <Icon name="notifications" size={28} color="#000" />
        </TouchableOpacity>
      </View>

      {/* Bottom Navigation Bar */}
      <NavBar />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  // Header styles: absolutely positioned at the top of the screen
  header: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    zIndex: 10, // Ensures the header appears on top of the feed
  },
  profileImage: {
    width: 40,
    height: 40,
    borderRadius: 20,
  },
  // Styles for each content post
  contentContainer: {
    width: width,
    height: height, // Each post fills the entire screen
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#fff',
  },
  title: {
    position: 'absolute',
    top: 60,
    fontSize: 32,
    fontWeight: 'bold',
    color: '#000',
  },
  image: {
    width: width - 40,
    height: height * 0.6,
    borderRadius: 10,
  },
  overview: {
    marginTop: 20,
    fontSize: 18,
    textAlign: 'center',
    paddingHorizontal: 20,
    color: '#333',
  },
});

