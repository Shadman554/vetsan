import 'package:flutter/material.dart';
import 'dart:async';
import '../services/sync_service.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/language_provider.dart';
import '../models/word.dart';
import 'terminology_details_page.dart';
import '../utils/page_transition.dart';

// Enum for terminology classification
enum TerminologyClass {
  antibiotic,
  painkiller,
  antiviral,
  antiparasitic,
  hormone,
  other
}

// Extension to provide user-friendly string representation
extension TerminologyClassExtension on TerminologyClass {
  String get displayName {
    switch (this) {
      case TerminologyClass.antibiotic:
        return 'Antibiotics';
      case TerminologyClass.painkiller:
        return 'Painkillers';
      case TerminologyClass.antiviral:
        return 'Antivirals';
      case TerminologyClass.antiparasitic:
        return 'Antiparasitics';
      case TerminologyClass.hormone:
        return 'Hormones';
      case TerminologyClass.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case TerminologyClass.antibiotic:
        return Colors.blue.shade700;
      case TerminologyClass.painkiller:
        return Colors.red.shade700;
      case TerminologyClass.antiviral:
        return Colors.green.shade700;
      case TerminologyClass.antiparasitic:
        return Colors.purple.shade700;
      case TerminologyClass.hormone:
        return Colors.orange.shade700;
      case TerminologyClass.other:
        return Colors.grey.shade700;
    }
  }
}

class TerminologyPage extends StatefulWidget {
  const TerminologyPage({Key? key}) : super(key: key);

  @override
  State<TerminologyPage> createState() => _TerminologyPageState();
}

class _TerminologyPageState extends State<TerminologyPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  static final SyncService _syncService = SyncService();

  List<Word> _terminology = [];
  List<Word> _filteredTerminology = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTerminologyData();
    _checkForUpdates();
    _startPeriodicSync();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTerminologyData() async {
    try {
      final terminologyList = await _syncService.loadCategoryData<Word>('dictionary');
      if (mounted) {
        setState(() {
          _terminology = terminologyList;
          _filteredTerminology = _terminology;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading terminology: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkForUpdates() async {
    // Check for updates in the background (no loading screen)
    final hasUpdates = await _syncService.checkForCategoryUpdates('dictionary');
    if (hasUpdates && mounted) {
      // Refresh the data silently
      final updatedData = await _syncService.loadCategoryData<Word>('dictionary');
      setState(() {
        _terminology = updatedData;
        _filteredTerminology = _terminology.where((terminology) =>
            terminology.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            terminology.kurdish.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            terminology.arabic.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            terminology.description.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
      });
    }
  }

  void _filterTerminology(String query) {
    setState(() {
      _filteredTerminology = _terminology
          .where((terminology) =>
              terminology.name.toLowerCase().contains(query.toLowerCase()) ||
              terminology.kurdish.toLowerCase().contains(query.toLowerCase()) ||
              terminology.arabic.toLowerCase().contains(query.toLowerCase()) ||
              terminology.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? themeProvider.theme.scaffoldBackgroundColor
          : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 4,
        surfaceTintColor: Colors.transparent,
        backgroundColor: themeProvider.isDarkMode
            ? themeProvider.theme.appBarTheme.backgroundColor
            : themeProvider.theme.colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode
                ? themeProvider.theme.colorScheme.onSurface
                : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          languageProvider.translate('terminology'),
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? themeProvider.theme.colorScheme.onSurface
                : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Color(0xFF2C2C2C)
                  : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: themeProvider.isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTerminology,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: languageProvider.translate('Search terminology...'),
                hintStyle: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: themeProvider.isDarkMode
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: themeProvider.isDarkMode
                        ? themeProvider.theme.colorScheme.primary
                        : Colors.blue,
                  ),
                  SizedBox(height: 16),
                  StreamBuilder<String>(
                    stream: _syncService.statusStream,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Loading terminology...',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : _filteredTerminology.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 80,
                        color: themeProvider.isDarkMode
                            ? Colors.grey[700]
                            : Colors.grey[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        languageProvider.translate('no_terminology_found'),
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[500],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    physics: const BouncingScrollPhysics(),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredTerminology.length,
                    itemBuilder: (context, index) {
                      final terminology = _filteredTerminology[index];
                      final isFavorite = favoritesProvider.isFavorite(terminology);

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: themeProvider.isDarkMode
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(createRoute(
                                TerminologyDetailsPage(terminology: terminology),
                              ));
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          terminology.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: isFavorite
                                          ? (themeProvider.isDarkMode
                                              ? Colors.blue.shade300
                                              : Colors.blue.shade700)
                                          : (themeProvider.isDarkMode
                                              ? Colors.grey[600]
                                              : Colors.grey[400]),
                                    ),
                                    onPressed: () {
                                      if (isFavorite) {
                                        favoritesProvider.removeFavorite(terminology);
                                      } else {
                                        favoritesProvider.addFavorite(terminology);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _startPeriodicSync() async {
    // Check for updates every 30 seconds in background
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (mounted) {
        try {
          final hasUpdates = await _syncService.checkForCategoryUpdates('dictionary');
          if (hasUpdates && mounted) {
            // Update data silently without showing loading
            final updatedData = _syncService.getCachedDictionary().cast<Word>();
            setState(() {
              _terminology = updatedData;
              _filteredTerminology = _terminology.where((terminology) =>
                  terminology.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                  terminology.kurdish.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                  terminology.arabic.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                  terminology.description.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
            });
          }
        } catch (e) {
          // Silent fail for background sync
          print('Background sync error: $e');
        }
      }
    });
  }
}