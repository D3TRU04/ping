// // SignupScreen.tsx
// import React, { useState } from 'react';
// import {
//   View,
//   Text,
//   TouchableOpacity,
//   TextInput,
//   KeyboardAvoidingView,
//   Platform,
//   ScrollView,
//   Alert,
//   Image,
// } from 'react-native';
// import { supabase } from '../../../lib/supabase';
// import { useNavigation } from '@react-navigation/native';
// import { NativeStackNavigationProp } from '@react-navigation/native-stack';
// import Icon from 'react-native-vector-icons/MaterialIcons';
// import { styled } from 'nativewind';

// const StyledView = styled(View);
// const StyledText = styled(Text);
// const StyledTouchableOpacity = styled(TouchableOpacity);
// const StyledTextInput = styled(TextInput);
// const StyledScrollView = styled(ScrollView);
// const StyledImage = styled(Image);

// type RootStackParamList = {
//   SignupScreen: undefined;
//   Home: undefined;
//   SignIn: undefined;
//   Startup: undefined;
//   Onboarding: undefined;
// };

// type SignUpScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'SignupScreen'>;

// export default function SignUpScreen() {
//   const [email, setEmail] = useState('');
//   const [password, setPassword] = useState('');
//   const [loading, setLoading] = useState(false);
//   const [emailError, setEmailError] = useState<string | null>(null);
//   const [passwordError, setPasswordError] = useState<string | null>(null);
//   const navigation = useNavigation<SignUpScreenNavigationProp>();

//   // Password validation function
//   const validatePassword = (pw: string) => {
//     if (pw.length < 8) {
//       return 'Password must be at least 8 characters.';
//     }
//     if (!/[0-9]/.test(pw)) {
//       return 'Password must contain at least one number.';
//     }
//     if (!/[A-Za-z]/.test(pw)) {
//       return 'Password must contain at least one letter.';
//     }
//     return null;
//   };

//   // async function checkEmailExists(email: string) {
//   //   // ... logic to check if email exists in Supabase ...
//   // }

//   async function signUpWithEmail() {
//     setLoading(true);
//     // Commented out email existence pre-check
//     // const emailExists = await checkEmailExists(email);
//     // if (emailExists) {
//     //   setEmailError('This email is already registered. Please sign in instead.');
//     //   setLoading(false);
//     //   return;
//     // }
//     try {
//       const { data: { session }, error } = await supabase.auth.signUp({
//         email,
//         password,
//         options: {
//           emailRedirectTo: 'ping://onboarding',
//         },
//       });

//       if (error) {
//         // Commented out email already used error handling
//         // if (error.message.toLowerCase().includes('already registered')) {
//         //   setEmailError('This email is already registered. Please sign in instead.');
//         // } else {
//           Alert.alert('Error signing up', error.message);
//         // }
//       } else {
//         // Alert.alert(
//         //   'Verification Email Sent',
//         //   'Please check your email to verify your account. After verification, you will be redirected to complete your profile.',
//         //   [
//         //     {
//         //       text: 'OK',
//         //       onPress: () => navigation.navigate('Onboarding'),
//         //     },
//         //   ]
//         // );
//         navigation.navigate('Onboarding');
//       }
//     } catch (error) {
//       Alert.alert('Error', 'An unexpected error occurred');
//     } finally {
//       setLoading(false);
//     }
//   }

//   async function signInWithOAuth(provider: 'google' | 'facebook' | 'azure') {
//     try {
//       const { error } = await supabase.auth.signInWithOAuth({
//         provider,
//         options: {
//           redirectTo: 'ping://onboarding',
//         },
//       });
//       if (error) {
//         console.error(`Error with ${provider} sign in:`, error);
//         Alert.alert(`Error with ${provider} sign in`, error.message);
//       }
//     } catch (error) {
//       console.error('Error:', error);
//       Alert.alert('Error', 'An unexpected error occurred');
//     }
//   }

