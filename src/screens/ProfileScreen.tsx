// import React from 'react';
// import {
//   View,
//   Text,
//   StyleSheet,
//   ScrollView,
//   Image,
//   TouchableOpacity,
//   Platform,
// } from 'react-native';
// import Icon from 'react-native-vector-icons/MaterialIcons';
// import { COLORS } from '../theme/colors';

// const ProfileScreen = () => {
//   const stats = [
//     { label: 'Matches', value: '24' },
//     { label: 'Saved', value: '12' },
//     { label: 'Reviews', value: '8' },
//   ];

//   const preferences = [
//     'Coffee Shops',
//     'Outdoor Activities',
//     'Live Music',
//     'Fine Dining',
//     'Art Galleries',
//   ];

//   return (
//     <ScrollView style={styles.container}>
//       <View style={styles.header}>
//         <View style={styles.profileImageContainer}>
//           <Image
//             source={{ uri: 'https://i.pravatar.cc/300' }}
//             style={styles.profileImage}
//           />
//           <TouchableOpacity style={styles.editButton}>
//             <Icon name="edit" size={20} color={COLORS.text} />
//           </TouchableOpacity>
//         </View>
//         <Text style={styles.name}>Alex Johnson</Text>
//         <Text style={styles.location}>San Francisco, CA</Text>
//       </View>

//       <View style={styles.statsContainer}>
//         {stats.map((stat, index) => (
//           <View key={index} style={styles.statItem}>
//             <Text style={styles.statValue}>{stat.value}</Text>
//             <Text style={styles.statLabel}>{stat.label}</Text>
//           </View>
//         ))}
//       </View>

//       <View style={styles.section}>
//         <Text style={styles.sectionTitle}>About Me</Text>
//         <Text style={styles.bio}>
//           Coffee enthusiast and adventure seeker. Always looking for new experiences
//           and hidden gems in the city. Love trying new restaurants and meeting new
//           people!
//         </Text>
//       </View>

//       <View style={styles.section}>
//         <Text style={styles.sectionTitle}>Preferences</Text>
//         <View style={styles.preferencesContainer}>
//           {preferences.map((pref, index) => (
//             <View key={index} style={styles.preferenceTag}>
//               <Text style={styles.preferenceText}>{pref}</Text>
//             </View>
//           ))}
//         </View>
//       </View>

//       <TouchableOpacity style={styles.settingsButton}>
//         <Icon name="settings" size={24} color={COLORS.text} />
//         <Text style={styles.settingsText}>Settings</Text>
//       </TouchableOpacity>
//     </ScrollView>
//   );
// };

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//     backgroundColor: COLORS.background,
//   },
//   header: {
//     alignItems: 'center',
//     paddingVertical: 30,
//   },
//   profileImageContainer: {
//     position: 'relative',
//     marginBottom: 15,
//   },
//   profileImage: {
//     width: 120,
//     height: 120,
//     borderRadius: 60,
//   },
//   editButton: {
//     position: 'absolute',
//     right: 0,
//     bottom: 0,
//     backgroundColor: COLORS.background,
//     padding: 8,
//     borderRadius: 20,
//     ...Platform.select({
//       ios: {
//         shadowColor: '#000',
//         shadowOffset: { width: 0, height: 2 },
//         shadowOpacity: 0.25,
//         shadowRadius: 3.84,
//       },
//       android: {
//         elevation: 5,
//       },
//     }),
//   },
//   name: {
//     fontSize: 24,
//     fontWeight: 'bold',
//     color: COLORS.text,
//     marginBottom: 5,
//   },
//   location: {
//     fontSize: 16,
//     color: COLORS.textSecondary,
//   },
//   statsContainer: {
//     flexDirection: 'row',
//     justifyContent: 'space-around',
//     paddingVertical: 20,
//     borderTopWidth: 1,
//     borderBottomWidth: 1,
//     borderColor: 'rgba(0, 0, 0, 0.1)',
//     marginHorizontal: 20,
//   },
//   statItem: {
//     alignItems: 'center',
//   },
//   statValue: {
//     fontSize: 20,
//     fontWeight: 'bold',
//     color: COLORS.coral,
//     marginBottom: 5,
//   },
//   statLabel: {
//     fontSize: 14,
//     color: COLORS.textSecondary,
//   },
//   section: {
//     padding: 20,
//   },
//   sectionTitle: {
//     fontSize: 18,
//     fontWeight: 'bold',
//     color: COLORS.text,
//     marginBottom: 10,
//   },
//   bio: {
//     fontSize: 16,
//     color: COLORS.text,
//     lineHeight: 24,
//   },
//   preferencesContainer: {
//     flexDirection: 'row',
//     flexWrap: 'wrap',
//     gap: 10,
//   },
//   preferenceTag: {
//     backgroundColor: 'rgba(255, 107, 107, 0.1)',
//     paddingHorizontal: 15,
//     paddingVertical: 8,
//     borderRadius: 20,
//   },
//   preferenceText: {
//     color: COLORS.coral,
//     fontSize: 14,
//   },
//   settingsButton: {
//     flexDirection: 'row',
//     alignItems: 'center',
//     justifyContent: 'center',
//     padding: 15,
//     marginHorizontal: 20,
//     marginVertical: 20,
//     backgroundColor: 'rgba(0, 0, 0, 0.05)',
//     borderRadius: 10,
//     gap: 10,
//   },
//   settingsText: {
//     fontSize: 16,
//     color: COLORS.text,
//     fontWeight: '500',
//   },
// });

