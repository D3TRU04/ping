# Ping

Ping is a social discovery platform for finding and sharing local places and events. 

## About
This app helps people discover new places in their city and connect with others around shared interests. Users can browse events, save places, and share recommendations with their network.

## Features
- Home screen with event and place discovery
- User authentication and profiles
- Event and place cards with details
- Navigation between different sections
- Real-time data from Supabase backend
- Cross-platform mobile support

## Tech Stack
- React Native with Expo
- NativeWind for styling
- Supabase for backend services
- React Navigation for routing
- TypeScript

## Getting Started

1. Clone the repository
```sh
git clone https://github.com/your-username/ping-app.git
cd ping-app
```

2. Install dependencies
```sh
npm install
```

3. Start the development server
```sh
npm run start
```

4. Run on device
Use Expo Go on your phone or run in a simulator.

## Development

### Branching
- `main` - stable releases
- `development` - active development

### Workflow
1. Create feature branches from `development`
2. Make changes and commit
3. Open pull request to `development`
4. Merge to `main` for releases

## Project Structure
```
frontend/
  src/
    components/
    screens/
      auth/
        signin/page.tsx
        signup/page.tsx
        onboarding/page.tsx
      chat/page.tsx
      core/
        loading/page.tsx
        startup/page.tsx
      discover/page.tsx
      home/page.tsx
      notifications/page.tsx
      profile/
        main/page.tsx
        edit/page.tsx
        settings/page.tsx
      results/page.tsx
    assets/
  App.tsx
  ...
backend/
  api_calls.py
  ...
README.md
```

## Contributing

Open issues for bugs or feature requests. Pull requests are welcome. 