//   return (
//     <KeyboardAvoidingView
//       behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
//       style={{ flex: 1, backgroundColor: '#FF5C5C' }}
//     >
//       <StyledView className="flex-1 bg-[#FF5C5C]">
//         <StyledTouchableOpacity 
//           className="absolute top-12 left-6 z-10 bg-black/8 rounded-full p-1.5"
//           onPress={() => navigation.navigate('Startup')}
//         >
//           <Icon name="arrow-back" size={28} color="#FFFFFF" />
//         </StyledTouchableOpacity>
//         {/* Error Alert - absolutely positioned below logo with overlay */}
//         {(emailError || passwordError) && (
//           <>
//             {/* Overlay to catch taps anywhere on the screen */}
//             <StyledTouchableOpacity
//               className="absolute left-0 right-0 top-0 bottom-0 z-10"
//               style={{ backgroundColor: 'transparent' }}
//               activeOpacity={1}
//               onPress={() => { setEmailError(null); setPasswordError(null); }}
//             />
//             <StyledView className="absolute left-4 right-4 z-20" style={{ top: 320 }}>
//               <StyledView className="bg-red-100 border border-red-400 rounded-xl p-3 shadow-lg">
//                 <StyledView className="flex-row items-start justify-between">
//                   <StyledView className="flex-row items-start flex-1 mr-2">
//                     <Icon name="error-outline" size={18} color="#DC2626" style={{ marginRight: 8, marginTop: 2 }} />
//                     <StyledText className="text-red-700 text-sm flex-1 leading-5">
//                       {emailError || passwordError}
//                     </StyledText>
//                   </StyledView>
//                   <StyledTouchableOpacity 
//                     onPress={() => { setEmailError(null); setPasswordError(null); }}
//                     className="p-1"
//                   >
//                     <Icon name="close" size={18} color="#DC2626" />
//                   </StyledTouchableOpacity>
//                 </StyledView>
//                 {emailError && (
//                   <StyledTouchableOpacity 
//                     className="mt-2 ml-6"
//                     onPress={() => navigation.navigate('SignIn')}
//                   >
//                     <StyledText className="text-red-700 text-sm font-bold">
//                       Go to Sign In →
//                     </StyledText>
//                   </StyledTouchableOpacity>
//                 )}
//               </StyledView>
//             </StyledView>
//           </>
//         )}

//         <StyledScrollView
//           className=""
//           contentContainerStyle={{ flex: 1, justifyContent: 'center', paddingHorizontal: 20 }}
//         >
//           <StyledView className="items-center mb-10">
//             <StyledImage 
//               source={require('../../assets/logo.png')} 
//               className="w-[250px] h-[250px] mb-1"
//               resizeMode="contain"
//             />
//           </StyledView>

//           <StyledView className="mb-8">
//             <StyledView className="flex-row items-center bg-white/90 rounded-xl mb-4 px-4">
//               <Icon name="email" size={20} color="#666" style={{ marginRight: 10 }} />
//               <StyledTextInput
//                 className="flex-1 h-[50px] text-gray-800 text-base"
//                 placeholder="Email"
//                 placeholderTextColor="#666"
//                 value={email}
//                 onChangeText={(text) => {
//                   setEmail(text);
//                   setEmailError(null);
//                 }}
//                 keyboardType="email-address"
//                 autoCapitalize="none"
//               />
//             </StyledView>

//             <StyledView className="flex-row items-center bg-white/90 rounded-xl mb-4 px-4">
//               <Icon name="lock" size={20} color="#666" style={{ marginRight: 10 }} />
//               <StyledTextInput
//                 className="flex-1 h-[50px] text-gray-800 text-base"
//                 placeholder="Password"
//                 placeholderTextColor="#666"
//                 value={password}
//                 onChangeText={text => {
//                   setPassword(text);
//                   setPasswordError(null);
//                 }}
//                 secureTextEntry
//                 autoCapitalize="none"
//               />
//             </StyledView>

//             <StyledTouchableOpacity
//               className="bg-[white] rounded-xl p-4 items-center shadow-lg"
//               onPress={signUpWithEmail}
//               disabled={loading}
//             >
//               <StyledText className="text-[#FFF6E3] text-base font-bold">
//                 {loading ? 'Creating Account...' : 'Create Account'}
//               </StyledText>
//             </StyledTouchableOpacity>
//           </StyledView>

//           <StyledView className="flex-row items-center my-5">
//             <StyledView className="flex-1 h-[1px] bg-white/30" />
//             <StyledText className="text-white mx-2.5 opacity-80">OR</StyledText>
//             <StyledView className="flex-1 h-[1px] bg-white/30" />
//           </StyledView>

//           <StyledView className="space-y-4">
//             <StyledTouchableOpacity
//               className="flex-row items-center justify-center bg-[#4285F4] rounded-xl p-4 shadow-lg"
//               onPress={() => signInWithOAuth('google')}
//             >
//               <Icon name="g-translate" size={24} color="#FFFFFF" />
//               <StyledText className="text-white text-base font-bold ml-2.5">Continue with Google</StyledText>
//             </StyledTouchableOpacity>

//             <StyledTouchableOpacity
//               className="flex-row items-center justify-center bg-[#1877F2] rounded-xl p-4 shadow-lg"
//               onPress={() => signInWithOAuth('facebook')}
//             >
//               <Icon name="facebook" size={24} color="#FFFFFF" />
//               <StyledText className="text-white text-base font-bold ml-2.5">Continue with Facebook</StyledText>
//             </StyledTouchableOpacity>
//           </StyledView>

//           <StyledView className="flex-row justify-center mt-8">
//             <StyledText className="text-white text-sm">Already have an account? </StyledText>
//             <StyledTouchableOpacity onPress={() => navigation.navigate('SignIn')}>
//               <StyledText className="text-white text-sm font-bold underline">Sign in</StyledText>
//             </StyledTouchableOpacity>
//           </StyledView>
//         </StyledScrollView>
//       </StyledView>
//     </KeyboardAvoidingView>
//   );
// }

// SignupScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
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
import { styled } from 'nativewind';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledTextInput = styled(TextInput);
const StyledScrollView = styled(ScrollView);
const StyledImage = styled(Image);