// export default ProfileScreen; 

/* Login Screen  */
// import React, { useState } from 'react';
// import {
//   View,
//   Text,
//   StyleSheet,
//   TouchableOpacity,
//   TextInput,
//   KeyboardAvoidingView,
//   Platform,
//   ScrollView,
// } from 'react-native';
// import Icon from 'react-native-vector-icons/MaterialIcons';
// import { useNavigation } from '@react-navigation/native';
// import { StackNavigationProp } from '@react-navigation/stack';
// import { COLORS } from '../theme/colors';

// type RootStackParamList = {
//   Login: undefined;
//   Swipe: undefined;
// };

// type LoginScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Login'>;

// const LoginScreen = () => {
//   const [email, setEmail] = useState('');
//   const [password, setPassword] = useState('');
//   const navigation = useNavigation<LoginScreenNavigationProp>();

//   const handleEmailLogin = () => {
//     navigation.navigate('Swipe');
//   };

//   const handleGoogleLogin = () => {
//     navigation.navigate('Swipe');
//   };

//   const handleAppleLogin = () => {
//     navigation.navigate('Swipe');
//   };

//   const handleFacebookLogin = () => {
//     navigation.navigate('Swipe');
//   };

//   return (
//     <KeyboardAvoidingView
//       behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
//       style={styles.container}
//     >
//       <View style={styles.background}>
//         <ScrollView contentContainerStyle={styles.scrollContent}>
//           <View style={styles.logoContainer}>
//             <Text style={styles.logoText}>Ping!</Text>
//             <Text style={styles.tagline}>Find your perfect match</Text>
//           </View>

//           <View style={styles.formContainer}>
//             <TextInput
//               style={styles.input}
//               placeholder="Email"
//               placeholderTextColor={COLORS.text + '80'}
//               value={email}
//               onChangeText={setEmail}
//               keyboardType="email-address"
//               autoCapitalize="none"
//             />
//             <TextInput
//               style={styles.input}
//               placeholder="Password"
//               placeholderTextColor={COLORS.text + '80'}
//               value={password}
//               onChangeText={setPassword}
//               secureTextEntry
//             />
//             <TouchableOpacity
//               style={styles.forgotPassword}
//               onPress={() => console.log('Forgot password')}
//             >
//               <Text style={styles.forgotPasswordText}>Forgot Password?</Text>
//             </TouchableOpacity>
//             <TouchableOpacity
//               style={styles.emailLoginButton}
//               onPress={handleEmailLogin}
//             >
//               <Text style={styles.emailLoginButtonText}>Login with Email</Text>
//             </TouchableOpacity>
//           </View>

//           <View style={styles.dividerContainer}>
//             <View style={styles.divider} />
//             <Text style={styles.dividerText}>OR</Text>
//             <View style={styles.divider} />
//           </View>

