import React, { useState } from 'react';
import { View, TextInput, FlatList, Text, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { supabase } from '../../../../lib/supabase';
import { MaterialIcons as Icon } from '@expo/vector-icons';

type RootStackParamList = {
  publicProfileScreen: { userId: string };
};

type NavigationProp = StackNavigationProp<RootStackParamList, 'publicProfileScreen'>;

const SearchUsersScreen = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<any[]>([]);
  const navigation = useNavigation<NavigationProp>();

  const handleSearch = async () => {
    const { data, error } = await supabase
      .from('profiles')
      .select('id, username, full_name, profile_picture')
      .ilike('username', `%${query}%`);

    if (!error) setResults(data || []);
  };

  return (

    

    <View className="my-20">

        {/* Back Button */}
      <TouchableOpacity
        onPress={() => navigation.goBack()}
        className="mb-4 flex-row items-center"
      >
        <Icon name="arrow-back" size={24} color="#1FC9C3" />
        <Text className="ml-2 text-[#1FC9C3] text-base font-medium">Back</Text>
      </TouchableOpacity>

      
      <TextInput
        placeholder="Search by username"
        value={query}
        onChangeText={setQuery}
        onSubmitEditing={handleSearch}
        className="border border-gray-300 p-2 rounded mb-4"
      />
      <FlatList
        data={results}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <TouchableOpacity
            onPress={() => navigation.navigate('publicProfileScreen', { userId: item.id })}
            className="p-3 border-b border-gray-200"
          >
            <Text className="text-lg font-medium">@{item.username}</Text>
            <Text className="text-gray-500">{item.full_name}</Text>
          </TouchableOpacity>
        )}
      />


     
    </View>
  );
};

export default SearchUsersScreen;
