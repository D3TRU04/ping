// SignupScreen.tsx
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
  Alert,
  Image,
} from 'react-native';
import { supabase } from '../../../lib/supabase';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Icon from 'react-native-vector-icons/MaterialIcons';

type RootStackParamList = {
  SignUp: undefined;
  Home: undefined;
  SignIn: undefined;
  Startup: undefined;
};

type SignUpScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'SignUp'>;

const ORANGE = '#FFA726';
const WHITE = '#FFFFFF';

export default function SignUpScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigation = useNavigation<SignUpScreenNavigationProp>();

  async function signUpWithEmail() {
    setLoading(true);
    // Sign up using email and password with Supabase Auth
    const { data: { session }, error } = await supabase.auth.signUp({
      email,
      password,
    });

    if (error) {
      Alert.alert('Error signing up', error.message);
    } else if (!session) {
      Alert.alert('Success!', 'Check your email for a confirmation link.');
      navigation.navigate('Home');
    }
    setLoading(false);
  }

async function signInWithOAuth(provider: 'google' | 'facebook' | 'azure') {
    const { error } = await supabase.auth.signInWithOAuth({ provider });
    if (error) {
      console.error(`Error with ${provider} sign in:`, error);
      Alert.alert(`Error with ${provider} sign in`, error.message);
    }
  }

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
          <Image source={require('../../assets/logo.png')} style={styles.logoImage}/>
          </View>

          <View style={styles.formContainer}>
            <View style={styles.inputContainer}>
              <Icon name="email" size={20} color="#666" style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Email"
                placeholderTextColor="#666"
        value={email}
        onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
              />
            </View>

            <View style={styles.inputContainer}>
              <Icon name="lock" size={20} color="#666" style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Password"
                placeholderTextColor="#666"
                value={password}
                onChangeText={setPassword}
        secureTextEntry
        autoCapitalize="none"
              />
            </View>

            <TouchableOpacity
              style={styles.signUpButton}
        onPress={signUpWithEmail}
        disabled={loading}
            >
              <Text style={styles.signUpButtonText}>
                {loading ? 'Creating Account...' : 'Create Account'}
              </Text>
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
        onPress={() => signInWithOAuth('google')}
            >
              <Icon name="g-translate" size={24} color="#FFFFFF" />
              <Text style={styles.socialButtonText}>Continue with Google</Text>
            </TouchableOpacity>

            {/* <TouchableOpacity
              style={[styles.socialButton, { backgroundColor: '#000000' }]}
              onPress={() => signInWithOAuth('azure')}
            >
              <Icon name="apple" size={24} color="#FFFFFF" />
              <Text style={styles.socialButtonText}>Continue with Apple</Text>
            </TouchableOpacity> */}

            <TouchableOpacity
              style={[styles.socialButton, { backgroundColor: '#1877F2' }]}
        onPress={() => signInWithOAuth('facebook')}
            >
              <Icon name="facebook" size={24} color="#FFFFFF" />
              <Text style={styles.socialButtonText}>Continue with Facebook</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.signinContainer}>
            <Text style={styles.signinText}>Already have an account? </Text>
            <TouchableOpacity onPress={() => navigation.navigate('SignIn')}>
              <Text style={styles.signinLink}>Sign in</Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
    </View>
    </KeyboardAvoidingView>
  );
}

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
    color: '#FFFFFF',
    marginBottom: 10,
    fontFamily: 'System',
  },
  tagline: {
    fontSize: 18,
    color: '#FFFFFF',
    opacity: 0.9,
    fontFamily: 'System',
  },
  formContainer: {
    marginBottom: 30,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    borderRadius: 12,
    marginBottom: 15,
    paddingHorizontal: 15,
  },
  inputIcon: {
    marginRight: 10,
  },
  input: {
    flex: 1,
    height: 50,
    color: '#333',
    fontSize: 16,
    fontFamily: 'System',
  },
  signUpButton: {
    backgroundColor: '#E74C3C',
    borderRadius: 12,
    padding: 15,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  signUpButtonText: {
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
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
  },
  dividerText: {
    color: '#FFFFFF',
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
    borderRadius: 12,
    padding: 15,
    gap: 10,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  socialButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
    fontFamily: 'System',
  },
  signinContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 30,
  },
  signinText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontFamily: 'System',
  },
  signinLink: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: 'bold',
    textDecorationLine: 'underline',
    fontFamily: 'System',
  },
  logoImage: {
    width: 250,
    height: 250,
    resizeMode: 'contain',
    marginBottom: 5,
  },
});