//           <View style={styles.socialButtonsContainer}>
//             <TouchableOpacity
//               style={[styles.socialButton, { backgroundColor: '#4285F4' }]}
//               onPress={handleGoogleLogin}
//             >
//               <Icon name="g-translate" size={24} color="#FFFFFF" />
//               <Text style={styles.socialButtonText}>Continue with Google</Text>
//             </TouchableOpacity>

//             <TouchableOpacity
//               style={[styles.socialButton, { backgroundColor: '#000000' }]}
//               onPress={handleAppleLogin}
//             >
//               <Icon name="apple" size={24} color="#FFFFFF" />
//               <Text style={styles.socialButtonText}>Continue with Apple</Text>
//             </TouchableOpacity>

//             <TouchableOpacity
//               style={[styles.socialButton, { backgroundColor: '#1877F2' }]}
//               onPress={handleFacebookLogin}
//             >
//               <Icon name="facebook" size={24} color="#FFFFFF" />
//               <Text style={styles.socialButtonText}>Continue with Facebook</Text>
//             </TouchableOpacity>
//           </View>

//           <View style={styles.signupContainer}>
//             <Text style={styles.signupText}>Don't have an account? </Text>
//             <TouchableOpacity onPress={() => console.log('Sign up')}>
//               <Text style={styles.signupLink}>Sign up</Text>
//             </TouchableOpacity>
//           </View>
//         </ScrollView>
//       </View>
//     </KeyboardAvoidingView>
//   );
// };

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//   },
//   background: {
//     flex: 1,
//     backgroundColor: COLORS.coral,
//   },
//   scrollContent: {
//     flexGrow: 1,
//     padding: 20,
//     justifyContent: 'center',
//   },
//   logoContainer: {
//     alignItems: 'center',
//     marginBottom: 40,
//   },
//   logoText: {
//     fontSize: 48,
//     fontWeight: 'bold',
//     color: COLORS.text,
//     marginBottom: 10,
//   },
//   tagline: {
//     fontSize: 18,
//     color: COLORS.text,
//     opacity: 0.8,
//   },
//   formContainer: {
//     marginBottom: 30,
//   },
//   input: {
//     backgroundColor: 'rgba(255, 255, 255, 0.1)',
//     borderRadius: 10,
//     padding: 15,
//     marginBottom: 15,
//     color: COLORS.text,
//     fontSize: 16,
//   },
//   forgotPassword: {
//     alignSelf: 'flex-end',
//     marginBottom: 20,
//   },
//   forgotPasswordText: {
//     color: COLORS.text,
//     fontSize: 14,
//   },
//   emailLoginButton: {
//     backgroundColor: COLORS.nightPurple,
//     borderRadius: 10,
//     padding: 15,
//     alignItems: 'center',
//   },
//   emailLoginButtonText: {
//     color: '#FFFFFF',
//     fontSize: 16,
//     fontWeight: 'bold',
//   },
//   dividerContainer: {
//     flexDirection: 'row',
//     alignItems: 'center',
//     marginVertical: 20,
//   },
//   divider: {
//     flex: 1,
//     height: 1,
//     backgroundColor: 'rgba(255, 255, 255, 0.2)',
//   },
//   dividerText: {
//     color: COLORS.text,
//     marginHorizontal: 10,
//     opacity: 0.5,
//   },
//   socialButtonsContainer: {
//     gap: 15,
//   },
//   socialButton: {
//     flexDirection: 'row',
//     alignItems: 'center',
//     justifyContent: 'center',
//     borderRadius: 10,
//     padding: 15,
//     gap: 10,
//   },
//   socialButtonText: {
//     color: '#FFFFFF',
//     fontSize: 16,
//     fontWeight: 'bold',
//   },
//   signupContainer: {
//     flexDirection: 'row',
//     justifyContent: 'center',
//     marginTop: 30,
//   },
//   signupText: {
//     color: COLORS.text,
//     fontSize: 14,
//   },
//   signupLink: {
//     color: COLORS.nightPurple,
//     fontSize: 14,
//     fontWeight: 'bold',
//   },
// });

// export default LoginScreen; 


/* -------------------------------- */