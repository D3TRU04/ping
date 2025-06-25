import { Platform, TextStyle } from 'react-native';

// Font family based on platform - using Satoshi
export const FONT_FAMILY = {
  regular: Platform.select({
    ios: 'Satoshi-Medium',
    android: 'Satoshi-Medium',
    default: 'Satoshi-Medium',
  }),
  medium: Platform.select({
    ios: 'Satoshi-Medium',
    android: 'Satoshi-Medium',
    default: 'Satoshi-Medium',
  }),
  bold: Platform.select({
    ios: 'Satoshi-Medium',
    android: 'Satoshi-Medium',
    default: 'Satoshi-Medium',
  }),
};

// Font sizes
export const FONT_SIZE = {
  xs: 12,
  sm: 14,
  base: 16,
  lg: 18,
  xl: 20,
  '2xl': 24,
  '3xl': 30,
  '4xl': 36,
};

// Font weights
export const FONT_WEIGHT: { [key: string]: TextStyle['fontWeight'] } = {
  regular: '400',
  medium: '500',
  semibold: '600',
  bold: '700',
  heavy: '800',
} as const;

// Line heights
export const LINE_HEIGHT = {
  tight: 1.2,
  normal: 1.5,
  relaxed: 1.75,
};

// Typography presets
export const TYPOGRAPHY = {
  h1: {
    fontFamily: FONT_FAMILY.medium,
    fontSize: FONT_SIZE['4xl'],
    fontWeight: '500' as TextStyle['fontWeight'],
    lineHeight: LINE_HEIGHT.tight * FONT_SIZE['4xl'],
  },
  h2: {
    fontFamily: FONT_FAMILY.medium,
    fontSize: FONT_SIZE['3xl'],
    fontWeight: '500' as TextStyle['fontWeight'],
    lineHeight: LINE_HEIGHT.tight * FONT_SIZE['3xl'],
  },
  h3: {
    fontFamily: FONT_FAMILY.medium,
    fontSize: FONT_SIZE['2xl'],
    fontWeight: '500' as TextStyle['fontWeight'],
    lineHeight: LINE_HEIGHT.tight * FONT_SIZE['2xl'],
  },
  body: {
    fontFamily: FONT_FAMILY.regular,
    fontSize: FONT_SIZE.base,
    fontWeight: '500' as TextStyle['fontWeight'],
    lineHeight: LINE_HEIGHT.normal * FONT_SIZE.base,
  },
  bodyBold: {
    fontFamily: FONT_FAMILY.medium,
    fontSize: FONT_SIZE.base,
    fontWeight: '500' as TextStyle['fontWeight'],
    lineHeight: LINE_HEIGHT.normal * FONT_SIZE.base,
  },
  caption: {
    fontFamily: FONT_FAMILY.regular,
    fontSize: FONT_SIZE.sm,
    fontWeight: '500' as TextStyle['fontWeight'],
    lineHeight: LINE_HEIGHT.normal * FONT_SIZE.sm,
  },
} as const; 