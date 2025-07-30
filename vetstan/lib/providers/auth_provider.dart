import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isSignedIn = false;
  bool _isLoading = false;
  String? _token;
  String? _refreshToken;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Map<String, dynamic>? get user => _user;
  bool get isSignedIn => _isSignedIn;
  bool get isLoading => _isLoading;
  String? get token => _token;
  GoogleSignIn get googleSignIn => _googleSignIn;

  // API Base URL
  static const String baseUrl = 'https://python-database-production.up.railway.app';

  AuthProvider() {
    _checkSignInStatus();
  }

  // Check if user is already signed in
  Future<void> _checkSignInStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final refreshToken = prefs.getString('refreshToken');
      // Load cached user data (including photo URL) if available so UI can display it immediately
      final cachedUserJson = prefs.getString('userData');
      if (cachedUserJson != null) {
        try {
          _user = jsonDecode(cachedUserJson);
        } catch (e) {
          // If decoding fails, clear corrupted data
          print('Warning: Failed to decode cached userData: $e');
          await prefs.remove('userData');
        }
      }
      
      if (token != null) {
        _token = token;
        _refreshToken = refreshToken; // Can be null
        
        // Try to get current user info
        final success = await _getCurrentUser();
        if (success) {
          _isSignedIn = true;
        } else {
          // Try to refresh token only if refresh token exists
          if (_refreshToken != null) {
            final refreshSuccess = await _refreshAccessToken();
            if (refreshSuccess) {
              _isSignedIn = true;
              await _getCurrentUser();
            } else {
              // Clear invalid tokens
              await _clearTokens();
            }
          } else {
            // No refresh token, clear tokens
            await _clearTokens();
          }
        }
      }
    } catch (e) {
      print('Error checking sign in status: $e');
      await _clearTokens();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? photoUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Attempting to register user: $email');
      
      // Prepare request body with required username field
      final requestBody = {
        'name': name,
        'username': email.split('@')[0], // Generate username from email
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (photoUrl != null) 'avatar': photoUrl,
      };
      
      print('Sending registration request to: $baseUrl/api/auth/register');
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'), // Registration endpoint
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Try to parse response
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        print('Failed to parse response: $e');
        throw Exception('Invalid server response format');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Registration successful, attempting to login...');
        // Registration successful, now login
        _isLoading = false;
        notifyListeners();
        return await login(email: email, password: password);
      } else {
        String errorMessage = 'Registration failed';
        if (data['message'] != null) {
          errorMessage = data['message'].toString();
        } else if (data['error'] != null) {
          errorMessage = data['error'].toString();
        }
        
        print('Registration failed: $errorMessage');
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': errorMessage,
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e, stackTrace) {
      print('Error during registration:');
      print(e);
      print(stackTrace);
      
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error during registration: ${e.toString()}',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Attempting to login user: $email');
      // For login, we'll use the part before @ as username
      final username = email.split('@')[0];
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'username': username,  // Add username field
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['access'] ?? data['access_token'];  // Support both formats
        _refreshToken = data['refresh'] ?? data['refresh_token'];  // Support both formats
        _isSignedIn = true;

        print('Login successful, token received');
        print('Access token: ${_token?.substring(0, 10)}...');
        print('Refresh token: ${_refreshToken?.substring(0, 10)}...');
        
        // Get user information using the token
        print('Attempting to get user info from API...');
        final userInfoSuccess = await _getCurrentUser();
        
        if (!userInfoSuccess) {
          print('API user info failed, using fallback data');
          // If we can't get user info, create a basic user object with email
          _user = {
            'email': email,
            'name': email.split('@')[0], // Use part before @ as name
            'username': email.split('@')[0],
          };
        }
        
        print('Final user info: $_user');
        
        // Ensure user data is saved
        if (_user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userData', jsonEncode(_user));
        }

        // Save tokens to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        if (_refreshToken != null) {
          await prefs.setString('refreshToken', _refreshToken!);
        }
        await prefs.setString('userData', jsonEncode(_user));

        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': 'Login successful',
          'user': _user,
        };
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Login with username instead of email (used after registration)
  Future<Map<String, dynamic>> _loginWithUsername({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Attempting to login with username: $username');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['access'] ?? data['access_token'];  // Support both formats
        _refreshToken = data['refresh'] ?? data['refresh_token'];  // Support both formats
        _isSignedIn = true;

        print('Login successful, token received');
        print('Access token: ${_token?.substring(0, 10)}...');
        print('Refresh token: ${_refreshToken?.substring(0, 10)}...');
        
        // Get user information using the token
        print('Attempting to get user info from API...');
        final userInfoSuccess = await _getCurrentUser();
        
        if (!userInfoSuccess) {
          print('API user info failed, using fallback data');
          // If we can't get user info, create a basic user object with username
          _user = {
            'username': username,
            'name': username,
          };
        }
        
        print('Final user info: $_user');
        
        // Ensure user data is saved
        if (_user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userData', jsonEncode(_user));
        }

        // Save tokens to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        if (_refreshToken != null) {
          await prefs.setString('refreshToken', _refreshToken!);
        }
        await prefs.setString('userData', jsonEncode(_user));

        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': 'Login successful',
          'user': _user,
        };
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get current user info
  Future<bool> _getCurrentUser() async {
    if (_token == null) {
      print('No token available for user info request');
      return false;
    }

    try {
      print('Making request to $baseUrl/api/auth/me');
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('User info response status: ${response.statusCode}');
      print('User info response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Preserve existing avatar/photo_url if the server response lacks them
        final newUser = Map<String, dynamic>.from(data['user'] ?? data);
        if ((newUser['avatar'] == null && newUser['photo_url'] == null) && _user != null) {
          newUser['avatar'] = _user!['avatar'] ?? _user!['photo_url'];
          newUser['photo_url'] = newUser['photo_url'] ?? _user!['photo_url'];
        }
        _user = newUser;
        print('User data from API (merged): $_user');
        
        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(_user));
        
        return true;
      } else {
        print('Failed to get user info, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return false;
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        if (data['refresh_token'] != null) {
          _refreshToken = data['refresh_token'];
        }

        // Save new tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        if (_refreshToken != null) {
          await prefs.setString('refreshToken', _refreshToken!);
        }

        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return false;
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token != null) {
        // Call logout API
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      print('Error during logout API call: $e');
    }

    // Sign out from Google as well
    try {
      await _googleSignIn.signOut();
      print('✅ Signed out from Google');
    } catch (e) {
      print('Warning: Could not sign out from Google: $e');
    }
    
    // Clear local data regardless of API call result
    await _clearTokens();
    _user = null;
    _isSignedIn = false;

    _isLoading = false;
    notifyListeners();
  }

  // Clear tokens and user data
  Future<void> _clearTokens() async {
    _token = null;
    _refreshToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('userData');
  }

  // Get user display name
  String get userDisplayName {
    if (_user != null) {
      return _user!['username'] ?? _user!['name'] ?? _user!['email'] ?? 'User';
    }
    return 'User';
  }

  // Get user email
  String get userEmail {
    if (_user != null) {
      return _user!['email'] ?? '';
    }
    return '';
  }

  // Get user photo URL
  String? get userPhotoUrl {
    if (_user != null) {
      return _user!['avatar'] ?? _user!['photo_url'];
    }
    return null;
  }

  // UPDATED: Fixed Google Sign-In Flow - Login First, Then Register
  Future<Map<String, dynamic>> _registerOrLoginWithGoogle({
    required String email,
    required String name,
    required String googleId,
    required String googleToken,
    String? photoUrl,
  }) async {
    print('\n🔄 === STARTING GOOGLE LOGIN/REGISTRATION PROCESS ===');
    print('📧 Email: $email');
    print('👤 Name: $name');
    print('🆔 Google ID: $googleId');
    print('🖼️ Photo URL: $photoUrl');
    print('🌐 Base URL: $baseUrl');
    print('================================================\n');

    // STEP 1: Try Google-specific login endpoint first (for existing Google users)
  print('🔑 STEP 1: Attempting Google login endpoint...');

  final googleLoginResult = await _loginWithGoogleEndpoint(
    email: email,
    name: name,
    googleId: googleId,
    googleToken: googleToken,
    photoUrl: photoUrl,
  );

  if (googleLoginResult['success'] == true) {
    print('✅ Logged in via Google endpoint!');
    return googleLoginResult;
  }

  // STEP 2: If Google login failed, try Google registration endpoint (for first-time Google users)
  print('🟡 STEP 2: Attempting Google registration endpoint...');
  final googleRegisterResult = await _registerWithGoogleEndpoint(
    email: email,
    name: name,
    googleId: googleId,
    googleToken: googleToken,
    photoUrl: photoUrl,
  );

  if (googleRegisterResult['success'] == true) {
    print('✅ Registered & logged in via Google endpoint!');
    return googleRegisterResult;
  }

  // STEP 3: Try regular email/password login as fallback (handles legacy accounts created with Google ID as password)
  print('🔄 STEP 3: Attempting regular login with email...');
    print('🔑 STEP 1: Attempting regular login with email...');
    
    // First, let's try to login with email and googleId as password
    // This handles users who registered via Google before
    final regularLoginResult = await login(
      email: email,
      password: googleId, // Using Google ID as password for consistency
    );

    if (regularLoginResult['success'] == true) {
      print('✅ Logged in via regular login with Google ID as password!');
      
      // Update user photo if available
      if (photoUrl != null && _user != null) {
        _user!['photo_url'] = photoUrl;
        _user!['avatar'] = photoUrl;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(_user));
      }
      
      return {
        'success': true,
        'message': 'بەخێربێیت $name!',
        'user': _user,
      };
    }

    // STEP 4: Try with just the base username (extract from name or email)
    print('🔄 STEP 2: Trying login with username variations...');
    final baseUsername = name.contains(' ') ? name.split(' ')[0] : name;
    final usernameVariations = [
      baseUsername,
      baseUsername.toLowerCase(),
      email.split('@')[0],
      email.split('@')[0].toLowerCase(),
      '${baseUsername}_google',
      '${baseUsername.toLowerCase()}_google',
    ];

    for (String username in usernameVariations) {
      try {
        print('🔍 Trying username: $username');
        final usernameLoginResult = await _loginWithUsername(
          username: username,
          password: googleId,
        );

        if (usernameLoginResult['success'] == true) {
          print('✅ Logged in with username: $username');
          
          // Update user photo if available
          if (photoUrl != null && _user != null) {
            _user!['photo_url'] = photoUrl;
            _user!['avatar'] = photoUrl;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userData', jsonEncode(_user));
          }
          
          return {
            'success': true,
            'message': 'بەخێربێیت $name!',
            'user': _user,
          };
        }
      } catch (e) {
        print('⚠️ Username login failed for $username: $e');
        continue;
      }
    }

    // STEP 3: All login attempts failed - do NOT try registration for signInWithGoogle
    print('❌ All login attempts failed - account may not exist or wrong credentials');
    return {
      'success': false,
      'message': 'ئەکاونت نەدۆزرایەوە یان زانیارییەکان هەڵەن. تکایە هەژماری نوێ دروست بکە.',
      'account_not_found': true,
      'email': email,
      'error_type': 'account_not_found',
    };
  }

  // Updated signInWithGoogle method to handle the response better
  Future<Map<String, dynamic>> signInWithGoogle() async {
    print('🚀🚀🚀 === GOOGLE SIGN-IN METHOD CALLED === 🚀🚀🚀');
    print('📅 Timestamp: ${DateTime.now()}');
    print('🔍 Checking GoogleSignIn instance: $_googleSignIn');
    print('📱 Platform: Android');
    
    _isLoading = true;
    notifyListeners();
    print('⚙️ Loading state set to true');
    
    try {
      print('🟢 Starting Google Sign-In process...');
      print('🔑 Calling _googleSignIn.signIn()...');
      
      // Sign out first to ensure fresh login
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google Sign-In was cancelled by user');
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'تۆ داخڵبوونت هەڵوەشاندەوە', // You cancelled the login
        };
      }

      print('Google user signed in: ${googleUser.email}');
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        print('Failed to get Google access token');
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'هەڵەیەک ڕووی دا لە گووگڵ داخڵبوون', // An error occurred with Google login
        };
      }

      print('Google access token obtained');
      
      // Try to register/login with your backend using Google data
      final result = await _registerOrLoginWithGoogle(
        email: googleUser.email,
        name: googleUser.displayName ?? googleUser.email.split('@')[0],
        googleId: googleUser.id,
        googleToken: googleAuth.idToken ?? googleAuth.accessToken ?? '',
        photoUrl: googleUser.photoUrl,
      );
      
      _isLoading = false;
      notifyListeners();
      
      return result;
      
    } catch (error) {
      print('Google Sign-In error: $error');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'هەڵەیەک ڕووی دا: $error', // An error occurred
      };
    }
  }

  // Updated _registerWithRegularEndpoint to be more robust
  Future<Map<String, dynamic>> _registerWithRegularEndpoint({
    required String email,
    required String name,
    required String googleId,
    String? photoUrl,
  }) async {
    try {
      // Try different username variations if the first one fails
      final baseUsername = name.contains(' ') ? name.split(' ')[0] : name;
      final emailUsername = email.split('@')[0];
      
      final usernameVariations = [
        baseUsername.toLowerCase(),
        emailUsername.toLowerCase(),
        '${baseUsername.toLowerCase()}_g',
        '${emailUsername.toLowerCase()}_google',
        '${baseUsername.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      ];
      
      for (int i = 0; i < usernameVariations.length; i++) {
        final username = usernameVariations[i];
        final requestBody = {
          'email': email,
          'name': name,
          'username': username,
          'password': googleId,
          'password_confirmation': googleId,
          if (photoUrl != null) 'photo_url': photoUrl,
          if (photoUrl != null) 'avatar': photoUrl,
        };
        
        print('🚀 Registration attempt ${i + 1}: username = $username');
        
        final registerResponse = await http.post(
          Uri.parse('$baseUrl/api/auth/register'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(requestBody),
        );
        
        print('📡 Registration response status: ${registerResponse.statusCode}');
        print('📄 Registration response body: ${registerResponse.body}');
        
        if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
          print('✅ User successfully registered with username: $username');
          
          // Parse the registration response
          final regData = jsonDecode(registerResponse.body);
          
          // Check if registration response contains tokens (direct login)
          if (regData['access_token'] != null) {
            print('✅ Registration response contains tokens - logging in directly');
            _token = regData['access_token'];
            _refreshToken = regData['refresh_token'];
            _user = regData['user'] ?? {
              'email': email,
              'username': username,
              'name': name,
              'photo_url': photoUrl,
            };
            _isSignedIn = true;

            // Persist tokens & user
            final prefs = await SharedPreferences.getInstance();
            if (_token != null) await prefs.setString('token', _token!);
            if (_refreshToken != null) await prefs.setString('refreshToken', _refreshToken!);
            await prefs.setString('userData', jsonEncode(_user));
            
            return {
              'success': true,
              'message': 'بەخێربێیت $name! هەژمارەکەت بە سەرکەوتوویی دروستکرا.',
              'user': _user,
            };
          }
          
          // If no tokens in registration response, login separately
          print('🔑 Registration successful, now logging in...');
          final loginResult = await login(
            email: email,
            password: googleId,
          );
          
          if (loginResult['success'] == true) {
            print('✅ Successfully logged in after registration');
            return {
              'success': true,
              'message': 'بەخێربێیت $name! هەژمارەکەت بە سەرکەوتوویی دروستکرا.',
              'user': _user,
            };
          } else {
            // Registration successful but login failed - try username login
            final usernameLoginResult = await _loginWithUsername(
              username: username,
              password: googleId,
            );
            
            if (usernameLoginResult['success'] == true) {
              return {
                'success': true,
                'message': 'بەخێربێیت $name! هەژمارەکەت بە سەرکەوتوویی دروستکرا.',
                'user': _user,
              };
            }
          }
          
          // If both login attempts failed after successful registration
          return {
            'success': false,
            'message': 'هەژمار دروست کرا بەڵام نەتوانرا بچیتە ژوورەوە. تکایە دووبارە هەوڵ بدەوە.',
          };
        } else {
          final data = jsonDecode(registerResponse.body);
          
          // If it's an email already registered error, return immediately
          if (data['detail']?.toString().contains('Email already registered') == true) {
            print('❌ Email already registered - stopping attempts');
            return {
              'success': false,
              'message': 'Registration failed',
              'detail': data['detail'],
              'errors': data['errors'] ?? {},
              'status_code': registerResponse.statusCode,
            };
          }
          
          // If username is already taken and we have more variations, try next
          if (data['detail']?.toString().contains('Username already registered') == true && 
              i < usernameVariations.length - 1) {
            print('⚠️ Username "$username" already taken, trying next variation...');
            continue;
          }
          
          // If it's the last attempt or a different error, return the error
          print('❌ Registration failed with status: ${registerResponse.statusCode}');
          return {
            'success': false,
            'message': data['message'] ?? data['detail'] ?? 'Registration failed',
            'detail': data['detail'],
            'errors': data['errors'] ?? {},
            'status_code': registerResponse.statusCode,
          };
        }
      }
      
      // If all username variations failed
      return {
        'success': false,
        'message': 'Unable to create account with available usernames',
        'status_code': 400,
      };
      
    } catch (e) {
      print('❌ Exception in regular endpoint registration: $e');
      return {
        'success': false,
        'message': 'هەڵەیەک ڕووی دا لە سێرڤەر: $e',
      };
    }
  }

  // Google-specific login endpoint method
  Future<Map<String, dynamic>> _loginWithGoogleEndpoint({
    required String email,
    required String name,
    required String googleId,
    required String googleToken,
    String? photoUrl,
  }) async {
    try {
      print('🔑 Attempting Google login endpoint...');
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google-login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'google_id': googleId,
          'google_token': googleToken,
          'photo_url': photoUrl,
        }),
      );

      print('Google login response status: ${response.statusCode}');
      print('Google login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Store tokens and user data
        _token = data['access_token'];
        _refreshToken = data['refresh_token'];
        _user = data['user'];
        _isSignedIn = true;

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        if (_refreshToken != null) {
          await prefs.setString('refreshToken', _refreshToken!);
        }
        await prefs.setString('userData', jsonEncode(_user));

        print('✅ Google login successful!');
        return {
          'success': true,
          'message': 'بەخێربێیت ${_user!['name']}!',
          'user': _user,
        };
      } else {
        print('❌ Google login failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Google login failed',
        };
      }
    } catch (e) {
      print('❌ Exception in Google login endpoint: $e');
      return {
        'success': false,
        'message': 'هەڵەیەک ڕووی دا لە سێرڤەر: $e',
      };
    }
  }

  // Google-specific registration endpoint method
  Future<Map<String, dynamic>> _registerWithGoogleEndpoint({
    required String email,
    required String name,
    required String googleId,
    required String googleToken,
    String? photoUrl,
  }) async {
    try {
      print('🆕 Attempting Google registration endpoint...');
      
      // Generate username from name or email
      String username = name.contains(' ') ? name.split(' ')[0] : name;
      if (username.isEmpty) {
        username = email.split('@')[0];
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google-register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'username': username,
          'google_id': googleId,
          'google_token': googleToken,
          'photo_url': photoUrl,
        }),
      );

      print('Google registration response status: ${response.statusCode}');
      print('Google registration response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          // Store tokens and user data if provided
          if (data['access_token'] != null) {
            _token = data['access_token'];
            _refreshToken = data['refresh_token'];
            _user = data['user'];
            _isSignedIn = true;

            // Save to SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', _token!);
            if (_refreshToken != null) {
              await prefs.setString('refreshToken', _refreshToken!);
            }
            await prefs.setString('userData', jsonEncode(_user));

            print('✅ Google registration successful with auto-login!');
            return {
              'success': true,
              'message': 'بەخێربێیت ${_user!['name']}!',
              'user': _user,
            };
          } else {
            // Registration successful but need to login
            print('✅ Google registration successful, now logging in...');
            return await _loginWithGoogleEndpoint(
              email: email,
              name: name,
              googleId: googleId,
              googleToken: googleToken,
              photoUrl: photoUrl,
            );
          }
        }
      }
      
      print('❌ Google registration failed: ${data['message']}');
      return {
        'success': false,
        'message': data['message'] ?? 'Google registration failed',
      };
    } catch (e) {
      print('❌ Exception in Google registration endpoint: $e');
      return {
        'success': false,
        'message': 'هەڵەیەک ڕووی دا لە سێرڤەر: $e',
      };
    }
  }

  // Google Sign-Up method - Forces registration first (for registration mode)
  Future<Map<String, dynamic>> signUpWithGoogle() async {
    print('🚀🚀🚀 === GOOGLE SIGN-UP METHOD CALLED === 🚀🚀🚀');
    print('📅 Timestamp: ${DateTime.now()}');
    print('🔍 Checking GoogleSignIn instance: $_googleSignIn');
    print('📱 Platform: Android');
    
    _isLoading = true;
    notifyListeners();
    print('⚙️ Loading state set to true');
    
    try {
      print('🟢 Starting Google Sign-Up process...');
      print('🔑 Calling _googleSignIn.signIn()...');
      
      // Sign out first to ensure fresh login
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google Sign-Up was cancelled by user');
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'تۆ داخڵبوونت هەڵوەشاندەوە', // You cancelled the login
        };
      }

      print('Google user signed up: ${googleUser.email}');
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        print('Failed to get Google access token');
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'هەڵەیەک ڕووی دا لە گووگڵ داخڵبوون', // An error occurred with Google login
        };
      }

      print('Google access token obtained for sign-up');
      
      // Try to register first (this is the key difference from signInWithGoogle)
      final result = await _registerWithRegularEndpoint(
        email: googleUser.email,
        name: googleUser.displayName ?? googleUser.email.split('@')[0],
        googleId: googleUser.id,
        photoUrl: googleUser.photoUrl,
      );
      
      _isLoading = false;
      notifyListeners();
      
      // If registration succeeded, return success
      if (result['success'] == true) {
        return result;
      }
      
      // If registration failed due to existing email, show appropriate message
      final errorMessage = result['message']?.toString() ?? '';
      final errorDetail = result['detail']?.toString() ?? '';
      
      if (errorDetail.contains('Email already registered') || 
          errorMessage.contains('already registered') ||
          errorDetail.contains('تۆمارکراوە') ||
          errorMessage.contains('تۆمارکراوە')) {
        
        print('⚠️ Email already exists during sign-up attempt');
        return {
          'success': false,
          'message': 'ئەم ئیمەیڵە پێشتر بە شێوەیەکی ئاسایی تۆمارکراوە. تکایە بە وشەی نهێنی خۆت بچۆ ژوورەوە.',
          'account_exists': true,
          'email': googleUser.email,
          'error_type': 'email_exists',
        };
      }
      
      // For other registration errors
      return {
        'success': false,
        'message': result['message'] ?? 'هەڵەیەک ڕوویدا لە هەژمار دروستکردن',
        'error_type': 'registration_failed'
      };
      
    } catch (error) {
      print('Google Sign-Up error: $error');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'هەڵەیەک ڕووی دا: $error', // An error occurred
      };
    }
  }

  // Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      print('Signed out from Google');
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  // Delete account method
  Future<Map<String, dynamic>> deleteAccount() async {
    if (!_isSignedIn || _token == null) {
      return {
        'success': false,
        'message': 'تۆ داخڵ نەبوویت',
      };
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('Attempting to delete account for user: ${_user?['email']}');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/auth/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Delete account response status: ${response.statusCode}');
      print('Delete account response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Account successfully deleted
        print('✅ Account deleted successfully');
        
        // Sign out from Google if applicable
        try {
          await _googleSignIn.signOut();
        } catch (e) {
          print('Warning: Could not sign out from Google: $e');
        }
        
        // Clear all local data
        await _clearTokens();
        _user = null;
        _isSignedIn = false;
        
        _isLoading = false;
        notifyListeners();
        
        return {
          'success': true,
          'message': 'هەژمارەکەت بە سەرکەوتوویی سڕایەوە',
        };
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['message'] ?? data['detail'] ?? 'هەڵەیەک ڕووی دا لە سڕینەوەی هەژمار';
        
        _isLoading = false;
        notifyListeners();
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('Error deleting account: $e');
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': false,
        'message': 'هەڵەیەک ڕووی دا: $e',
      };
    }
  }
}