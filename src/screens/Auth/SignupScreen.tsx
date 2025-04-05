// SignupScreen.tsx
import React, { useState } from 'react';
import { Alert, StyleSheet, View } from 'react-native';
import { supabase } from '../../../lib/supabase';
import { Button, Input } from '@rneui/themed';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';

type RootStackParamList = {
  Signup: undefined;
  Home: undefined;
};

type SignupScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Signup'>;

export default function SignupScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigation = useNavigation<SignupScreenNavigationProp>();

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

//   async function signInWithOAuth(provider: 'google' | 'facebook' | 'azure') {
//     // Trigger the OAuth flow for the specified provider
//     const { error } = await supabase.auth.signInWithOAuth({ provider });
//     if (error) {
//       console.error('Error with ${provider} sign in:`, error);
//       Alert.alert(`Error with ${provider} sign in`, error.message);
//     }
//   }

async function signInWithOAuth(provider: 'google' | 'facebook' | 'azure') {
    const { error } = await supabase.auth.signInWithOAuth({ provider });
    if (error) {
      console.error(`Error with ${provider} sign in:`, error);
      Alert.alert(`Error with ${provider} sign in`, error.message);
    }
  }

  return (
    <View style={styles.container}>
      <Input
        label="Email"
        placeholder="Enter your email"
        autoCapitalize="none"
        value={email}
        onChangeText={setEmail}
      />
      <Input
        label="Password"
        placeholder="Enter your password"
        secureTextEntry
        autoCapitalize="none"
        value={password}
        onChangeText={setPassword}
      />
      <Button
        title="Sign Up with Email"
        onPress={signUpWithEmail}
        disabled={loading}
        loading={loading}
        containerStyle={styles.buttonContainer}
      />
      <Button
        title="Sign Up with Google"
        onPress={() => signInWithOAuth('google')}
        disabled={loading}
        containerStyle={styles.buttonContainer}
      />
      <Button
        title="Sign Up with Facebook"
        onPress={() => signInWithOAuth('facebook')}
        disabled={loading}
        containerStyle={styles.buttonContainer}
      />
      <Button
        title="Sign Up with Microsoft"
        onPress={() => signInWithOAuth('azure')}
        disabled={loading}
        containerStyle={styles.buttonContainer}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: 40,
    padding: 12,
  },
  buttonContainer: {
    marginVertical: 5,
  },
});
