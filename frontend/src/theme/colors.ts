export const COLORS = {
  // Primary colors
  coral: '#FF6B6B',
  sunnyYellow: '#FFD93D',
  nightPurple: '#6B4EFF',
  
  // UI elements
  background: '#FFFFFF',
  text: '#2D3436',
  textSecondary: '#636E72',
  cardBackground: '#F5F6FA',
  
  // Additional UI colors
  success: '#00B894',
  error: '#D63031',
  warning: '#FDCB6E',
  info: '#0984E3',
  
  // Card colors
  cardShadow: 'rgba(0, 0, 0, 0.1)',
  
  // Swipe indicators
  like: '#00B894',
  dislike: '#D63031',
};

export const GRADIENTS = {
  primary: [COLORS.coral, COLORS.sunnyYellow, COLORS.nightPurple],
  card: [COLORS.cardBackground, '#FFFFFF'],
  button: [COLORS.coral, COLORS.sunnyYellow],
};

export const SHADOWS = {
  card: {
    shadowColor: COLORS.cardShadow,
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  button: {
    shadowColor: COLORS.cardShadow,
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 3,
  },
}; 