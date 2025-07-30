import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }



  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    fontFamily: 'Inter',
    fontFamilyFallback: const ['sans-serif'],
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1E293B),
      onBackground: const Color(0xFF1E293B),
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1E293B)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
    cardTheme: CardTheme( // Removed const
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData( // Removed const
      color: const Color(0xFFE0E0E0),
      thickness: 1,
      indent: 16,
      endIndent: 16,
    ),
    dialogTheme: DialogTheme( // Removed const
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      contentTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData( // Removed const
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: Colors.grey[600],
      elevation: 8,
    ),
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: 'Inter',
    fontFamilyFallback: const ['sans-serif'],
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4B9EFF),
      brightness: Brightness.dark,
      primary: const Color(0xFF4B9EFF),
      secondary: const Color(0xFF7B91B0),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      error: const Color(0xFFCF6679),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFE1E1E1),
      onBackground: const Color(0xFFE1E1E1),
      onError: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE1E1E1)),
      titleTextStyle: TextStyle(
        color: Color(0xFFE1E1E1),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
    cardTheme: CardTheme( // Removed const
      color: const Color(0xFF1E1E1E),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData( // Removed const
      color: const Color(0xFF2C2C2C),
      thickness: 1,
      indent: 16,
      endIndent: 16,
    ),
    dialogTheme: DialogTheme( // Removed const
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white70),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData( // Removed const
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: const Color(0xFF4B9EFF),
      unselectedItemColor: Colors.grey[400],
      elevation: 8,
    ),
  );
}