import React from 'react';
import { Text, TextProps } from 'react-native';

const AppText: React.FC<TextProps> = ({ style, ...props }) => {
  return <Text style={[{ fontFamily: 'Satoshi-Medium' }, style]} {...props} />;
};

export default AppText; 