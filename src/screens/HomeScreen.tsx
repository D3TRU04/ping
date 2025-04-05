// HomeScreen.tsx
import React from 'react';
import { View, Text, StyleSheet, Button } from 'react-native';
import { supabase } from '../../lib/supabase';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';

type RootStackParamList = {
  Home: undefined;
  SignIn: undefined;
};

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

export default function HomeScreen() {
  const navigation = useNavigation<HomeScreenNavigationProp>();

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    // Redirect to the SignIn screen after signing out
    navigation.navigate('SignIn');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.text}>Welcome to HomeScreen!</Text>
      <Button title="Sign Out" onPress={handleSignOut} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    fontSize: 24,
    marginBottom: 20,
  },
});
