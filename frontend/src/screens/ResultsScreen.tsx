import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  Dimensions,
  Linking,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { COLORS, SHADOWS } from '../theme/colors';

const { width } = Dimensions.get('window');

interface Recommendation {
  id: string;
  name: string;
  type: string;
  rating: number;
  distance: string;
  imageUrl: string;
  tiktokUrl?: string;
  googleMapsUrl?: string;
}

const ResultsScreen = () => {
  const recommendations: Recommendation[] = [
    {
      id: '1',
      name: 'The Hidden Gem Cafe',
      type: 'Coffee Shop',
      rating: 4.8,
      distance: '0.5 mi',
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d82924aeb?w=800',
      tiktokUrl: 'https://tiktok.com/@hidden_gem_cafe',
      googleMapsUrl: 'https://maps.google.com/?q=hidden+gem+cafe',
    },
    {
      id: '2',
      name: 'Adventure Park',
      type: 'Activity',
      rating: 4.6,
      distance: '2.3 mi',
      imageUrl: 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800',
      tiktokUrl: 'https://tiktok.com/@adventure_park',
      googleMapsUrl: 'https://maps.google.com/?q=adventure+park',
    },
    {
      id: '3',
      name: 'Night Market',
      type: 'Food & Entertainment',
      rating: 4.9,
      distance: '1.1 mi',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      tiktokUrl: 'https://tiktok.com/@night_market',
      googleMapsUrl: 'https://maps.google.com/?q=night+market',
    },
  ];

  const handleSave = (item: Recommendation) => {
    // Implement save functionality
    console.log('Saving:', item.name);
  };

  const handleShare = (item: Recommendation) => {
    // Implement share functionality
    console.log('Sharing:', item.name);
  };

  const handleTikTok = (url?: string) => {
    if (url) {
      Linking.openURL(url);
    }
  };

  const handleGoogleMaps = (url?: string) => {
    if (url) {
      Linking.openURL(url);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.background}>
        <ScrollView style={styles.scrollView}>
          <Text style={styles.title}>Your Perfect Matches</Text>
          {recommendations.map((item) => (
            <TouchableOpacity
              key={item.id}
              style={styles.card}
              onPress={() => handleGoogleMaps(item.googleMapsUrl)}
            >
              <Image
                source={{ uri: item.imageUrl }}
                style={styles.image}
                defaultSource={{ uri: 'https://via.placeholder.com/300x200' }}
              />
              <View style={styles.cardContent}>
                <Text style={styles.name}>{item.name}</Text>
                <Text style={styles.type}>{item.type}</Text>
                <View style={styles.details}>
                  <View style={styles.rating}>
                    <Icon name="star" size={16} color={COLORS.sunnyYellow} />
                    <Text style={styles.ratingText}>{item.rating}</Text>
                  </View>
                  <Text style={styles.distance}>{item.distance}</Text>
                </View>
                <View style={styles.actions}>
                  <TouchableOpacity
                    style={styles.actionButton}
                    onPress={() => handleSave(item)}
                  >
                    <Icon name="save" size={24} color={COLORS.text} />
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={styles.actionButton}
                    onPress={() => handleShare(item)}
                  >
                    <Icon name="share" size={24} color={COLORS.text} />
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={styles.actionButton}
                    onPress={() => handleTikTok(item.tiktokUrl)}
                  >
                    <Icon name="play-circle" size={24} color={COLORS.text} />
                  </TouchableOpacity>
                </View>
              </View>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  background: {
    flex: 1,
    backgroundColor: COLORS.coral,
  },
  scrollView: {
    flex: 1,
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: 20,
    textAlign: 'center',
  },
  card: {
    backgroundColor: COLORS.cardBackground,
    borderRadius: 15,
    marginBottom: 20,
    overflow: 'hidden',
    ...SHADOWS.card,
  },
  image: {
    width: '100%',
    height: width * 0.6,
    resizeMode: 'cover',
  },
  cardContent: {
    padding: 15,
  },
  name: {
    fontSize: 20,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: 5,
  },
  type: {
    fontSize: 16,
    color: COLORS.text,
    opacity: 0.7,
    marginBottom: 10,
  },
  details: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  rating: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  ratingText: {
    marginLeft: 5,
    fontSize: 16,
    color: COLORS.text,
  },
  distance: {
    fontSize: 16,
    color: COLORS.text,
  },
  actions: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    borderTopWidth: 1,
    borderTopColor: 'rgba(0,0,0,0.1)',
    paddingTop: 15,
  },
  actionButton: {
    padding: 10,
  },
});

export default ResultsScreen; 