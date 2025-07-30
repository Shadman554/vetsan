import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/history_provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DrugDetailsPage extends StatefulWidget {
  final dynamic drug;

  const DrugDetailsPage({Key? key, required this.drug}) : super(key: key);

  @override
  State<DrugDetailsPage> createState() => _DrugDetailsPageState();
}

class _DrugDetailsPageState extends State<DrugDetailsPage> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    // Add to history after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false)
          .addToHistory(widget.drug.name, 'drug', 'Viewed drug details');
    });
  }

  Future<void> _initTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
    } catch (e) {
      print("TTS initialization error: $e");
    }
  }

  Future<void> _speak(String text) async {
    try {
      if (isPlaying) {
        await flutterTts.stop();
        setState(() => isPlaying = false);
      } else {
        setState(() => isPlaying = true);
        await flutterTts.speak(text);
        setState(() => isPlaying = false);
      }
    } catch (e) {
      print("TTS speak error: $e");
      setState(() => isPlaying = false);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    Provider.of<LanguageProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(widget.drug);

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
                          icon: Icon(Icons.arrow_back, color: themeProvider.isDarkMode ? Colors.white : Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Drug Image
                  if (widget.drug.imageUrl.isNotEmpty)
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
                          widget.drug.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // Drug Name
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Text(
                      widget.drug.name,
                      style: TextStyle(
                        color: themeProvider.isDarkMode 
                          ? Colors.white 
                          : Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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
                            String content = '''${widget.drug.name}
${widget.drug.usage}
${widget.drug.sideEffect}
${widget.drug.otherInfo}''';
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
                              favoritesProvider.removeFavorite(widget.drug);
                            } else {
                              favoritesProvider.addFavorite(widget.drug);
                            }
                          },
                          label: isFavorite 
                            ? 'پاشەکەوتکراوە'
                            : 'پاشەکەوتکردن',
                          themeProvider: themeProvider,
                        ),
                        _buildActionButton(
                          icon: Icons.share_rounded,
                          onTap: () {
                            String content = '''${widget.drug.name}
${widget.drug.usage}
${widget.drug.sideEffect}
${widget.drug.otherInfo}''';
                            Share.share(content);
                          },
                          label: 'هاوبەشکردن',
                          themeProvider: themeProvider,
                        ),
                        _buildActionButton(
                          icon: isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                          onTap: () {
                            String content = '''${widget.drug.name}
${widget.drug.usage}
${widget.drug.sideEffect}
${widget.drug.otherInfo}''';
                            _speak(content.trim());
                          },
                          label: isPlaying 
                            ? 'وەستان'
                            : 'دەنگ',
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
                  _buildInfoSection(
                    'بەکارهێنان',
                    widget.drug.usage,
                    Icons.medical_services,
                    themeProvider.isDarkMode 
                      ? Colors.blue.shade300 
                      : Colors.blue.shade700,
                    themeProvider,
                  ),
                  SizedBox(height: 16),
                  _buildInfoSection(
                    'کاریگەری لاوەکی',
                    widget.drug.sideEffect,
                    Icons.warning_amber,
                    themeProvider.isDarkMode 
                      ? Colors.orange.shade300 
                      : Colors.orange.shade700,
                    themeProvider,
                  ),
                  SizedBox(height: 16),
                  _buildInfoSection(
                    'زانیاری زیاتر',
                    widget.drug.otherInfo,
                    Icons.info,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
