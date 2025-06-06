// SurveyScreen.tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet, Button } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';

type RootStackParamList = {
  Home: undefined;
  Survey: undefined;
};

type SurveyScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Survey'>;

export default function SurveyScreen() {
  const navigation = useNavigation<SurveyScreenNavigationProp>();
  const [interest, setInterest] = useState('');

  const handleFinishSurvey = () => {
    // TODO: Save the interest in your app state or backend
    // Then navigate back or to another screen
    navigation.navigate('Home');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>What’s on your mind?</Text>
      {/* For demonstration, a single button or text that sets interest */}
      <Button
        title="I'm hungry for Mexican Food Trucks"
        onPress={() => setInterest('Mexican Food Trucks')}
      />
      <Button
        title="Finish Survey"
        onPress={handleFinishSurvey}
      />
      {interest ? <Text style={styles.selected}>Selected: {interest}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16
  },
  title: {
    fontSize: 24,
    marginBottom: 20
  },
  selected: {
    marginTop: 20,
    fontSize: 16,
    color: 'green'
  }
});
