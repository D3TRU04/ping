import React from 'react';
import { View, StyleSheet } from 'react-native';
import { styled } from 'nativewind';
import BottomNavBar from './navbar/BottomNavBar';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

const StyledView = styled(View);
const StyledSafeAreaView = styled(SafeAreaView);

interface ScreenLayoutProps {
  children: React.ReactNode;
}

const ScreenLayout: React.FC<ScreenLayoutProps> = ({ children }) => {
  const insets = useSafeAreaInsets();
  
  return (
    <StyledView style={styles.container}>
      <StyledSafeAreaView edges={['top']} style={styles.content}>
        <StyledView 
          style={[
            styles.innerContent,
            {
              paddingBottom: 64 + insets.bottom, // NavBar height (64) + bottom inset
            }
          ]}
        >
          {children}
        </StyledView>
      </StyledSafeAreaView>
      <BottomNavBar />
    </StyledView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    flex: 1,
  },
  innerContent: {
    flex: 1,
  },
});

export default ScreenLayout; 