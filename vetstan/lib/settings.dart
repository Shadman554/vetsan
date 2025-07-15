import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/font_size_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          languageProvider.translate('settings'),
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, 
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B)
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            title: languageProvider.translate('display'),
            children: [
              _buildThemeToggle(),
              _buildFontSizeSlider(),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: languageProvider.translate('language'),
            children: [
              _buildLanguageSelector(context),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title:languageProvider.translate('About'),
            children: [
              _buildAboutTile(),
            ],
          ),
      ],
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Divider(
            height: 1,
            color: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            languageProvider.translate('Dark Mode'),
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF475569),
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
  
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageProvider.translate('Font Size'),
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '${(fontSizeProvider.fontSize * 100).round()}%',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          Slider(
            value: fontSizeProvider.fontSize,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            onChanged: (value) {
              fontSizeProvider.setFontSize(value);
            },
            activeColor: const Color(0xFF6366F1),
            inactiveColor: themeProvider.isDarkMode ? Colors.white24 : Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        _buildLanguageOption(
          'English',
          languageProvider.currentLocale.languageCode == 'en',
          () => languageProvider.setLanguage('en'),
        ),
        Divider(
          height: 1,
          color: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
        ),
        _buildLanguageOption(
          'Kurdish',
          languageProvider.currentLocale.languageCode == 'ku',
          () => languageProvider.setLanguage('ku'),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: TextStyle(
                color: isSelected 
                  ? const Color(0xFF2563EB)
                  : (themeProvider.isDarkMode ? Colors.white : const Color(0xFF475569)),
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFF2563EB),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        languageProvider.translate('App Version'),
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF475569),
          fontSize: 16,
          fontFamily: 'Inter',
        ),
      ),
      trailing: Text(
        '1.0.0',
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.grey[400] : const Color(0xFF64748B),
          fontSize: 16,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}