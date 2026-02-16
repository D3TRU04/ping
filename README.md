# Ping

A location-based social discovery iOS app that helps users find places and connect with others who share similar interests.

## Overview

Ping combines social networking with place discovery, allowing users to find restaurants, shops, recreational venues, and other locations based on their preferences. Users can save places to collections, create groups with friends to track common interests, follow other users, and receive personalized recommendations -- all through an interactive map-driven interface.

## Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | SwiftUI, Swift |
| **Architecture** | MVVM |
| **Backend** | Supabase (PostgreSQL + REST API) |
| **Authentication** | Clerk (email/phone OTP) |
| **Maps** | Mapbox GL |
| **Location** | CoreLocation |

## Features

### Home
- Personalized "For You" feed of place recommendations
- Daily curated suggestions on the "Today" page with category selection
- Matchmaking-based discovery
- Save places to collections ("Want to Go", "Been There")

### Discover
- Interactive Mapbox map showing nearby places
- Toggle between standard and satellite views
- Search for places and users
- View detailed place information with ratings and hours

### Profile
- Customizable user profiles with photo upload
- Follower/following system
- Browse saved place collections
- View other users' public profiles and account info

### Groups
- Create and manage groups with friends
- View common places across group members
- Group detail views with member management

### Notifications
- Activity feed for follows and messages
- Configurable notification preferences

### Settings
- App preferences and privacy settings
- Account management

## Project Structure

```
ping-application/
├── ping-application/               # iOS app source
│   ├── PingNativeApp.swift         # App entry point
│   ├── AppEnvironment.swift        # Dependency injection container
│   ├── RootView.swift              # Root navigation and tab structure
│   ├── Info.plist                  # App configuration (API keys)
│   │
│   ├── Config/                     # Configuration
│   │   ├── AppConfig.swift         # Loads keys from Info.plist
│   │   └── AppConfig.swift.example # Template for new developers
│   │
│   ├── Features/                   # Feature modules
│   │   ├── Auth/                   # Login, signup, OTP, onboarding
│   │   ├── Core/                   # Loading, startup, login modal
│   │   ├── Home/                   # Feed, "Today" page, matchmaking
│   │   ├── Discover/               # Mapbox map and search
│   │   ├── Profile/                # User profiles (own + public)
│   │   ├── Groups/                 # Group management
│   │   ├── Notifications/          # Notification feed
│   │   ├── Friends/                # User search / social
│   │   ├── Settings/               # Preferences, privacy, account
│   │   └── Map/                    # Legacy map screen
│   │
│   ├── Services/                   # Backend communication
│   │   ├── Supabase/               # Supabase REST services (primary)
│   │   │   ├── SupabaseClient.swift
│   │   │   ├── SupabaseAuthService.swift
│   │   │   ├── SupabaseUserService.swift
│   │   │   ├── SupabaseProfileService.swift
│   │   │   ├── SupabasePlacesService.swift
│   │   │   ├── SupabaseCollectionsService.swift
│   │   │   ├── SupabaseGroupsService.swift
│   │   │   ├── SupabaseNotificationsService.swift
│   │   │   ├── SupabaseTodayGameService.swift
│   │   │   └── ... (models and mutations)
│   │   ├── Protocols/              # Service interfaces
│   │   ├── Auth/                   # KeychainService
│   │   └── Map/                    # MapService (legacy)
│   │
│   ├── Models/                     # Data models
│   │   ├── User.swift
│   │   ├── Place.swift
│   │   ├── Notification.swift
│   │   └── Session.swift
│   │
│   ├── UI/                         # Reusable components
│   │   ├── Components/             # AppText, BottomNavBar, buttons
│   │   ├── Theme/                  # AppTheme, AppColors
│   │   └── Helpers/                # UI utilities
│   │
│   ├── Utilities/                  # General helpers
│   │   ├── ErrorHandler.swift
│   │   ├── FlowLayout.swift
│   │   ├── MasonryLayout.swift
│   │   ├── ImagePicker.swift
│   │   └── ScaleButtonStyle.swift
│   │
│   └── Assets.xcassets/            # Image assets and app icon
│
└── ping-application.xcodeproj/     # Xcode project
```

