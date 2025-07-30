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

    return Directionality(
      textDirection: languageProvider.textDirection,
      child: Scaffold(
        backgroundColor: themeProvider.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Directionality(
            textDirection: languageProvider.textDirection,
            child: Text(
              'ڕێکخستنەکان',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
            ),
          ),
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          centerTitle: true,
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
              title: 'ڕووکار',
              children: [
                _buildThemeToggle(),
                _buildFontSizeSlider(),
              ],
            ),

            const SizedBox(height: 24),
            _buildSettingsSection(
              title:'دەربارە',
              children: [
                _buildAboutTile(),
              ],
            ),

        ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              title,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                fontSize: 19,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                letterSpacing: 0.2,
              ),
              textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
              textDirection: languageProvider.textDirection,
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: themeProvider.isDarkMode ? Colors.grey[600] : Colors.grey[300],
            indent: 20,
            endIndent: 20,
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
      child: Directionality(
        textDirection: languageProvider.textDirection,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'دۆخی تاریک',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF475569),
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
                textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
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
        crossAxisAlignment: languageProvider.isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Directionality(
            textDirection: languageProvider.textDirection,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'قەبارەی فۆنت',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                    textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
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



  Widget _buildAboutTile() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Directionality(
      textDirection: languageProvider.textDirection,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          'وەشانی ئەپ',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF475569),
            fontSize: 16,
            fontFamily: 'Inter',
          ),
          textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
        ),
        trailing: Text(
          '1.0.0',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.grey[400] : const Color(0xFF64748B),
            fontSize: 16,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

}