import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/language_provider.dart';
import '../utils/page_transition.dart';
import 'drug_details_page.dart';
import 'disease_details_page.dart';
import 'terminology_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFavoritesList(List<dynamic> items, String type) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Provider.of<LanguageProvider>(context);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 80,
              color: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'هیچ ${type.toLowerCase() == 'drug' ? 'دەرمانی' : type.toLowerCase() == 'disease' ? 'نەخۆشیی' : 'زاراوەی'} دڵخواز نییە',
              style: TextStyle(
                color: themeProvider.isDarkMode ? themeProvider.theme.colorScheme.onSurface.withOpacity(0.6) : themeProvider.theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (type == 'drug') {
                    Navigator.push(
                      context,
                      createRoute(DrugDetailsPage(drug: item)),
                    );
                  } else if (type == 'disease') {
                    Navigator.push(
                      context,
                      createRoute(DiseaseDetailsPage(disease: item)),
                    );
                  } else if (type == 'terminology') {
                    Navigator.push(
                      context,
                      createRoute(TerminologyDetailsPage(terminology: item)),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? themeProvider.theme.colorScheme.primary.withOpacity(0.2)
                              : themeProvider.theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          type == 'drug'
                              ? Icons.medication_rounded
                              : type == 'disease'
                                  ? Icons.sick_rounded
                                  : Icons.book_rounded,
                          color: themeProvider.theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Provider.of<FavoritesProvider>(context, listen: false).isFavorite(item)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Provider.of<FavoritesProvider>(context, listen: false).isFavorite(item)
                              ? (themeProvider.isDarkMode
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade700)
                              : (themeProvider.isDarkMode
                                  ? Colors.grey[600]
                                  : Colors.grey[400]),
                        ),
                        onPressed: () {
                          final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
                          if (favoritesProvider.isFavorite(item)) {
                            favoritesProvider.removeFavorite(item);
                          } else {
                            favoritesProvider.addFavorite(item);
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    Provider.of<LanguageProvider>(context);

    final drugFavorites = favoritesProvider.getDrugFavorites();
    final diseaseFavorites = favoritesProvider.getDiseaseFavorites();
    final wordFavorites = favoritesProvider.getWordFavorites();

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? themeProvider.theme.scaffoldBackgroundColor : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeProvider.theme.appBarTheme.backgroundColor,
        title: Text(
          'دڵخوازەکان',
          style: themeProvider.theme.appBarTheme.titleTextStyle?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: themeProvider.theme.colorScheme.onSurface,
          unselectedLabelColor: themeProvider.theme.colorScheme.onSurface.withOpacity(0.7),
          indicatorColor: themeProvider.theme.colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          tabs: [
            Tab(
              child: Directionality(
                textDirection: Provider.of<LanguageProvider>(context).textDirection,
                child: Text(
                  'دەرمانەکان',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            Tab(
              child: Directionality(
                textDirection: Provider.of<LanguageProvider>(context).textDirection,
                child: Text(
                  'نەخۆشییەکان',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            Tab(
              child: Directionality(
                textDirection: Provider.of<LanguageProvider>(context).textDirection,
                child: Text(
                  'زاراوەکان',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesList(drugFavorites, 'drug'),
          _buildFavoritesList(diseaseFavorites, 'disease'),
          _buildFavoritesList(wordFavorites, 'terminology'),
        ],
      ),
    );
  }
}