type RootStackParamList = {
  SignupScreen: undefined;
  Home: undefined;
  SignIn: undefined;
  Startup: undefined;
  Onboarding: undefined;
};

type SignUpScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'SignupScreen'>;

export default function SignUpScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigation = useNavigation<SignUpScreenNavigationProp>();

  async function signUpWithEmail() {
    setLoading(true);
    try {
      const { data: { session }, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: 'ping://onboarding',
        },
      });

      if (error) {
        Alert.alert('Error signing up', error.message);
      } else {
        // Alert.alert(
        //   'Verification Email Sent',
        //   'Please check your email to verify your account. After verification, you will be redirected to complete your profile.',
        //   [
        //     {
        //       text: 'OK',
        //       onPress: () => navigation.navigate('Startup'),
        //     },
        //   ]
        // );
        navigation.navigate('Onboarding');
      }
    } catch (error) {
      console.error('Error:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  }

  async function signInWithOAuth(provider: 'google' | 'facebook' | 'azure') {
    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider,
        options: {
          redirectTo: 'ping://onboarding',
        },
      });
      if (error) {
        console.error(`Error with ${provider} sign in:`, error);
        Alert.alert(`Error with ${provider} sign in`, error.message);
      }
    } catch (error) {
      console.error('Error:', error);
      Alert.alert('Error', 'An unexpected error occurred');
    }
  }

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1, backgroundColor: '#1FC9C3' }}
    >
      <StyledView className="flex-1 bg-[#1FC9C3]">
        <StyledTouchableOpacity 
          className="absolute top-12 left-6 z-10 bg-black/8 rounded-full p-1.5"
          onPress={() => navigation.navigate('Startup')}
        >
          <Icon name="arrow-back" size={28} color="#FFFFFF" />
        </StyledTouchableOpacity>

        <StyledScrollView
          className=""
          contentContainerStyle={{ flex: 1, justifyContent: 'center', paddingHorizontal: 20 }}
        >
          <StyledView className="items-center mb-10">
            <StyledImage 
              source={require('../../assets/logo.png')} 
              className="w-[250px] h-[250px] mb-1"
              resizeMode="contain"
            />
          </StyledView>

          <StyledView className="mb-8">
            <StyledView className="flex-row items-center bg-white/90 rounded-xl mb-4 px-4">
              <Icon name="email" size={20} color="#666" style={{ marginRight: 10 }} />
              <StyledTextInput
                className="flex-1 h-[50px] text-gray-800 text-base"
                placeholder="Email"
                placeholderTextColor="#666"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
              />
            </StyledView>

            <StyledView className="flex-row items-center bg-white/90 rounded-xl mb-4 px-4">
              <Icon name="lock" size={20} color="#666" style={{ marginRight: 10 }} />
              <StyledTextInput
                className="flex-1 h-[50px] text-gray-800 text-base"
                placeholder="Password"
                placeholderTextColor="#666"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
                autoCapitalize="none"
              />
            </StyledView>

            <StyledTouchableOpacity
              className="bg-white rounded-xl p-4 items-center shadow-lg"
              onPress={signUpWithEmail}
              disabled={loading}
            >
              <StyledText className="text-[#1FC9C3] text-base font-bold">
                {loading ? 'Creating Account...' : 'Create Account'}
              </StyledText>
            </StyledTouchableOpacity>
          </StyledView>

          <StyledView className="flex-row items-center my-5">
            <StyledView className="flex-1 h-[1px] bg-white/30" />
            <StyledText className="text-white mx-2.5 opacity-80">OR</StyledText>
            <StyledView className="flex-1 h-[1px] bg-white/30" />
          </StyledView>

          <StyledView className="space-y-4">
            <StyledTouchableOpacity
              className="flex-row items-center justify-center bg-[#4285F4] rounded-xl p-4 shadow-lg"
              onPress={() => signInWithOAuth('google')}
            >
              <Icon name="g-translate" size={24} color="#FFFFFF" />
              <StyledText className="text-white text-base font-bold ml-2.5">Continue with Google</StyledText>
            </StyledTouchableOpacity>

            <StyledTouchableOpacity
              className="flex-row items-center justify-center bg-[#1877F2] rounded-xl p-4 shadow-lg"
              onPress={() => signInWithOAuth('facebook')}
            >
              <Icon name="facebook" size={24} color="#FFFFFF" />
              <StyledText className="text-white text-base font-bold ml-2.5">Continue with Facebook</StyledText>
            </StyledTouchableOpacity>
          </StyledView>

          <StyledView className="flex-row justify-center mt-8">
            <StyledText className="text-white text-sm">Already have an account? </StyledText>
            <StyledTouchableOpacity onPress={() => navigation.navigate('SignIn')}>
              <StyledText className="text-white text-sm font-bold underline">Sign in</StyledText>
            </StyledTouchableOpacity>
          </StyledView>
        </StyledScrollView>
      </StyledView>
    </KeyboardAvoidingView>
  );
}