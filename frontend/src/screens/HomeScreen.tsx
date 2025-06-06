// // HomeScreen.tsx
// import React, { useState } from 'react';
// import {
//   View,
//   Text,
//   StyleSheet,
//   Dimensions,
//   Image,
//   FlatList,
//   TouchableOpacity,
// } from 'react-native';
// import { useNavigation } from '@react-navigation/native';
// import { StackNavigationProp } from '@react-navigation/stack';
// import Icon from 'react-native-vector-icons/MaterialIcons';
// import NavBar from '../components/NavBar';
// import { useSafeAreaInsets } from 'react-native-safe-area-context';

// const { width, height } = Dimensions.get('window');

// type RootStackParamList = {
//   Home: undefined;
//   Profile: undefined;
//   Notifications: undefined;
// };

// type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

// // Sample content data (this would typically be loaded from your backend)
// const contentData = [
//   {
//     id: '1',
//     name: 'Espoch Coffee',
//     image: 'https://via.placeholder.com/800x1200?text=Espoch+Coffee',
//     overview: 'A cozy coffee shop with a vibrant atmosphere and excellent brews.',
//   },
//   {
//     id: '2',
//     name: 'Sunset Concert',
//     image: 'https://via.placeholder.com/800x1200?text=Sunset+Concert',
//     overview: 'Enjoy live music as the sun sets, featuring popular local bands.',
//   },
//   {
//     id: '3',
//     name: 'City Art Gallery',
//     image: 'https://via.placeholder.com/800x1200?text=City+Art+Gallery',
//     overview: 'Explore contemporary art pieces in a modern space that inspires creativity.',
//   },
//   // Add more items as needed...
// ];

// export default function HomeScreen() {
//   const navigation = useNavigation<HomeScreenNavigationProp>();
//   const insets = useSafeAreaInsets();

//     // We'll control visibility with a state
//     const [showSurveyPrompt, setShowSurveyPrompt] = useState(true);

//   // Render each content item as a full-screen post
//   const renderItem = ({ item }: { item: typeof contentData[0] }) => (
//     <View style={styles.contentContainer}>
//       <Text style={styles.title}>{item.name}</Text>
//       <Image source={{ uri: item.image }} style={styles.image} resizeMode="cover" />
//       <Text style={styles.overview}>{item.overview}</Text>
//     </View>
//   );

//   return (
//     <View style={styles.container}>
//       {/* Main scrolling feed */}
//       <FlatList
//         data={contentData}
//         renderItem={renderItem}
//         keyExtractor={(item) => item.id}
//         pagingEnabled
//         showsVerticalScrollIndicator={false}
//         onEndReached={() => {
//           console.log('Reached end of content');
//           // You can add logic here to load more content for infinite scroll
//         }}
//         onEndReachedThreshold={0.5}
//       />

//       {/* If showSurveyPrompt is true, show a small banner */}
//       {showSurveyPrompt && (
//         <View style={[styles.surveyBanner, { top: insets.top + 60 }]}>
//           <TouchableOpacity
//             style={styles.surveyBannerContent}
//             onPress={() => {
//               // Hide the banner & navigate to Survey
//               setShowSurveyPrompt(false);
//               navigation.navigate('Survey');
//             }}
//           >
//             <Text style={styles.surveyBannerText}>What's on your mind?</Text>
//           </TouchableOpacity>
//         </View>
//       )}

//       {/* Fixed Header with Profile (top left) and Notifications (top right) */}
//       <View style={[styles.header, { paddingTop: insets.top + 10 }]}>
//         <TouchableOpacity onPress={() => navigation.navigate('ProfileScreen')}>
//           <Image
//             source={{ uri: 'https://via.placeholder.com/150' }}
//             style={styles.profileImage}
//           />
//         </TouchableOpacity>
//         <TouchableOpacity onPress={() => navigation.navigate('Notifications')}>
//           <Icon name="notifications" size={28} color="#000" />
//         </TouchableOpacity>
//       </View>

//       {/* Bottom Navigation Bar */}
//       <NavBar />
//     </View>
//   );
// }

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//   },
//   // Header styles: absolutely positioned at the top of the screen
//   header: {
//     position: 'absolute',
//     top: 0,
//     left: 0,
//     right: 0,
//     flexDirection: 'row',
//     justifyContent: 'space-between',
//     alignItems: 'center',
//     paddingHorizontal: 20,
//     zIndex: 10, // Ensures the header appears on top of the feed
//   },
//   profileImage: {
//     width: 40,
//     height: 40,
//     borderRadius: 20,
//   },
//   // Styles for each content post
//   contentContainer: {
//     width: width,
//     height: height, // Each post fills the entire screen
//     justifyContent: 'center',
//     alignItems: 'center',
//     padding: 20,
//     backgroundColor: '#fff',
//   },
//   title: {
//     position: 'absolute',
//     top: 60,
//     fontSize: 32,
//     fontWeight: 'bold',
//     color: '#000',
//   },
//   image: {
//     width: width - 40,
//     height: height * 0.6,
//     borderRadius: 10,
//   },
//   overview: {
//     marginTop: 20,
//     fontSize: 18,
//     textAlign: 'center',
//     paddingHorizontal: 20,
//     color: '#333',
//   },
//   surveyBanner: {
//     position: 'absolute',
//     left: 0,
//     right: 0,
//     zIndex: 999, // ensure on top of content
//     alignItems: 'center',
//     justifyContent: 'center',
//   },
//   surveyBannerContent: {
//     backgroundColor: '#ffd700', // a bright color to stand out
//     paddingVertical: 10,
//     paddingHorizontal: 20,
//     borderRadius: 5,
//     marginHorizontal: 20,
//   },
//   surveyBannerText: {
//     color: '#000',
//     fontSize: 16,
//     fontWeight: 'bold',
//   },
// });



