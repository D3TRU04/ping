export type RootStackParamList = {
  // Core screens
  Loading: undefined;
  Startup: undefined;
  
  // Auth screens
  SignIn: undefined;
  Onboarding: undefined;
  
  // Main app screens
  Home: { currentUser: any };
  Discover: { currentUser: any };
  Post: undefined;
  Notifications: { currentUser: any };
  ProfileScreen: { currentUser: any };
  
  // Profile screens
  publicProfileScreen: undefined;
  SearchUsersScreen: undefined;
  
  // Settings screens
  AccountInfo: undefined;
  NotificationsSettings: undefined;
  PrivacySecurity: undefined;
  AppearanceSettings: undefined;
  AboutPing: undefined;
  
  // Chat screens
  Chat: { currentUser: any; groupChat: any };
  GroupChat: { currentUser: any; groupChat: any };
  CreateGroup: { currentUser: any };
  GroupMembersList: { currentUser: any; groupChat: any };
  
  // Other screens
  Results: undefined;
  Matchmaking: { currentUser: any };
  Today: { currentUser: any };
  Friends: { currentUser: any };
  Settings: { currentUser: any };
}; 