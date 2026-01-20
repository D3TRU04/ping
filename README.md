# Ping

A location-based social discovery iOS app that helps users find places and connect with others who share similar interests.

## Overview

Ping combines social networking with place discovery, allowing users to find restaurants, shops, recreational venues, and other locations based on their preferences. Users can save places to collections, follow other users, and receive personalized recommendations.

## Features

### Home
- Personalized "For You" feed of place recommendations
- Daily curated suggestions on the "Today" page
- Save places to collections ("Want to Go", "Been There")
- Filter by category and subcategory

### Discover
- Interactive map showing nearby places
- Toggle between standard and satellite views
- Search for places and users
- View detailed place information with ratings and hours

### Profile
- Customizable user profiles
- Follower/following system
- Browse saved place collections
- View other users' public profiles

### Notifications
- Activity feed for follows and messages
- Configurable notification preferences

## Tech Stack

### Frontend
- **Framework**: SwiftUI
- **Language**: Swift
- **Architecture**: MVVM

### Backend
- **Database & API**: Convex (TypeScript)
- **Authentication**: Clerk
- **Maps**: MapKit with Mapbox integration

### Services
- Convex for real-time database and API
- Clerk for authentication and session management
- CoreLocation for location services

## Project Structure

```
ping-application/
├── ping-application/           # iOS app source
│   ├── Features/               # Feature modules
│   │   ├── Auth/               # Login, signup, onboarding
│   │   ├── Home/               # Feed and recommendations
│   │   ├── Discover/           # Map and search
│   │   ├── Profile/            # User profiles
│   │   ├── Notifications/      # Notification management
│   │   ├── Settings/           # App preferences
│   │   └── Friends/            # Social features
│   ├── Models/                 # Data models
│   ├── Services/               # API and business logic
│   ├── UI/                     # Reusable components
│   └── Config/                 # App configuration
│
├── convex-backend/             # Convex backend
│   └── convex/
│       ├── schema.ts           # Database schema
│       ├── users.ts            # User operations
│       ├── profiles.ts         # Profile queries
│       ├── places.ts           # Place queries
│       ├── collections.ts      # Collection management
│       └── notifications.ts    # Notifications
│
└── ping-application.xcodeproj/ # Xcode project
```

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Active Convex deployment
- Clerk account for authentication

## Configuration

The app requires the following keys in `Info.plist`:

- `CONVEX_URL`: Convex deployment URL
- `CLERK_PUBLISHABLE_KEY`: Clerk publishable key
- `MAPBOX_ACCESS_TOKEN`: Mapbox access token

## Getting Started

1. Clone the repository
2. Open `ping-application.xcodeproj` in Xcode
3. Configure the required API keys in `Info.plist`
4. Install Convex backend dependencies:
   ```bash
   cd convex-backend
   npm install
   ```
5. Deploy the Convex backend:
   ```bash
   npx convex dev
   ```
6. Build and run the iOS app in Xcode

## Architecture

### Authentication Flow
1. User authenticates via Clerk (email/phone with OTP)
2. Auth token stored securely in Keychain
3. App fetches user profile from Convex
4. Routes to onboarding or main app based on user state

### Data Flow
- Services layer handles all Convex API communication
- View models manage state and data fetching
- AppEnvironment provides shared services via SwiftUI environment
- Models use Codable for JSON serialization

## License

Private repository - All rights reserved
