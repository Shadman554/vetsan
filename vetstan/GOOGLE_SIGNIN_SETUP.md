# Google Sign-In Setup Guide for VetStan App

## Overview
Google Sign-In has been implemented in your VetStan app! Users can now login directly with their Google account.

## What's Been Added

### 1. AuthProvider Updates
- ✅ Added Google Sign-In functionality
- ✅ `signInWithGoogle()` method
- ✅ Backend integration for Google authentication
- ✅ Automatic registration for new Google users
- ✅ Google sign-out integration

### 2. Login Page Updates
- ✅ Beautiful Google Sign-In button with Kurdish text
- ✅ "یان" (Or) divider between regular login and Google login
- ✅ Error handling and success messages in Kurdish
- ✅ Loading states for Google authentication

### 3. UI Features
- ✅ Kurdish text: "چوونە ژوورەوە بە گووگڵ" (Sign in with Google)
- ✅ Professional button design with Google branding
- ✅ Fallback icon if Google logo image is missing
- ✅ RTL support for Kurdish text

## Required Setup Steps

### Step 1: Google Console Configuration
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials:
   - Application type: Android
   - Package name: `com.example.vetdict`
   - SHA-1 certificate fingerprint (get from your keystore)

### Step 2: Get SHA-1 Fingerprint
Run this command in your project directory:
```bash
cd android
./gradlew signingReport
```
Copy the SHA-1 fingerprint from the debug keystore.

### Step 3: Download google-services.json
1. Download the `google-services.json` file from Google Console
2. Place it in: `android/app/google-services.json`

### Step 4: Update Android Configuration
Add to `android/app/build.gradle` (if not already present):
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

Add to `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

### Step 5: Backend API Endpoints
Your backend needs these endpoints:
- `POST /api/auth/google-login` - For existing Google users
- `POST /api/auth/google-register` - For new Google users

Expected request format:
```json
{
  "email": "user@gmail.com",
  "google_id": "google_user_id",
  "name": "User Name",
  "username": "user",
  "photo_url": "https://..."
}
```

### Step 6: Add Google Logo (Optional)
1. Download Google logo from [Google Branding Guidelines](https://developers.google.com/identity/branding-guidelines)
2. Save as `assets/images/google_logo.png`
3. Size: 24x24 or 48x48 pixels (PNG with transparent background)

## How It Works

### User Flow
1. User taps "چوونە ژوورەوە بە گووگڵ" button
2. Google Sign-In dialog opens
3. User selects Google account
4. App receives Google user data
5. App tries to login with existing account
6. If no account exists, automatically registers new user
7. User is logged in and redirected to home page

### Backend Integration
- First attempts login with Google ID
- If login fails, registers new user with Google data
- Returns JWT token for authenticated sessions
- Supports both access and refresh tokens

## Testing
1. Build and run the app
2. Navigate to login page
3. Tap the Google Sign-In button
4. Complete Google authentication
5. Verify successful login

## Troubleshooting

### Common Issues
1. **Google Sign-In fails**: Check SHA-1 fingerprint and google-services.json
2. **Backend errors**: Ensure API endpoints are implemented
3. **Button not working**: Check AuthProvider integration
4. **No Google logo**: Add google_logo.png to assets/images/

### Debug Logs
Check console for these messages:
- "Starting Google Sign-In process..."
- "Google user signed in: email@gmail.com"
- "Google access token obtained"
- "Attempting Google authentication with backend..."

## Security Notes
- Google Sign-In uses OAuth 2.0 for secure authentication
- No passwords are stored for Google users
- JWT tokens are used for session management
- Google user data is handled according to privacy policies

## Next Steps
1. Complete Google Console setup
2. Add google-services.json file
3. Test Google Sign-In functionality
4. Update backend API endpoints if needed
5. Add Google logo image for better branding

The Google Sign-In implementation is complete and ready for production use once the setup steps are completed!
