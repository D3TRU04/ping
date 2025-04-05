import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ImageBackground,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';

type RootStackParamList = {
  Startup: undefined;
  SignUp: undefined;
  SignIn: undefined;
  Home: undefined;
};

type StartupScreenNavigationProp = StackNavigationProp<
  RootStackParamList,
  'Startup'
>;

const StartupScreen = () => {
  const navigation = useNavigation<StartupScreenNavigationProp>();

  return (
    <View style={styles.container}>
      {/* Background image can be replaced with your desired visual */}
      <ImageBackground
        source={require('../../assets/Headshot.jpg')}
        style={styles.background}
      >
        {/* Floating components simulating popular locations/events */}
        <View style={[styles.floatingComponent, { top: 50, left: 30 }]}>
          <Text style={styles.floatingText}>Concerts</Text>
        </View>
        <View style={[styles.floatingComponent, { top: 120, right: 30 }]}>
          <Text style={styles.floatingText}>Restaurants</Text>
        </View>
        <View style={[styles.floatingComponent, { bottom: 100, left: 50 }]}>
          <Text style={styles.floatingText}>Art Galleries</Text>
        </View>
        <View style={[styles.floatingComponent, { bottom: 150, right: 50 }]}>
          <Text style={styles.floatingText}>Theaters</Text>
        </View>

        {/* Center container with logo and navigation buttons */}
        <View style={styles.centerContainer}>
          <Text style={styles.logoText}>Ping!</Text>
          <Text style={styles.tagline}>Discover your next adventure</Text>

          <TouchableOpacity
            style={styles.signupButton}
            onPress={() => navigation.navigate('SignUp')}
          >
            <Text style={styles.buttonText}>Sign Up</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.signinButton}
            onPress={() => navigation.navigate('SignIn')}
          >
            <Text style={[styles.buttonText, styles.signinButtonText]}>
              Sign In
            </Text>
          </TouchableOpacity>
        </View>
      </ImageBackground>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  background: {
    flex: 1,
    resizeMode: 'cover',
    justifyContent: 'center',
  },
  centerContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    flex: 1,
  },
  logoText: {
    fontSize: 60,
    fontWeight: 'bold',
    color: '#FFFFFF',
    marginBottom: 10,
  },
  tagline: {
    fontSize: 18,
    color: '#FFFFFF',
    marginBottom: 40,
  },
  signupButton: {
    backgroundColor: '#FF6B6B',
    paddingVertical: 15,
    paddingHorizontal: 50,
    borderRadius: 30,
    marginVertical: 10,
  },
  signinButton: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#FFFFFF',
    paddingVertical: 15,
    paddingHorizontal: 50,
    borderRadius: 30,
    marginVertical: 10,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 18,
  },
  signinButtonText: {
    color: '#FFFFFF',
  },
  floatingComponent: {
    position: 'absolute',
    backgroundColor: 'rgba(255, 255, 255, 0.8)',
    paddingVertical: 5,
    paddingHorizontal: 10,
    borderRadius: 10,
  },
  floatingText: {
    color: '#333',
    fontSize: 14,
  },
});

export default StartupScreen;
