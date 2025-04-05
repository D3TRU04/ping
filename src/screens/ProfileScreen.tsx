import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Image,
  TouchableOpacity,
  Platform,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { COLORS } from '../theme/colors';

const ProfileScreen = () => {
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

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <View style={styles.profileImageContainer}>
          <Image
            source={{ uri: 'https://i.pravatar.cc/300' }}
            style={styles.profileImage}
          />
          <TouchableOpacity style={styles.editButton}>
            <Icon name="edit" size={20} color={COLORS.text} />
          </TouchableOpacity>
        </View>
        <Text style={styles.name}>Alex Johnson</Text>
        <Text style={styles.location}>San Francisco, CA</Text>
      </View>

      <View style={styles.statsContainer}>
        {stats.map((stat, index) => (
          <View key={index} style={styles.statItem}>
            <Text style={styles.statValue}>{stat.value}</Text>
            <Text style={styles.statLabel}>{stat.label}</Text>
          </View>
        ))}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>About Me</Text>
        <Text style={styles.bio}>
          Coffee enthusiast and adventure seeker. Always looking for new experiences
          and hidden gems in the city. Love trying new restaurants and meeting new
          people!
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Preferences</Text>
        <View style={styles.preferencesContainer}>
          {preferences.map((pref, index) => (
            <View key={index} style={styles.preferenceTag}>
              <Text style={styles.preferenceText}>{pref}</Text>
            </View>
          ))}
        </View>
      </View>

      <TouchableOpacity style={styles.settingsButton}>
        <Icon name="settings" size={24} color={COLORS.text} />
        <Text style={styles.settingsText}>Settings</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    alignItems: 'center',
    paddingVertical: 30,
  },
  profileImageContainer: {
    position: 'relative',
    marginBottom: 15,
  },
  profileImage: {
    width: 120,
    height: 120,
    borderRadius: 60,
  },
  editButton: {
    position: 'absolute',
    right: 0,
    bottom: 0,
    backgroundColor: COLORS.background,
    padding: 8,
    borderRadius: 20,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
      },
      android: {
        elevation: 5,
      },
    }),
  },
  name: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: 5,
  },
  location: {
    fontSize: 16,
    color: COLORS.textSecondary,
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingVertical: 20,
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: 'rgba(0, 0, 0, 0.1)',
    marginHorizontal: 20,
  },
  statItem: {
    alignItems: 'center',
  },
  statValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: COLORS.coral,
    marginBottom: 5,
  },
  statLabel: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  section: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: 10,
  },
  bio: {
    fontSize: 16,
    color: COLORS.text,
    lineHeight: 24,
  },
  preferencesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  preferenceTag: {
    backgroundColor: 'rgba(255, 107, 107, 0.1)',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 20,
  },
  preferenceText: {
    color: COLORS.coral,
    fontSize: 14,
  },
  settingsButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 15,
    marginHorizontal: 20,
    marginVertical: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.05)',
    borderRadius: 10,
    gap: 10,
  },
  settingsText: {
    fontSize: 16,
    color: COLORS.text,
    fontWeight: '500',
  },
});

export default ProfileScreen; 