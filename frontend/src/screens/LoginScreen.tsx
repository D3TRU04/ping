import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { COLORS } from '../theme/colors';

type RootStackParamList = {
  Login: undefined;
  Swipe: undefined;
  Startup: undefined;
};

type LoginScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Login'>;

const ORANGE = '#FFA726';
const WHITE = '#FFFFFF';

const LoginScreen = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigation = useNavigation<LoginScreenNavigationProp>();

  const handleEmailLogin = () => {
    navigation.navigate('Swipe');
  };

  const handleGoogleLogin = () => {
    navigation.navigate('Swipe');
  };

  const handleAppleLogin = () => {
    navigation.navigate('Swipe');
  };

  const handleFacebookLogin = () => {
    navigation.navigate('Swipe');
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
    >
      <View style={styles.background}>
        <TouchableOpacity style={styles.backButton} onPress={() => navigation.navigate('Startup')}>
          <Icon name="arrow-back" size={28} color={WHITE} />
        </TouchableOpacity>
        <ScrollView contentContainerStyle={styles.scrollContent}>
          <View style={styles.logoContainer}>
            <Text style={styles.logoText}>Ping!</Text>
          </View>

          <View style={styles.formContainer}>
            <TextInput
              style={styles.input}
              placeholder="Email"
              placeholderTextColor={COLORS.text + '80'}
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
            />
            <TextInput
              style={styles.input}
              placeholder="Password"
              placeholderTextColor={COLORS.text + '80'}
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />
            <TouchableOpacity
              style={styles.forgotPassword}
              onPress={() => console.log('Forgot password')}
            >
              <Text style={styles.forgotPasswordText}>Forgot Password?</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.emailLoginButton}
              onPress={handleEmailLogin}
            >
              <Text style={styles.emailLoginButtonText}>Login with Email</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.dividerContainer}>
            <View style={styles.divider} />
            <Text style={styles.dividerText}>OR</Text>
            <View style={styles.divider} />
          </View>

          <View style={styles.socialButtonsContainer}>
            <TouchableOpacity
              style={[styles.socialButton, { backgroundColor: '#4285F4' }]}
              onPress={handleGoogleLogin}
            >
              <Icon name="g-translate" size={24} color="#FFFFFF" />
              <Text style={styles.socialButtonText}>Continue with Google</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.socialButton, { backgroundColor: '#000000' }]}
              onPress={handleAppleLogin}
            >
              <Icon name="apple" size={24} color="#FFFFFF" />
              <Text style={styles.socialButtonText}>Continue with Apple</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.socialButton, { backgroundColor: '#1877F2' }]}
              onPress={handleFacebookLogin}
            >
              <Icon name="facebook" size={24} color="#FFFFFF" />
              <Text style={styles.socialButtonText}>Continue with Facebook</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.signupContainer}>
            <Text style={styles.signupText}>Don't have an account? </Text>
            <TouchableOpacity onPress={() => console.log('Sign up')}>
              <Text style={styles.signupLink}>Sign up</Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: ORANGE,
  },
  background: {
    flex: 1,
    backgroundColor: ORANGE,
  },
  backButton: {
    position: 'absolute',
    top: 48,
    left: 24,
    zIndex: 10,
    backgroundColor: 'rgba(0,0,0,0.08)',
    borderRadius: 20,
    padding: 6,
  },
  scrollContent: {
    flexGrow: 1,
    padding: 20,
    justifyContent: 'center',
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 40,
  },
  logoText: {
    fontSize: 48,
    fontWeight: 'bold',
    color: WHITE,
    marginBottom: 10,
    fontFamily: 'System',
  },
  tagline: {
    fontSize: 18,
    color: WHITE,
    opacity: 0.9,
    fontFamily: 'System',
  },
  formContainer: {
    marginBottom: 30,
  },
  input: {
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    borderRadius: 12,
    paddingHorizontal: 15,
    marginBottom: 15,
    color: '#333',
    fontSize: 16,
    fontFamily: 'System',
  },
  forgotPassword: {
    alignSelf: 'flex-end',
    marginBottom: 20,
  },
  forgotPasswordText: {
    color: WHITE,
    fontSize: 14,
    fontFamily: 'System',
  },
  emailLoginButton: {
    backgroundColor: '#E74C3C',
    borderRadius: 12,
    padding: 15,
    alignItems: 'center',
  },
  emailLoginButtonText: {
    color: '#FFF6E3',
    fontSize: 16,
    fontWeight: 'bold',
    fontFamily: 'System',
  },
  dividerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 20,
  },
  divider: {
    flex: 1,
    height: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
  },
  dividerText: {
    color: WHITE,
    marginHorizontal: 10,
    opacity: 0.8,
    fontFamily: 'System',
  },
  socialButtonsContainer: {
    gap: 15,
  },
  socialButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 10,
    padding: 15,
    gap: 10,
  },
  socialButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
    fontFamily: 'System',
  },
  signupContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 30,
  },
  signupText: {
    color: WHITE,
    fontSize: 14,
    fontFamily: 'System',
  },
  signupLink: {
    color: WHITE,
    fontSize: 14,
    fontWeight: 'bold',
    textDecorationLine: 'underline',
    fontFamily: 'System',
  },
});

export default LoginScreen; 