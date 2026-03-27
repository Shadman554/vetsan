/// Application configuration
/// 
/// SECURITY NOTE: In production, these values should be loaded from:
/// 1. Environment variables (for CI/CD)
/// 2. google-services.json (for Android OAuth)
/// 3. Secure key management system
/// 
/// For now, they're here for development convenience but should be
/// moved to .gitignore'd files before making repository public.
class AppConfig {
  // Google OAuth Configuration
  // iOS Client ID - used for iOS authentication
  static const String googleClientIdIOS = 
      '589785529975-ptq1u21msf0kt6uora4ce6ojicic1p7t.apps.googleusercontent.com';
  
  // Web Application Client ID - used for Android backend authentication
  static const String googleServerClientId = 
      '926387769090-9rqg69tucg9d2rcas57n7lf9eqp03vkd.apps.googleusercontent.com';
  
  // API Configuration
  static const String apiBaseUrl = 'https://python-database.up.railway.app';
  
  // OneSignal Configuration
  static const String oneSignalAppId = 'c680a189-e57c-48b4-9ce8-b28d91dc5c58';
  
  // App Store URLs
  static const String androidStoreUrl = 
      'https://play.google.com/store/apps/details?id=com.shaduman.vetdictplus';
  static const String iosStoreUrl = 
      'https://apps.apple.com/us/app/vet-dict/id6680200091';
  
  // Privacy Policy
  static const String privacyPolicyUrl = 
      'https://python-database.up.railway.app/api/privacy-policy/';
  
  // Contact
  static const String contactEmail = 'shadmanothman59@gmail.com';
}
