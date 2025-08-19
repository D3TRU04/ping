// @ts-check

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./App.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        satoshi: ['Satoshi-Regular'],
        sans: ['Satoshi-Regular', 'ui-sans-serif', 'system-ui', 'sans-serif'],
      },
      colors: {
        mint: '#1FC9C3',
      },
    },
  },
  plugins: [],
}; 