## Architecture

### MVVM + Service Layer

Each feature follows the MVVM pattern:

- **Views** -- SwiftUI views that observe their view model
- **View Models** -- `@Observable` or `@ObservableObject` classes that own feature state and call services
- **Services** -- protocol-backed classes that handle Supabase REST calls (e.g. `SupabasePlacesService`)

### Dependency Injection via AppEnvironment

`AppEnvironment` is an `ObservableObject` injected into the SwiftUI environment at the app root. It owns every service instance and exposes shared state like `isAuthenticated`, `currentUser`, and `needsOnboarding`. Features access it via `@EnvironmentObject`.

### Navigation

- The **auth flow** uses a `NavigationStack` with typed `NavigationDestination` values (signIn, signUp, onboarding)
- The **main app** uses a tab bar (`BottomNavBar`) with three tabs: Home, Discover, Notifications
- Home and Discover each maintain their own `NavigationPath` for push/pop navigation
- Profile is accessed via a floating `ProfileButtonIsland` that pushes onto the Home navigation stack

## Prerequisites

- Xcode 16+
- iOS 15.0+ deployment target
- A [Supabase](https://supabase.com) project
- A [Clerk](https://clerk.com) application (publishable key)
- A [Mapbox](https://www.mapbox.com) access token

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd ping-application
   ```

2. **Configure API keys** -- open `ping-application/Info.plist` and set the values for the keys listed in [Configuration](#configuration) below.

3. **Open in Xcode**
   ```
   open ping-application.xcodeproj
   ```

4. **Build and run** on a simulator or device (iOS 15+).

## Configuration

The app reads these keys from `Info.plist` at launch (via `AppConfig.load()`):

| Key | Description |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL (e.g. `https://<ref>.supabase.co/`) |
| `SUPABASE_ANON_KEY` | Supabase anonymous / public API key |
| `CLERK_PUBLISHABLE_KEY` | Clerk front-end publishable key |
| `MAPBOX_ACCESS_TOKEN` | Mapbox GL access token |

## Authentication Flow

1. User opens the app -- `PingNativeApp` configures Clerk with the publishable key and calls `clerk.load()`
2. `AppEnvironment.checkAuthStatus()` checks for an existing Clerk session
3. If authenticated, the app calls `userService.createOrUpdateFromClerk()` to sync the Clerk user to a Supabase profile
4. Auth tokens are stored securely via `KeychainService`
5. Based on state, the user is routed to:
   - **Onboarding** -- new users complete their profile (name, username, birthday, category preferences)
   - **Main app** -- returning users land on the Home tab

## Data Flow

```
View  -->  ViewModel  -->  Service (protocol)  -->  SupabaseClient  -->  Supabase REST API
 ^                              |
 |                              v
 +--- @Published state <--- Response models (Codable)
```

1. A **View** observes its **ViewModel** via `@StateObject` / `@EnvironmentObject`
2. The ViewModel calls a **Service** method (e.g. `placesService.getNearby()`)
3. The Service uses **SupabaseClient** to make an HTTP request to the Supabase REST API
4. The response is decoded into **Codable** model structs and returned to the ViewModel
5. The ViewModel updates its `@Published` properties, which triggers a SwiftUI view update

## Branching and Development Workflow

| Branch | Purpose |
|---|---|
| `main` | Production-ready code |
| `dev` | Integration branch for in-progress work |
| `feature/*` | Individual feature branches, branched from `dev` |

1. Create a feature branch from `dev` (e.g. `feature/group-invites`)
2. Open a pull request targeting `dev`
3. After review, merge into `dev`
4. Periodically merge `dev` into `main` for releases

## License

Private repository -- All rights reserved.
