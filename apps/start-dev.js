#!/usr/bin/env node

const { spawn } = require('child_process');

// Set environment variables to reduce file watching
process.env.WATCHMAN_MAX_FILES = '100000';
process.env.WATCHMAN_MAX_DIRS = '10000';
process.env.METRO_MAX_WORKERS = '1';

// Start Metro with minimal options
const metro = spawn('npx', ['metro', 'start', '--reset-cache', '--max-workers', '1'], {
  stdio: 'inherit',
  env: {
    ...process.env,
    NODE_OPTIONS: '--max-old-space-size=4096'
  }
});

metro.on('error', (err) => {
  console.error('Failed to start Metro:', err);
  process.exit(1);
});

metro.on('close', (code) => {
  console.log(`Metro exited with code ${code}`);
  process.exit(code);
});
