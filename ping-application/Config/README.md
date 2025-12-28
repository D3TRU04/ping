# Configuration Setup

This directory contains the app configuration files with API keys and secrets.

## ⚠️ SECURITY NOTICE

**NEVER commit `AppConfig.swift` to Git!** This file is gitignored to protect your API keys.

## Setup Instructions

1. **Copy the template file:**
   ```bash
   cp AppConfig.swift.example AppConfig.swift
   ```

2. **Add your API keys** to `AppConfig.swift`:
   - Replace `YOUR_CONVEX_DEPLOYMENT_URL` with your Convex deployment URL (e.g., `https://your-deployment.convex.cloud`)
   - Replace `YOUR_MAPBOX_ACCESS_TOKEN` with your Mapbox access token
   - ~~Supabase keys (deprecated, will be removed)~~

3. **Verify the file is gitignored:**
   ```bash
   git status ping-application/Config/AppConfig.swift
   ```

   You should see: "Untracked files" or the file should not appear at all.

## Current API Keys

Your current `AppConfig.swift` contains:
- **Convex Deployment URL:** Your Convex backend URL
- **Mapbox Access Token:** (Secret token starting with "sk.")
- ~~**Supabase URL/Key:** (deprecated, being migrated to Convex)~~

⚠️ **The Mapbox token is a SECRET token** - it should never be committed to Git or exposed in client-side code!

## Alternative: Using Info.plist

You can also store your secrets in `Info.plist` by adding these keys:
- `CONVEX_DEPLOYMENT_URL`
- `MAPBOX_ACCESS_TOKEN`
- ~~`SUPABASE_URL` (deprecated)~~
- ~~`SUPABASE_ANON_KEY` (deprecated)~~

The `AppConfig.load()` method will automatically read from Info.plist if the keys are present.

## What's Gitignored?

The following files are automatically ignored by Git:
- `ping-application/Config/AppConfig.swift` ✓
- `Config.plist`
- `Secrets.plist`

## Team Setup

When a new developer joins:
1. They should copy `AppConfig.swift.example` to `AppConfig.swift`
2. Share the API keys securely (via password manager, secure messaging, etc.)
3. Never share keys via email or commit them to Git
