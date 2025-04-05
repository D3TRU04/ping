// SignInScreen.tsx
import React, { useState } from 'react';
import { Alert, StyleSheet, View } from 'react-native';
import { supabase } from '../../../lib/supabase';
import { Button, Input } from '@rneui/themed';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';

type RootStackParamList = {
  SignIn: undefined;
  Home: undefined;
};

type SignInScreenNavigationProp = StackNavigationProp<RootStackParamList, 'SignIn'>;

export default function SignInScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigation = useNavigation<SignInScreenNavigationProp>();

  async function signInWithEmail() {
    setLoading(true);
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) {
      Alert.alert('Error signing in', error.message);
    } else if (data.session) {
      // Sign in successful; navigate to HomeScreen.
      navigation.navigate('Home');
    }
    setLoading(false);
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
        title="Sign In"
        onPress={signInWithEmail}
        disabled={loading}
        loading={loading}
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
});
