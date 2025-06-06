// @ts-check

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./App.{js,jsx,ts,tsx}",
    "./src/**/*.{js,jsx,ts,tsx}",
    "./app/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        coral: '#FF6B6B',
        text: '#333333',
        textSecondary: '#666666',
        cardBackground: '#FFFFFF',
        cardShadow: '#000000',
        sunnyYellow: '#FFD93D',
      },
    },
  },
  plugins: [],
}; 