import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  Image,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import Icon from 'react-native-vector-icons/MaterialIcons';
import NavBar from '../components/NavBar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { supabase } from '../../lib/supabase';

const { width, height } = Dimensions.get('window');

type RootStackParamList = {
  Home: undefined;
  Profile: undefined;
  Notifications: undefined;
  Survey: undefined;
};

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

type FoodPlace = {
  place_id: string;
  name: string;
  image_url?: string;
  description?: string;
  type_of_food?: string;
  subtopic?: string;
  rating?: number;
  price_range?: number;
  hours?: string[];
};

export default function HomeScreen() {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const insets = useSafeAreaInsets();

  const [contentData, setContentData] = useState<FoodPlace[]>([]);
  const [loading, setLoading] = useState(true);
  const [showSurveyPrompt, setShowSurveyPrompt] = useState(true);

  useEffect(() => {
    async function fetchFoodPlaces() {
      const { data, error } = await supabase
        .from('food_places')
        .select('place_id, name, image_url, description, type_of_food, subtopic, rating, price_range, hours');

      if (error) {
        console.error('Error fetching food places:', error.message);
      } else if (data) {
        const transformed = data.map((item) => ({
          place_id: item.place_id,
          name: item.name,
          image_url: item.image_url || 'https://via.placeholder.com/800x1200?text=No+Image',
          description: item.description || 'No description available',
          type_of_food: item.type_of_food || '',
          subtopic: item.subtopic || '',
          rating: item.rating || null,
          price_range: item.price_range || null,
          hours: item.hours || [],
        }));
        setContentData(transformed);
      }
      setLoading(false);
    }

    fetchFoodPlaces();
  }, []);

  const renderItem = ({ item }: { item: FoodPlace }) => (
    <View style={styles.contentContainer}>
     
      <Text style={styles.title}>{item.name}</Text>
      <Image source={{ uri: item.image_url }} style={styles.image} resizeMode="cover" />
      <Text style={styles.meta}>
        {item.subtopic} • {item.type_of_food}
      </Text>
      <Text style={styles.meta}>
        {item.rating ? `⭐ ${item.rating.toFixed(1)}` : '⭐ N/A'}{'   '}
        {item.price_range ? '💲'.repeat(item.price_range) : ''}
      </Text>
      <Text style={styles.description}>{item.description}</Text>
      {item.hours && item.hours.length > 0 && (
        <View style={styles.hoursContainer}>
          <Text style={styles.hoursLabel}>Hours:</Text>
          {item.hours.map((line, idx) => (
            <Text key={idx} style={styles.hoursText}>{line}</Text>
          ))}
        </View>
      )}
    </View>
  );

  return (
    <View style={styles.container}>
      {loading ? (
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
          <ActivityIndicator size="large" color="#000" />
          <Text>Loading places...</Text>
        </View>
      ) : (
        <FlatList
          data={contentData}
          renderItem={renderItem}
          keyExtractor={(item) => item.place_id}
          pagingEnabled
          showsVerticalScrollIndicator={false}
          onEndReached={() => console.log('End reached')}
          onEndReachedThreshold={0.5}
        />
      )}

      {/* SURVEYYY */}
      {/* {showSurveyPrompt && (
        <View style={[styles.surveyBanner, { top: insets.top + 60 }]}>
          <TouchableOpacity
            style={styles.surveyBannerContent}
            onPress={() => {
              setShowSurveyPrompt(false);
              navigation.navigate('Survey');
            }}
          >
            <Text style={styles.surveyBannerText}>What's on your mind?</Text>
          </TouchableOpacity>
        </View>
      )} */}

      <View style={[styles.header, { paddingTop: insets.top + 10 }]}>
        <TouchableOpacity onPress={() => navigation.navigate('Profile')}>
          <Image
            source={{ uri: 'https://via.placeholder.com/150' }}
            style={styles.profileImage}
          />
        </TouchableOpacity>
        <TouchableOpacity onPress={() => navigation.navigate('Notifications')}>
          <Icon name="notifications" size={28} color="#000" />
        </TouchableOpacity>
      </View>

      <NavBar />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 3,
  },
  header: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    zIndex: 10,
  },
  profileImage: {
    width: 40,
    height: 40,
    borderRadius: 20,
  },
  contentContainer: {
    width: width,
    height: height,
    justifyContent: 'flex-start',
    alignItems: 'center',
    padding: 100,
    backgroundColor: '#fff',
  },
  image: {
    width: width - 40,
    height: height * 0.3,
    borderRadius: 10,
    marginBottom: 10,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 6,
    textAlign: 'center',
  },
  meta: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
  },
  description: {
    marginTop: 10,
    fontSize: 16,
    textAlign: 'center',
    paddingHorizontal: 10,
    color: '#333',
  },
  hoursContainer: {
    marginTop: 10,
    alignItems: 'center',
  },
  hoursLabel: {
    fontWeight: 'bold',
    fontSize: 14,
    marginBottom: 2,
  },
  hoursText: {
    fontSize: 13,
    color: '#555',
  },
  surveyBanner: {
    position: 'absolute',
    left: 0,
    right: 0,
    zIndex: 999,
    alignItems: 'center',
    justifyContent: 'center',
  },
  surveyBannerContent: {
    backgroundColor: '#ffd700',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 5,
    marginHorizontal: 20,
  },
  surveyBannerText: {
    color: '#000',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
