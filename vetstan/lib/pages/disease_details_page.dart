import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../models/disease.dart';

class DiseaseDetailsPage extends StatefulWidget {
  final Disease disease;

  const DiseaseDetailsPage({Key? key, required this.disease}) : super(key: key);

  @override
  State<DiseaseDetailsPage> createState() => _DiseaseDetailsPageState();
}

class _DiseaseDetailsPageState extends State<DiseaseDetailsPage> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    // Add to history after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false)
          .addDiseaseToHistory(widget.disease.name, 'Viewed disease details');
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
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(widget.disease);

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

                  // Disease Image
                  if (widget.disease.imageUrl.isNotEmpty)
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
                          widget.disease.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // Disease Name
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Directionality(
                      textDirection: languageProvider.textDirection,
                      child: Text(
                        widget.disease.name,
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
                            String content = '''${widget.disease.name}
${widget.disease.kurdish}
${widget.disease.cause}
${widget.disease.symptoms}
${widget.disease.control}''';
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
                              favoritesProvider.removeFavorite(widget.disease);
                            } else {
                              favoritesProvider.addFavorite(widget.disease);
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
                            String content = '''${widget.disease.name}
${widget.disease.kurdish}
${widget.disease.cause}
${widget.disease.symptoms}
${widget.disease.control}''';
                            Share.share(content);
                          },
                          label: 'هاوبەشکردن',
                          themeProvider: themeProvider,
                        ),
                        _buildActionButton(
                          icon: isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                          onTap: () {
                            String content = '''${widget.disease.name}
${widget.disease.cause}
${widget.disease.symptoms}
${widget.disease.control}''';
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
                  if (widget.disease.kurdish.isNotEmpty)
                    _buildInfoSection(
                      'کوردی',
                      widget.disease.kurdish,
                      Icons.translate,
                      Colors.blue,
                      themeProvider,
                    ),
                  SizedBox(height: 16),
                  if (widget.disease.cause.isNotEmpty)
                    _buildInfoSection(
                      'هۆکار',
                      widget.disease.cause,
                      Icons.bug_report,
                      Colors.red,
                      themeProvider,
                    ),
                  SizedBox(height: 16),
                  _buildInfoSection(
                    'نیشانەکان',
                    widget.disease.symptoms,
                    Icons.medical_information,
                    Colors.orange,
                    themeProvider,
                  ),
                  SizedBox(height: 16),
                  if (widget.disease.control.isNotEmpty)
                    _buildInfoSection(
                      'کۆنترۆڵ',
                      widget.disease.control,
                      Icons.healing,
                      Colors.green,
                      themeProvider,
                    ),
                  SizedBox(height: 24),
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
      borderRadius: BorderRadius.circular(15),
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
