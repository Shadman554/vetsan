import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/language_provider.dart';
import '../providers/history_provider.dart';
import '../models/drug.dart';
import 'drug_details_page.dart';
import '../utils/page_transition.dart';

// Enum for drug classification
enum DrugClass {
  antibiotic,
  painkiller,
  antiviral,
  antiparasitic,
  hormone,
  other
}

// Extension to provide user-friendly string representation
extension DrugClassExtension on DrugClass {
  String get displayName {
    switch (this) {
      case DrugClass.antibiotic:
        return 'Antibiotics';
      case DrugClass.painkiller:
        return 'Painkillers';
      case DrugClass.antiviral:
        return 'Antivirals';
      case DrugClass.antiparasitic:
        return 'Antiparasitics';
      case DrugClass.hormone:
        return 'Hormones';
      case DrugClass.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case DrugClass.antibiotic:
        return Colors.blue.shade700;
      case DrugClass.painkiller:
        return Colors.red.shade700;
      case DrugClass.antiviral:
        return Colors.green.shade700;
      case DrugClass.antiparasitic:
        return Colors.purple.shade700;
      case DrugClass.hormone:
        return Colors.orange.shade700;
      case DrugClass.other:
        return Colors.grey.shade700;
    }
  }
}

// Removed duplicate Drug class. Using shared model from lib/models/drug.dart
/*class Drug {
  final String id;
  final String name;
  final String otherInfo;
  final String sideEffect;
  final String usage;
  final String imageUrl;
  final String category;
  final String drugClass;

  Drug({
    required this.id,
    required this.name,
    required this.otherInfo,
    required this.sideEffect,
    required this.usage,
    this.imageUrl = '',
    this.category = 'General',
    this.drugClass = '',
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      otherInfo: json['otherInfo'] ?? '',
      sideEffect: json['sideEffect'] ?? '',
      usage: json['usage'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'General',
      drugClass: json['class'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'otherInfo': otherInfo,
      'sideEffect': sideEffect,
      'usage': usage,
      'imageUrl': imageUrl,
      'category': category,
      'class': drugClass,
    };
  }
}
*/

class DrugsPage extends StatefulWidget {
  const DrugsPage({Key? key}) : super(key: key);

  @override
  _DrugsPageState createState() => _DrugsPageState();
}

class _DrugsPageState extends State<DrugsPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Drug> _drugs = [];
  List<Drug> _filteredDrugs = [];
  bool _isLoading = true;
  Set<String> _availableClasses = <String>{};
  String? _selectedClass;

  void _onDrugTap(BuildContext context, Drug drug) {
    // Add to history
    Provider.of<HistoryProvider>(context, listen: false).addToHistory(
      drug.name,
      'drug',
      'Viewed drug details'
    );
    
    // Navigate to drug details with custom transition
    Navigator.push(
      context,
      createRoute(DrugDetailsPage(drug: drug)),
    );
  }

  void _showFilterOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Color(0xFF1E1E1E)
                : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by Class',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildFilterOption(
                      'All Classes',
                      Icons.category,
                      Colors.blue,
                      null,
                    ),
                    ..._availableClasses.map((classValue) => _buildFilterOption(
                          classValue,
                          Icons.medical_services,
                          Colors.blue,
                          classValue,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String text, IconData icon, Color color, String? value) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedClass = value;
          _filterDrugs(_searchController.text);
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black12 : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            Spacer(),
            if (_selectedClass == value)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchDrugs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDrugs() async {
    try {
      final drugsList = await _apiService.fetchAllDrugs();
      setState(() {
        _drugs = drugsList.where((drug) => drug.name.isNotEmpty).toList();
        _filteredDrugs = _drugs;
        _availableClasses = _drugs.map((d) => d.drugClass).where((c) => c.isNotEmpty).toSet();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching drugs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterDrugs(String query) {
    setState(() {
      _filteredDrugs = _drugs.where((drug) {
        final nameMatch = drug.name.toLowerCase().contains(query.toLowerCase());
        final classMatch = _selectedClass == null || drug.drugClass == _selectedClass;
        return nameMatch && classMatch;
      }).toList();
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
          languageProvider.translate('drugs'),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterDrugs,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: languageProvider.translate('Search Drugs...'),
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
                Container(
                  height: 24,
                  width: 1,
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.2),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: themeProvider.isDarkMode
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                  onPressed: () => _showFilterOptions(context),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: themeProvider.isDarkMode
                    ? themeProvider.theme.colorScheme.primary
                    : Colors.blue,
              ),
            )
          : _filteredDrugs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 80,
                        color: themeProvider.isDarkMode
                            ? Colors.grey[700]
                            : Colors.grey[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        languageProvider.translate('no_drugs_found'),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    itemCount: _filteredDrugs.length,
                    itemBuilder: (context, index) {
                      final drug = _filteredDrugs[index];
                      final isFavorite = favoritesProvider.isFavorite(drug);

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
                            onTap: () => _onDrugTap(context, drug),
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
                                          drug.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (drug.drugClass.isNotEmpty) ...[
                                          SizedBox(height: 4),
                                          Text(
                                            drug.drugClass,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: themeProvider.isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
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
                                        favoritesProvider.removeFavorite(drug);
                                      } else {
                                        favoritesProvider.addFavorite(drug);
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
}
