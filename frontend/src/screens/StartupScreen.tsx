import React from 'react';
import {
  View,
  StyleSheet,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  Dimensions,
  ImageBackground,
  Text,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';

const { width } = Dimensions.get('window');

const illustration = require('../assets/illustration.png');

type RootStackParamList = {
  Startup: undefined;
  SignUp: undefined;
  SignIn: undefined;
  Home: undefined;
};

type StartupScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Startup'>;

const StartupScreen = () => {
  const navigation = useNavigation<StartupScreenNavigationProp>();

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
    >
      <ImageBackground
        source={illustration}
        style={styles.background}
        resizeMode="cover"
      >
        <View style={styles.buttonContainer}>
          <TouchableOpacity
            style={styles.getStartedButton}
            onPress={() => navigation.navigate('SignUp')}
          >
            <Text style={styles.getStartedButtonText}>Get Started</Text>
          </TouchableOpacity>
          <Text style={styles.disclaimer}>
            By tapping 'Get Started', you agree to our Privacy Policy and Terms of Service.
          </Text>
        </View>
      </ImageBackground>
    </KeyboardAvoidingView>
  );
};

const RED = '#E74C3C';
const CREAM = '#FFF6E3';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFA726',
  },
  background: {
    flex: 1,
    width: '100%',
    height: '100%',
    justifyContent: 'flex-end',
  },
  buttonContainer: {
    width: '100%',
    alignItems: 'center',
    paddingBottom: 48,
    paddingHorizontal: 32,
  },
  getStartedButton: {
    backgroundColor: RED,
    borderRadius: 16,
    paddingVertical: 18,
    paddingHorizontal: 64,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 2,
    marginBottom: 32,
  },
  getStartedButtonText: {
    color: CREAM,
    fontFamily: 'System',
    fontSize: 20,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  disclaimer: {
    color: '#FFFFFF',
    fontSize: 12,
    textAlign: 'center',
    marginTop: 12,
    opacity: 1,
  },
});

export default StartupScreen;
