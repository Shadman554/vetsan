import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroductionItem> _introItems = [
    IntroductionItem(
      icon: Icons.medical_services,
      title: 'بەخێربێن بۆ VET DICT+',
      description: 'فەرهەنگی تەواوی پزیشکی ڤێتیرنەری بە زمانی کوردی. هەموو زانیارییەکانی پێویستت لێرە دەدۆزیتەوە.',
      color: Color(0xFF2563EB),
    ),
    IntroductionItem(
      icon: Icons.book,
      title: 'زاراوە پزیشکیەکان',
      description: 'هەزاران زاراوەی پزیشکی بە کوردی، عەرەبی و ئینگلیزی. گەڕان و فێربوون بە ئاسانی.',
      color: Color(0xFF059669),
    ),
    IntroductionItem(
      icon: Icons.healing,
      title: 'نەخۆشی و دەرمانەکان',
      description: 'زانیاری تەواو دەربارەی نەخۆشییەکانی ئاژەڵان و دەرمانەکانیان بە وردی.',
      color: Color(0xFFDC2626),
    ),
    IntroductionItem(
      icon: Icons.library_books,
      title: 'کتێب و سەرچاوەکان',
      description: 'کۆمەڵێک کتێبی پزیشکی ڤێتیرنەری بە زمانەکانی جیاواز بۆ خوێندن و داگرتن.',
      color: Color(0xFF7C3AED),
    ),
    IntroductionItem(
      icon: Icons.science,
      title: 'ئامرازەکان و تاقیکردنەوەکان',
      description: 'ئامرازەکانی پزیشکی، سلایدەکان، تاقیکردنەوەکان و نرخە ئاساییەکان.',
      color: Color(0xFFEA580C),
    ),
    IntroductionItem(
      icon: Icons.favorite,
      title: 'دڵخوازەکان و مێژوو',
      description: 'هەموو ئەو زانیارییانەی کە بەکارت هێناوە یان دڵخوازت کردووە لێرە هەڵدەگیرێت.',
      color: Color(0xFFDB2777),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      languageProvider.isRTL ? Icons.arrow_forward : Icons.arrow_back,
                      color: themeProvider.theme.colorScheme.primary,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      'VET DICT+',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Directionality(
                      textDirection: languageProvider.textDirection,
                      child: Text(
                        'تەواوکردن',
                        style: TextStyle(
                          color: themeProvider.theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NRT',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _introItems.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? themeProvider.theme.colorScheme.primary
                          : themeProvider.theme.colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _introItems.length,
                itemBuilder: (context, index) {
                  final item = _introItems[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                item.color,
                                item.color.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: item.color.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            item.icon,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Title
                        Directionality(
                          textDirection: languageProvider.textDirection,
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                              fontFamily: 'NRT',
                            ),
                            textAlign: languageProvider.isRTL
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Description
                        Directionality(
                          textDirection: languageProvider.textDirection,
                          child: Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              color: themeProvider.isDarkMode
                                  ? Colors.white.withOpacity(0.8)
                                  : const Color(0xFF64748B),
                              fontFamily: 'NRT',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Directionality(
                        textDirection: languageProvider.textDirection,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              languageProvider.isRTL ? Icons.arrow_forward : Icons.arrow_back,
                              color: themeProvider.theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'پێشوو',
                              style: TextStyle(
                                color: themeProvider.theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'NRT',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80),

                  // Next/Finish button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _introItems.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: Directionality(
                      textDirection: languageProvider.textDirection,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage < _introItems.length - 1 ? 'دواتر' : 'تەواوکردن',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'NRT',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage < _introItems.length - 1
                                ? (languageProvider.isRTL ? Icons.arrow_back : Icons.arrow_forward)
                                : Icons.check,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IntroductionItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  IntroductionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
