import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Directionality(
      textDirection: languageProvider.textDirection,
      child: Scaffold(
        backgroundColor: themeProvider.theme.scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: themeProvider.isDarkMode
                  ? [
                      themeProvider.theme.scaffoldBackgroundColor,
                      const Color(0xFF1E1E1E),
                    ]
                  : [
                      themeProvider.theme.scaffoldBackgroundColor,
                      const Color(0xFFE2E8F0),
                    ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  // App Logo and Title
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF556598),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode 
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icon/logo1.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.medical_services,
                            size: 25,
                            color: themeProvider.theme.colorScheme.primary,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '+VET DICT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.theme.colorScheme.onBackground,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Welcome Text
                  Text(
                    _isLoginMode ? 'چوونە ژوورەوە' : 'دروستکردنی هەژمار',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.theme.colorScheme.onBackground,
                      fontFamily: 'NRT',
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Login/Register Form
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Name field (only for registration)
                            if (!_isLoginMode) ...[
                              _buildTextField(
                                controller: _nameController,
                                label: 'ناو',
                                icon: Icons.person,
                                validator: (value) {
                                  if (!_isLoginMode && (value == null || value.isEmpty)) {
                                    return 'تکایە ناوت بنووسە';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                            
                            // Email field
                            _buildTextField(
                              controller: _emailController,
                              label: 'ئیمەیڵ',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'تکایە ئیمەیڵەکەت بنووسە';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'ئیمەیڵەکە دروست نییە';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            // Password field
                            _buildTextField(
                              controller: _passwordController,
                              label: 'وشەی نهێنی',
                              icon: Icons.lock,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: themeProvider.theme.colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'تکایە وشەی نهێنی بنووسە';
                                }
                                if (value.length < 6) {
                                  return 'وشەی نهێنی دەبێت لانیکەم ٦ پیت بێت';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            // Confirm Password field (only for registration)
                            if (!_isLoginMode) ...[
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'دووبارەکردنەوەی وشەی نهێنی',
                                icon: Icons.lock_outline,
                                obscureText: _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                    color: themeProvider.theme.colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (!_isLoginMode && (value == null || value.isEmpty)) {
                                    return 'تکایە وشەی نهێنی دووبارە بکەرەوە';
                                  }
                                  if (!_isLoginMode && value != _passwordController.text) {
                                    return 'وشەی نهێنی یەکسان نین';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ] else
                              const SizedBox(height: 16),
                            
                            // Login/Register Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.theme.colorScheme.primary,
                                  foregroundColor: themeProvider.theme.colorScheme.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            themeProvider.theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        _isLoginMode ? 'چوونە ژوورەوە' : 'دروستکردنی هەژمار',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Toggle between login and register
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLoginMode = !_isLoginMode;
                                  // Clear form when switching modes
                                  _formKey.currentState?.reset();
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _nameController.clear();
                                  _confirmPasswordController.clear();
                                });
                              },
                              child: RichText(
                                textDirection: TextDirection.rtl,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    color: themeProvider.theme.colorScheme.onBackground.withOpacity(0.8),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _isLoginMode 
                                          ? 'هەژمارت نییە؟ ' 
                                          : 'هەژمارت هەیە؟ ',
                                    ),
                                    TextSpan(
                                      text: _isLoginMode 
                                          ? 'دروستی بکە' 
                                          : 'چوونە ژوورەوە',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Divider with "یان" (Or)
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: themeProvider.theme.colorScheme.onBackground.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'یان',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeProvider.theme.colorScheme.onBackground.withOpacity(0.6),
                                      fontFamily: 'NRT',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: themeProvider.theme.colorScheme.onBackground.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Google Sign-In Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: Colors.grey.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/google_logo.png',
                                            height: 24,
                                            width: 24,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.login,
                                                size: 24,
                                                color: Colors.black87,
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _isLoginMode ? 'چوونە ژوورەوە بە گووگڵ' : 'دروستکردنی هەژمار بە گووگڵ',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'NRT',
                                              color: Colors.black87,
                                            ),
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Bottom section with terms
                            Text(
                              'بە چوونە ژوورەوە، تۆ ڕێکەوتننامە و سیاسەتی تایبەتمەندی قبوڵ دەکەیت',
                              style: TextStyle(
                                fontSize: 10,
                                color: themeProvider.theme.colorScheme.onBackground.withOpacity(0.6),
                                fontFamily: 'NRT',
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Directionality(
      textDirection: languageProvider.textDirection,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        textDirection: languageProvider.textDirection,
        style: TextStyle(
          color: themeProvider.theme.colorScheme.onBackground,
          fontFamily: 'Inter',
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: themeProvider.theme.colorScheme.onBackground.withOpacity(0.7),
            fontFamily: 'Inter',
          ),
          prefixIcon: Icon(
            icon,
            color: themeProvider.theme.colorScheme.primary,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: themeProvider.theme.cardTheme.color,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.theme.colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  // UPDATED: Handle Google Sign-In with better error handling
  Future<void> _handleGoogleSignIn() async {
    print('🔴🔴🔴 GOOGLE SIGN-IN BUTTON PRESSED! 🔴🔴🔴');
    print('📱 Device Info: Android');
    print('⏰ Timestamp: ${DateTime.now()}');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Map<String, dynamic> result;
    
    try {
      if (_isLoginMode) {
        print('🔵🔵🔵 CALLING authProvider.signInWithGoogle() for LOGIN... 🔵🔵🔵');
        result = await authProvider.signInWithGoogle();
      } else {
        print('🔵🔵🔵 CALLING authProvider.signUpWithGoogle() for REGISTRATION... 🔵🔵🔵');
        // For registration mode, use signUpWithGoogle which forces registration first
        result = await authProvider.signUpWithGoogle();
      }
      print('🟡🟡🟡 GOOGLE RESULT: $result 🟡🟡🟡');
    } catch (error, stackTrace) {
      print('❌❌❌ CRITICAL ERROR IN _handleGoogleSignIn: $error');
      print('📋 Stack trace: $stackTrace');
      
      if (mounted) {
        _showErrorSnackBar('هەڵەیەک ڕوویدا لە گووگڵ داخڵبوون: $error');
      }
      return;
    }
    
    if (result['success'] == true) {
      // Success - user logged in successfully
      print('✅ Google Sign-In successful!');
      
      // Show success message
      final userName = authProvider.userDisplayName;
      _showSuccessMessage(userName);
      
      // Navigation will be handled by the main app automatically
    } else {
      // Handle different error types
      final errorType = result['error_type'] ?? '';
      final message = result['message'] ?? 'Unknown error occurred';
      final email = result['email'] ?? '';
      
      print('❌ Google Sign-In failed: $errorType - $message');
      
      if (errorType == 'email_exists') {
        // Show dialog explaining the account exists with regular login
        _showAccountExistsDialog(email, message);
      } else if (errorType == 'username_exists') {
        // Show error about username availability
        _showErrorSnackBar(message);
      } else if (errorType == 'authentication_failed') {
        // Show general authentication error
        _showErrorSnackBar('تکایە دووبارە هەوڵ بدەوە یان بە شێوەیەکی ئاسایی بچۆ ژوورەوە.');
      } else {
        // Show the specific error message
        _showErrorSnackBar(message);
      }
    }
  }

  // UPDATED: Show better account exists dialog
  void _showAccountExistsDialog(String email, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (BuildContext context) {
        final languageProvider = Provider.of<LanguageProvider>(context);
        final themeProvider = Provider.of<ThemeProvider>(context);
        
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: AlertDialog(
            backgroundColor: themeProvider.theme.dialogBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.account_circle_outlined, 
                  color: themeProvider.theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'هەژماری ئاسایی هەیە', // Regular Account Exists
                      style: TextStyle(
                        fontFamily: 'NRT',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'NRT',
                      color: themeProvider.theme.colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: themeProvider.theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: themeProvider.theme.colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            email,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeProvider.theme.colorScheme.primary,
                              fontFamily: 'Inter',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    'تکایە بە وشەی نهێنی خۆت بچۆ ژوورەوە.',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NRT',
                      color: themeProvider.theme.colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              // Cancel button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: themeProvider.theme.colorScheme.onSurface.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'پاشگەزبوونەوە', // Cancel
                  style: TextStyle(
                    fontFamily: 'NRT',
                    fontSize: 14,
                  ),
                ),
              ),
              
              // Login with regular account button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Pre-fill the email and switch to login mode
                  _goToRegularLogin(email);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.theme.colorScheme.primary,
                  foregroundColor: themeProvider.theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.login, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'چوونە ژوورەوە', // Login
                      style: TextStyle(
                        fontFamily: 'NRT',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'NRT',
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          action: SnackBarAction(
            label: 'باشە', // OK
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  // UPDATED: Pre-fill email and switch to login mode with better UX
  void _goToRegularLogin(String email) {
    // Pre-fill the email and switch to login mode
    setState(() {
      _emailController.text = email;
      _isLoginMode = true; // Switch to login mode
      _passwordController.clear(); // Clear password field
    });
    
    // Show a helpful message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ئیمەیڵەکەت پڕکراوەتەوە. تکایە وشەی نهێنیت بنووسە.',
                style: const TextStyle(
                  fontFamily: 'NRT',
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    
    // Auto-focus on password field after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  // Show success message for successful Google Sign-In
  void _showSuccessMessage(String userName) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'بەخێربێیت $userName!', // Welcome!
                style: const TextStyle(fontFamily: 'NRT'),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  // Handle form submission for regular login/register
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Map<String, dynamic> result;

    if (_isLoginMode) {
      // Login
      result = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      // Register
      result = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );
    }

    if (mounted) {
      if (result['success'] == true) {
        // Success - navigation will be handled by the main app
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] ?? (_isLoginMode ? 'بە سەرکەوتوویی چوویتە ژوورەوە' : 'هەژمار بە سەرکەوتوویی دروست کرا'),
                    style: const TextStyle(
                      fontFamily: 'NRT',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        // Error
        String errorMessage = result['message'] ?? 'هەڵەیەک ڕوویدا';
        
        // Handle validation errors
        if (result['errors'] != null && result['errors'] is Map) {
          final errors = result['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            } else if (value is String) {
              errorMessages.add(value);
            }
          });
          
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      fontFamily: 'NRT',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}