import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/favorites_provider.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/history_provider.dart';
import '../models/word.dart';

class TerminologyDetailsPage extends StatefulWidget {
  final Word terminology;

  const TerminologyDetailsPage({Key? key, required this.terminology}) : super(key: key);

  @override
  State<TerminologyDetailsPage> createState() => _TerminologyDetailsPageState();
}

class _TerminologyDetailsPageState extends State<TerminologyDetailsPage> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    // Add to history after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false)
          .addTerminologyToHistory(widget.terminology.name, 'Viewed terminology details');
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(widget.terminology);

    return Scaffold(
      backgroundColor: themeProvider.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode 
                  ? themeProvider.theme.colorScheme.surface 
                  : themeProvider.theme.colorScheme.primary.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 40, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Directionality(
                      textDirection: languageProvider.textDirection,
                      child: Text(
                        widget.terminology.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Terminology Image
                  if (widget.terminology.imageUrl.isNotEmpty)
                    Container(
                      width: 140,
                      height: 140,
                      margin: EdgeInsets.only(top: 20, bottom: 16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode 
                          ? Colors.grey[800] 
                          : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: themeProvider.isDarkMode 
                          ? null 
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.terminology.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.medication_outlined,
                              size: 60,
                              color: themeProvider.isDarkMode 
                                ? Colors.grey[600] 
                                : Colors.grey[400],
                            );
                          },
                        ),
                      ),
                    ),
                  // Action buttons
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode 
                        ? Colors.grey[800]?.withOpacity(0.5) 
                        : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.copy_rounded,
                          onTap: () {
                            String content = '''${widget.terminology.name}
${widget.terminology.kurdish}
${widget.terminology.arabic}
${widget.terminology.description}''';
                            Clipboard.setData(ClipboardData(text: content.trim()));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                          label: 'کۆپی',
                          themeProvider: themeProvider,
                        ),
                        _buildActionButton(
                          icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
                          onTap: () {
                            if (isFavorite) {
                              favoritesProvider.removeFavorite(widget.terminology);
                            } else {
                              favoritesProvider.addFavorite(widget.terminology);
                            }
                          },
                          label: isFavorite 
                            ? 'پاشەکەوتکراوە'
                            : 'پاشەکەوتکردن',
                          themeProvider: themeProvider,
                        ),
                        _buildActionButton(
                          icon: Icons.share,
                          onTap: () {
                            String content = '''${widget.terminology.name}
${widget.terminology.kurdish}
${widget.terminology.arabic}
${widget.terminology.description}''';
                            Share.share(content);
                          },
                          label: 'هاوبەشکردن',
                          themeProvider: themeProvider,
                        ),
                        _buildActionButton(
                          icon: Icons.volume_up,
                          onTap: () async {
                            final FlutterTts flutterTts = FlutterTts();
                            await flutterTts.speak(widget.terminology.name);
                          },
                          label: 'دەنگ',
                          themeProvider: themeProvider,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            
            // Content sections
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  if (widget.terminology.kurdish.isNotEmpty) ...[
                    _buildInfoSection(
                      'کوردی',
                      widget.terminology.kurdish,
                      Icons.translate,
                      themeProvider.isDarkMode 
                        ? Colors.blue.shade300 
                        : Colors.blue.shade700,
                      themeProvider,
                    ),
                    SizedBox(height: 16),
                  ],
                  if (widget.terminology.arabic.isNotEmpty) ...[
                    _buildInfoSection(
                      'عەرەبی',
                      widget.terminology.arabic,
                      Icons.language,
                      themeProvider.isDarkMode 
                        ? Colors.orange.shade300 
                        : Colors.orange.shade700,
                      themeProvider,
                    ),
                    SizedBox(height: 16),
                  ],
                  if (widget.terminology.description.isNotEmpty)
                    _buildInfoSection(
                      'پێناسە',
                      widget.terminology.description,
                      Icons.description,
                      themeProvider.isDarkMode 
                        ? Colors.green.shade300 
                        : Colors.green.shade700,
                      themeProvider,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
    required ThemeProvider themeProvider,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: themeProvider.isDarkMode 
                ? Colors.white 
                : Colors.white, 
              size: 24
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: themeProvider.isDarkMode 
                  ? Colors.white 
                  : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    String title, 
    String content, 
    IconData icon, 
    Color color,
    ThemeProvider themeProvider,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
          ? Color(0xFF1E1E1E) 
          : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: themeProvider.isDarkMode 
          ? null 
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
      ),
      child: Column(
        crossAxisAlignment: languageProvider.isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Directionality(
            textDirection: languageProvider.textDirection,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode 
                        ? Colors.white 
                        : color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Directionality(
            textDirection: languageProvider.textDirection,
            child: Text(
              content,
              textDirection: languageProvider.textDirection,
              textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode 
                  ? Colors.grey[400] 
                  : Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
