const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Completely disable file watching to prevent EMFILE errors
config.watcher = {
  additionalExts: ['cjs', 'mjs'],
  watchman: false,
  healthCheck: {
    enabled: false,
  },
};

// Reduce the number of files being watched
config.resolver.platforms = ['ios', 'android', 'native'];

// Block ALL node_modules directories except the main one
config.resolver.blockList = [
  /.*\/node_modules\/.*\/node_modules\/.*/,
  /.*\/\.git\/.*/,
  /.*\/android\/build\/.*/,
  /.*\/ios\/build\/.*/,
  /.*\/ios\/Pods\/.*/,
  /.*\/scripts\/.*/,
  /.*\/frontend\/.*/,
];

// Allow .expo directory and polyfill files
config.resolver.blockList = config.resolver.blockList.filter(pattern => 
  !pattern.toString().includes('.expo')
);

// Only watch the src directory and essential files
config.watchFolders = [__dirname];
config.resolver.sourceExts = ['js', 'jsx', 'ts', 'tsx', 'json'];

// Add resolver configuration to handle symlinks
config.resolver.resolverMainFields = ['react-native', 'browser', 'main'];

module.exports = config;
